# Drupal Custom Module Template (Copy/Paste Starter)

Use `my_module` as placeholder.

## `my_module.info.yml`

```yaml
name: 'My Module'
type: module
description: 'Custom integration module.'
core_version_requirement: ^10 || ^11
package: 'Custom'
```

If your menu links are parented under another module's route, declare that module in `dependencies:`.

## `my_module.services.yml`

```yaml
services:
  my_module.example:
    class: Drupal\my_module\Service\ExampleService
    arguments: ['@config.factory', '@logger.factory']
```

## `my_module.permissions.yml`

```yaml
administer my module settings:
  title: 'Administer My Module settings'
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

## `config/schema/my_module.schema.yml`

```yaml
my_module.settings:
  type: config_object
  mapping:
    base_url: { type: string, label: 'Base URL' }
    sync_enabled: { type: boolean, label: 'Enable cron sync' }
```

## `src/Form/MyModuleSettingsForm.php` structure

```php
class MyModuleSettingsForm extends ConfigFormBase {
  public function getFormId(): string {}
  protected function getEditableConfigNames(): array {}
  public function buildForm(array $form, FormStateInterface $form_state): array {}
  public function submitForm(array &$form, FormStateInterface $form_state): void {}
}
```

## `src/Commands/MyModuleCommands.php` structure

```php
class MyModuleCommands extends DrushCommands {
  public function __construct(private readonly SyncManager $syncManager) { parent::__construct(); }
  #[CLI\Command(name: 'my-module:sync')]
  public function sync(): int {}
}
```

## `my_module.module` cron stub

```php
function my_module_cron(): void {
  if (!\Drupal::config('my_module.settings')->get('sync_enabled')) {
    return;
  }
  \Drupal::service('my_module.sync_manager')->sync();
}
```
