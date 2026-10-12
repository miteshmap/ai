---
name: drupal-backend-dev
description: >-
  Drupal 10/11 server-side development: custom modules, services, plugins,
  event subscribers, OOP hooks, routing/permissions, config schema, entity
  queries, caching, queue workers, Drush commands, REST/JSON:API and external
  API clients. Use for writing, refactoring, debugging or reviewing PHP and
  YAML in custom modules. Not for Twig/SCSS/JS (use the frontend skill).
---

# Drupal Backend Development

## Quick start

1. Confirm the goal, integration points, and affected entity/config surfaces.
2. Discover existing patterns in the repo (forms, commands, services, hooks) and reuse them.
3. Scaffold files (`.info.yml`, `.services.yml`, routing, permissions, schema, install config). See [templates/module-template.md](templates/module-template.md).
4. Implement with dependency injection; no service locator in classes.
5. Validate with the project's own tooling (see "Validate").

## Required standards

- Drupal coding standards (load `drupal-coding-standards` when reviewing), config schema correctness, translatable strings (`$this->t()`, `TranslatableMarkup`).
- PHP 8.3+: typed properties/params/returns, constructor promotion, `readonly` for injected dependencies, no dynamic properties, explicit null handling.
- Baseline is Drupal 10.6+, being migrated to 11. Write code that runs on both:
  - Plugins use attributes (`#[Block]`, `#[QueueWorker]`, `#[RestResource]`), not annotations.
  - Hooks stay procedural in `.module`/`.install`, delegating to autowired services, until the site is on 11.1+. Convert to `#[Hook]` classes at migration time (see [references/plugins-events-hooks.md](references/plugins-events-hooks.md)).
  - Use no API deprecated in 10.x or removed in 11. Check with `upgrade_status` or `drupal-check`/PHPStan deprecation rules, and `core_version_requirement: ^10.6 || ^11`.
- No broad `try/catch` that hides failures; never return success-shaped defaults on error.
- Reuse existing services before adding abstractions.
- Entity/query/config APIs over raw SQL. Entity queries need an explicit `accessCheck()`.
- Per-request memoization: prefer a private array property in services; use `drupal_static()` only in procedural code. Never use either where persistent or tag-invalidated caching is needed.
- When API behaviour or signatures are unclear, check docs (Context7 MCP if connected, otherwise api.drupal.org) for the project's Drupal version instead of guessing.

## Workflow

1. **Design**: interfaces for external clients; low-level client separate from domain services; orchestration in dedicated manager classes; thin controllers/forms/commands.
2. **Implement**:
   - Schema + default config before using any new config key.
   - Admin routes get `options._admin_route: TRUE`.
   - Keep constructors and service definitions in lockstep (`*.services.yml`, `drush.services.yml`, plugin `create()`). Prefer `autowire: true` or named arguments over long positional lists.
3. **Harden**: see [references/security.md](references/security.md) and [references/caching.md](references/caching.md).
4. **Validate**: `php -l`, PHPCS with Drupal standard, PHPStan if configured, then tests (see `drupal-testing`). Run changed code paths via Drush where practical. After finishing a set of changes touching access, forms or data handling, run `drupal-security-review`.

## Reference files (load on demand)

- [references/caching.md](references/caching.md): cache metadata, contexts/tags/max-age, lazy builders, custom bins.
- [references/security.md](references/security.md): access, CSRF, input/output, queries, secrets.
- [references/plugins-events-hooks.md](references/plugins-events-hooks.md): plugins, event subscribers, OOP hooks, update hooks, queue workers.
- [references/api-clients.md](references/api-clients.md): external API/OAuth clients, REST/JSON:API.
- [EXAMPLES.md](EXAMPLES.md): concrete snippets and anti-patterns.

## Precision checklist

- Config keys exist in both install defaults and schema.
- Routes have explicit access (`_permission`, `_custom_access`, `_entity_access`); admin routes have the admin option.
- A menu link parented under another module's route needs that module in `.info.yml` dependencies.
- Constructor/DI parity: every changed constructor matches all service definitions (especially `drush.services.yml`).
- Drush commands return proper exit codes.
- Cron logic is idempotent and gated by config flags.
- Entities are saved only when values actually changed.
- Render arrays and controller responses carry cache metadata.
- Multilingual: no hardcoded English strings; load translations where entity output is language-dependent.
- README documents setup, commands, and endpoint/auth expectations.
- Config changes on existing sites ship with an update hook or config-sync note.
