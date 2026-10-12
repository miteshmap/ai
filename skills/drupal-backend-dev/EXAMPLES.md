# Drupal Backend Examples

## 1) Service registration (autowired, with interface alias)

```yaml
services:
  _defaults:
    autowire: true

  Drupal\my_module\Client\ApiClient: ~
  Drupal\my_module\Client\ApiClientInterface: '@Drupal\my_module\Client\ApiClient'
```

When autowiring is not possible (scalar args, several services of one type), use explicit arguments and keep them in lockstep with the constructor:

```yaml
services:
  my_module.client:
    class: Drupal\my_module\Client\ApiClient
    arguments: ['@http_client', '@config.factory', '@logger.channel.my_module']
```

## 2) PHP 8.3 service skeleton

```php
<?php

namespace Drupal\my_module\Client;

use Drupal\Core\Config\ConfigFactoryInterface;
use GuzzleHttp\ClientInterface;
use GuzzleHttp\Exception\GuzzleException;
use Psr\Log\LoggerInterface;

final class ApiClient implements ApiClientInterface {

  public function __construct(
    private readonly ClientInterface $httpClient,
    private readonly ConfigFactoryInterface $configFactory,
    private readonly LoggerInterface $logger,
  ) {}

  public function request(string $endpoint, array $payload = []): array {
    $base = $this->configFactory->get('my_module.settings')->get('base_url');
    try {
      $response = $this->httpClient->request('POST', $base . $endpoint, ['json' => $payload, 'timeout' => 10]);
      return json_decode((string) $response->getBody(), TRUE, flags: JSON_THROW_ON_ERROR);
    }
    catch (GuzzleException | \JsonException $e) {
      $this->logger->error('Request to @endpoint failed: @message', ['@endpoint' => $endpoint, '@message' => $e->getMessage()]);
      throw new ApiException('Request failed.', previous: $e);
    }
  }

}
```

## 3) Config schema

```yaml
my_module.settings:
  type: config_object
  mapping:
    base_url: { type: string, label: 'Base URL' }
    sync_enabled: { type: boolean, label: 'Enable sync' }
```

## 4) Drush command with DI and exit codes

```php
namespace Drupal\my_module\Drush\Commands;

use Drush\Attributes as CLI;
use Drush\Commands\DrushCommands;

final class MyModuleCommands extends DrushCommands {

  public function __construct(private readonly SyncManager $syncManager) {
    parent::__construct();
  }

  #[CLI\Command(name: 'my-module:sync')]
  #[CLI\Usage(name: 'drush my-module:sync', description: 'Run the sync.')]
  public function sync(): int {
    $summary = $this->syncManager->sync();
    return ($summary['errors'] ?? 0) > 0 ? self::EXIT_FAILURE : self::EXIT_SUCCESS;
  }

}
```

```yaml
# drush.services.yml
services:
  my_module.commands:
    class: Drupal\my_module\Drush\Commands\MyModuleCommands
    arguments: ['@my_module.sync_manager']
    tags: [{ name: drush.command }]
```

## 5) Entity query

```php
$ids = $this->entityTypeManager->getStorage('node')->getQuery()
  ->accessCheck(TRUE)
  ->condition('type', 'article')
  ->condition('status', 1)
  ->sort('changed', 'DESC')
  ->range(0, 10)
  ->execute();
$nodes = $this->entityTypeManager->getStorage('node')->loadMultiple($ids);
```

## 6) Update only when changed

```php
if ($node->get('field_ref')->target_id !== $new_id) {
  $node->set('field_ref', $new_id)->save();
}
```

## 7) Admin config route

```yaml
my_module.settings:
  path: '/admin/config/my-module/settings'
  defaults:
    _form: '\Drupal\my_module\Form\MyModuleSettingsForm'
    _title: 'My Module settings'
  requirements:
    _permission: 'administer my module settings'
  options:
    _admin_route: TRUE
```

A menu link whose parent is another module's route needs that module in `.info.yml` `dependencies`.

## 8) Anti-patterns

- `\Drupal::service()` in normal classes.
- Config keys missing from schema or install defaults.
- Catching exceptions and returning success-shaped defaults.
- Entity queries without `accessCheck()`.
- Saving entities without checking for actual changes.
- `#cache => ['max-age' => 0]` to "fix" stale output instead of correct tags/contexts.
- Constructor changed but `services.yml` / `drush.services.yml` not updated.
