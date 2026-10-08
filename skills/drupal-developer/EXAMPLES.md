# Drupal Development Examples

## 1) Service registration pattern

```yaml
services:
  my_module.client:
    class: Drupal\my_module\Client\ApiClient
    arguments: ['@http_client', '@config.factory', '@logger.factory', '@cache.default', '@datetime.time']

  Drupal\my_module\Client\ApiClientInterface:
    alias: my_module.client
```

## 2) PHP 8.3-friendly service skeleton

```php
<?php

namespace Drupal\my_module\Client;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\Logger\LoggerChannelFactoryInterface;
use GuzzleHttp\ClientInterface;

final class ApiClient implements ApiClientInterface {

  public function __construct(
    private readonly ClientInterface $httpClient,
    private readonly ConfigFactoryInterface $configFactory,
    private readonly LoggerChannelFactoryInterface $loggerFactory,
  ) {}

  public function request(string $endpoint, array $payload = []): array {
    // Build request, validate response, return normalized structure.
    return ['success' => TRUE, 'data' => []];
  }
}
```

## 3) Config schema reminder

```yaml
my_module.settings:
  type: config_object
  mapping:
    base_url: { type: string, label: 'Base URL' }
    sync_enabled: { type: boolean, label: 'Enable sync' }
```

## 4) Drush command pattern

```php
#[CLI\Command(name: 'my-module:sync')]
public function sync(): int {
  $summary = $this->syncManager->sync();
  return ($summary['errors'] ?? 0) > 0 ? self::EXIT_FAILURE : self::EXIT_SUCCESS;
}
```

## 5) OAuth + endpoint flow (Yardi-style)

1. Request token from `/connect/token` using form params.
2. Cache `access_token` with expiry minus safety buffer.
3. Use `Authorization: Bearer <token>` for endpoint request.
4. Keep domain payload (e.g., `apiToken`, `companyCode`) in request body if API requires both.

## 6) Common anti-patterns to avoid

- Direct `\Drupal::service()` inside normal classes (except procedural hooks where unavoidable).
- Missing schema entries for newly added config keys.
- Catching exceptions and returning success-shaped defaults.
- Writing entity fields without checking for actual value changes.

## 7) Admin config route + dependency reminder

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

If a menu link uses another module's parent route (for example `quintain_helper.settings`), add that module to your `.info.yml` dependencies.
