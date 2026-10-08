---
name: drupal-developer
description: Builds and reviews Drupal 10/11 custom module code with PHP 8.3+ standards, Drupal APIs, and production-safe patterns. Use when users ask to create/refactor Drupal modules, services, forms, plugins, Drush commands, config schema, or integration clients (APIs, cron, queues, entity sync).
---

# Drupal Development

## Quick start

1. Confirm module goal, integration points, and affected entity/config surfaces.
2. Scaffold module files (`.info.yml`, `.services.yml`, routing, permissions, schema, install config).
3. Implement with dependency injection first; avoid service locator in classes.
4. Add commands/cron/queues only when needed; keep error handling explicit.
5. Validate syntax, coding standards, and behavior with existing project tooling.

## Required standards

- Follow Drupal coding standards, config schema correctness, and translation-safe strings.
- Use PHP 8.3+ practices:
  - Typed properties/params/returns everywhere practical.
  - Constructor property promotion for injected dependencies.
  - `readonly` for immutable dependencies/value objects when safe.
  - No dynamic properties; no silent `mixed` pipelines.
  - Prefer explicit null handling and narrow types over broad casts.
- Keep code behavior-safe: no broad try/catch that hides failures.
- Reuse existing services/helpers before adding new abstractions.
- Use entity/query APIs and config APIs; avoid raw SQL unless truly required.
- Prefer `drupal_static()` for lightweight per-request caching when repeated lookups can happen within the same request and persistence beyond the request is not needed.
- Follow existing repo style for `drupal_static()`:
  - use `&drupal_static(__FUNCTION__, [])` for method-local memoization keyed by lookup input
  - use a named static key only when the cached value must be shared across methods/call sites
  - cache resolved entities/results after the first lookup, including `NULL` when that avoids repeated misses
  - do not replace persistent/cache-tagged caching needs with `drupal_static()`
- **Reference policy (mandatory):** When in doubt or when API behavior/signatures are unclear, always use Context7 MCP docs instead of assumptions — use `drupal/drupal/10_4_8` for Drupal 10 work and `drupal/drupal/11.2.2` for Drupal 11 work.

## Drupal module workflow

1. **Discover**
   - Find existing patterns in same repo (forms, commands, services, cron hooks).
   - Check target fields/bundles/config names before mapping data.
2. **Design**
   - Define interfaces for external API clients.
   - Split low-level client from endpoint/domain services.
   - Keep sync/orchestration in dedicated manager classes.
3. **Implement**
   - Add schema + default config before using new config keys.
   - Mark admin configuration routes with `options._admin_route: TRUE`.
   - Register services with explicit arguments and aliases/interfaces.
   - Keep constructor signatures and service definitions in lockstep (`*.services.yml`, `drush.services.yml`, plugin managers).
   - Keep controllers/forms/commands thin; delegate to services.
4. **Harden**
    - Validate response shapes defensively.
    - Log actionable error context (endpoint, code, entity id), never secrets.
    - Cache short-lived tokens with expiry buffers when using OAuth APIs.
    - Add `drupal_static()` memoization for repeated in-request entity/API lookups when profiling or code structure suggests duplicate work.
5. **Validate**
   - Run `php -l` and project PHPCS standards.
   - Run available Drupal/Drush checks already present in repo.

## Drupal Best Practices
- Use Drupal's database API instead of raw SQL queries
- Implement Repository pattern for data access logic
- Utilize the service container for dependency injection
- Leverage Drupal's caching API for performance optimization
- Use Queue API for background processing
- Implement comprehensive PHPUnit testing
- Follow the configuration management system
- Use Drupal's entity system and Field API appropriately
- Implement hooks properly following Drupal conventions
- Use Form API for all form handling

## Integration best practices (API clients)

- Model auth and business endpoints separately.
- Prefer token caching with explicit TTL + refresh buffer.
- Treat non-JSON/invalid payloads as errors, not partial success.
- Normalize external payloads into stable internal DTO-style arrays before mapping.
- Keep field mapping isolated in one method per sync manager.

## Precision checklist

- Config keys exist in both install defaults and schema.
- Routes have explicit permissions and admin route option where relevant.
- If a menu link is parented under another module's route, declare that module in `.info.yml` dependencies.
- Drush commands return proper exit codes.
- Constructor/DI parity check passes: every changed constructor matches all related service definitions (especially `drush.services.yml` for Drush command classes).
- Cron logic is idempotent and gated by config flags.
- Node/entity updates only write when values actually changed.
- README includes setup, commands, endpoint/auth expectations.

## Templates and examples

- See [EXAMPLES.md](EXAMPLES.md) for concrete module patterns.
- See [templates/module-template.md](templates/module-template.md) for copy/paste scaffolds.
