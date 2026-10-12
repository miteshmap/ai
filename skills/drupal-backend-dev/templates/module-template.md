# Drupal Custom Module Template (Copy/Paste Starter)

Use `my_module` as placeholder. Layout:

```
my_module/
  my_module.info.yml
  my_module.services.yml
  my_module.permissions.yml
  my_module.routing.yml
  my_module.links.menu.yml
  my_module.install
  drush.services.yml            (only if Drush commands)
  config/install/my_module.settings.yml
  config/schema/my_module.schema.yml
  src/Form/MyModuleSettingsForm.php
  my_module.module              (thin procedural hooks)
  src/Hook/CronHooks.php        (service holding hook logic)
  src/Drush/Commands/MyModuleCommands.php
  tests/src/Unit | Kernel
  README.md
```

## `my_module.info.yml`

```yaml
name: 'My Module'
type: module
description: 'Custom integration module.'
core_version_requirement: ^10.6 || ^11
package: 'Custom'
dependencies: []
```

Add any module whose route is used as a menu-link parent to `dependencies`. Do not use `#[Hook]` classes until the project is on 11.1+.

## `my_module.services.yml`

```yaml
services:
  _defaults:
    autowire: true
  Drupal\my_module\Service\ExampleService: ~
  logger.channel.my_module:
    parent: logger.channel_base
    arguments: ['my_module']
```

## `my_module.permissions.yml`

```yaml
administer my module settings:
  title: 'Administer My Module settings'
  restrict access: true
```

## `my_module.routing.yml`

```yaml
my_module.settings:
  path: '/admin/config/services/my-module'
  defaults:
    _form: '\Drupal\my_module\Form\MyModuleSettingsForm'
    _title: 'My Module settings'
  requirements:
    _permission: 'administer my module settings'
  options:
    _admin_route: TRUE
```

## `my_module.links.menu.yml`

```yaml
my_module.settings:
  title: 'My Module'
  route_name: my_module.settings
  parent: system.admin_config_services
```

## `config/install/my_module.settings.yml`

```yaml
base_url: ''
sync_enabled: false
```

## `config/schema/my_module.schema.yml`

```yaml
my_module.settings:
  type: config_object
  label: 'My Module settings'
  mapping:
    base_url: { type: string, label: 'Base URL' }
    sync_enabled: { type: boolean, label: 'Enable cron sync' }
```

## `src/Form/MyModuleSettingsForm.php`

```php
<?php

namespace Drupal\my_module\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

final class MyModuleSettingsForm extends ConfigFormBase {

  protected function getEditableConfigNames(): array {
    return ['my_module.settings'];
  }

  public function getFormId(): string {
    return 'my_module_settings';
  }

  public function buildForm(array $form, FormStateInterface $form_state): array {
    $config = $this->config('my_module.settings');
    $form['base_url'] = [
      '#type' => 'url',
      '#title' => $this->t('Base URL'),
      '#default_value' => $config->get('base_url'),
    ];
    $form['sync_enabled'] = [
      '#type' => 'checkbox',
      '#title' => $this->t('Enable cron sync'),
      '#default_value' => $config->get('sync_enabled'),
    ];
    return parent::buildForm($form, $form_state);
  }

  public function submitForm(array &$form, FormStateInterface $form_state): void {
    $this->config('my_module.settings')
      ->set('base_url', $form_state->getValue('base_url'))
      ->set('sync_enabled', (bool) $form_state->getValue('sync_enabled'))
      ->save();
    parent::submitForm($form, $form_state);
  }

}
```

`ConfigFormBase` already receives `config.factory` (and typed config manager) via its parent `create()`. Add `create()` only for extra dependencies.

## Cron

`my_module.module` (10.6 and 11): the hook only delegates to a service.

```php
function my_module_cron(): void {
  // Procedural hook: the accepted place for the service locator.
  \Drupal::service(Drupal\my_module\Hook\CronHooks::class)->cron();
}
```

`CronHooks` is an autowired service that checks `sync_enabled` and calls the sync manager. When the project reaches 11.1+, move to `#[Hook('cron')]`; see [../references/plugins-events-hooks.md](../references/plugins-events-hooks.md). Keep cron work idempotent; push heavy work to a queue.

## `my_module.install`

```php
function my_module_update_10001(): void {
  // Idempotent change for existing sites (config import, data fix).
}
```

## Drush command

See EXAMPLES.md section 4 for the class and `drush.services.yml`.

## Tests

Put pure logic in Unit tests, entity/config/service wiring in Kernel tests; see the `drupal-testing` skill.
