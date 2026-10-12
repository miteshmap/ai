# Plugins, events, hooks, queues

Projects are on Drupal 10.6+ and migrating to 11: plugin attributes work on both; OOP hooks (`#[Hook]`) need 11.1+, so use procedural hooks until the site is on 11.

## Plugin (attribute discovery)

```php
namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\Block\BlockBase;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Drupal\Core\StringTranslation\TranslatableMarkup;
use Symfony\Component\DependencyInjection\ContainerInterface;

#[Block(id: 'my_module_example', admin_label: new TranslatableMarkup('Example'))]
final class ExampleBlock extends BlockBase implements ContainerFactoryPluginInterface {

  public function __construct(
    array $configuration,
    $plugin_id,
    $plugin_definition,
    private readonly ExampleService $example,
  ) {
    parent::__construct($configuration, $plugin_id, $plugin_definition);
  }

  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): static {
    return new static($configuration, $plugin_id, $plugin_definition, $container->get('my_module.example'));
  }

  public function build(): array {
    return ['#markup' => $this->example->label(), '#cache' => ['tags' => ['my_module:example']]];
  }

}
```

Custom plugin types: define an attribute class, a manager extending `DefaultPluginManager` (subdir, interface, attribute class, alter hook), and register it as a service with parent `default_plugin_manager`.

## Event subscriber

```php
final class ExampleSubscriber implements EventSubscriberInterface {

  public function __construct(private readonly LoggerInterface $logger) {}

  public static function getSubscribedEvents(): array {
    return [KernelEvents::REQUEST => ['onRequest', 30]];
  }

  public function onRequest(RequestEvent $event): void {}

}
```

```yaml
services:
  my_module.example_subscriber:
    class: Drupal\my_module\EventSubscriber\ExampleSubscriber
    arguments: ['@logger.channel.my_module']
    tags: [{ name: event_subscriber }]
  logger.channel.my_module:
    parent: logger.channel_base
    arguments: ['my_module']
```

## Hooks: procedural now, OOP at migration

On 10.6, write the hook in `.module` and delegate to a service:

```php
function my_module_cron(): void {
  \Drupal::service(CronHooks::class)->cron();
}
```

Registering the class as a service (`autowire: true`) keeps the logic testable and makes the later move to `#[Hook]` mechanical. Once on 11.1+, drop the procedural function. For a transition period supporting both, keep the function with `#[LegacyHook]` (`Drupal\Core\Hook\Attribute\LegacyHook`) in `my_module.module` and add the `#[Hook]` method; 11 then ignores the procedural one.

OOP form (11.1+ only):

```php
namespace Drupal\my_module\Hook;

use Drupal\Core\Hook\Attribute\Hook;

final class CronHooks {

  public function __construct(private readonly ConfigFactoryInterface $configFactory, private readonly SyncManager $sync) {}

  #[Hook('cron')]
  public function cron(): void {
    if ($this->configFactory->get('my_module.settings')->get('sync_enabled')) {
      $this->sync->sync();
    }
  }

}
```

Hook classes in `src/Hook/` are autowired and discovered automatically. In procedural hooks, `\Drupal::service()` is the one accepted use of the locator.

## Update hooks

- `hook_update_N()` in `.install` for schema/data changes; `hook_post_update_NAME()` in `.post_update.php` for entity/config work that needs the full API.
- Config changes on existing sites: update hook importing the new config, or config sync. Make updates idempotent and batch-aware (`$sandbox`).

## Queue worker

```php
#[QueueWorker(id: 'my_module_sync', title: new TranslatableMarkup('Sync'), cron: ['time' => 60])]
final class SyncWorker extends QueueWorkerBase implements ContainerFactoryPluginInterface {
  public function processItem($data): void {
    // Throw SuspendQueueException to stop the run; RequeueException to retry; other exceptions are logged.
  }
}
```

Enqueue from cron/forms with `$queueFactory->get('my_module_sync')->createItem([...])`. Items must be small, serializable, idempotent. Use Batch API (not queues) for user-triggered long jobs with progress.
