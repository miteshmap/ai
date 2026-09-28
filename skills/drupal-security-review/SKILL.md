---
name: drupal-security-review
description: This skill should be used when the user asks to "run a Drupal security review", "audit custom modules for security issues", "check for Drupal security vulnerabilities", requests a security review of web/modules/custom or web/themes/custom, or before merging PRs that touch access control, forms, or data handling in this repository.
license: MIT
---

To perform a Drupal security review, audit this repository's custom code
against the checklist below, which is derived from
https://www.drupal.org/docs/administering-a-drupal-site/security-in-drupal.
Only report issues in project code (custom modules/themes, settings.php,
config), not Drupal core or third-party contrib modules unless they have been
patched locally. See `references/project-modules.md` for this repository's
custom module/theme scope paths and which modules to pay particular
attention to for specific checklist items.

## Review process

1. Load `references/project-modules.md` to get the custom module/theme scope
   paths and the per-checklist-item module hints for this repository.
2. Default to a diff-based review: identify the changed files (e.g. from the
   current PR/branch diff or currently staged/unstaged changes) that fall
   under the custom module/theme scope paths. Only run a full audit of the
   entire custom module/theme tree when explicitly asked for a full audit.
3. Walk the checklist below section by section. For each item, search the
   relevant code paths (PHP controllers/forms/services, `.twig` templates,
   `.js`, `.yml` permissions/routing, `settings.php`) for violations, using
   the module hints from `references/project-modules.md` to prioritize where
   to look first.
4. Skip sections that are not applicable (e.g. CAPTCHA/PCI sections only
   apply if that functionality exists in the code).
5. Report only real findings with file:line evidence — do not speculate.

## Checklist (from drupal.org "Security in Drupal")

### Writing secure code for Drupal
- **XSS / output sanitization**: Twig templates rely on autoescaping — flag
  any use of the `|raw` filter, `{{ content|raw }}`, or `#markup`/`#allowed_tags`
  render arrays built from unsanitized user input. Flag `class={{ class }}`
  style unquoted Twig attributes (must be quoted).
- Flag use of `check_markup()` outside a text-format context.
- In JS, flag direct DOM insertion of user-controlled strings without
  `Drupal.checkPlain()` / equivalent escaping.
- **SQL injection**: flag any `\Database::getConnection()->query()` or
  `db_query()` call with string-concatenated variables instead of named
  placeholders (`:name`) or the query builder (`->condition()`, `->select()`).
  Flag `LIKE` conditions missing `$connection->escapeLike()`. Flag user input
  used as a query *operator* instead of a value.
- **CSRF**: flag routes that perform state-changing actions (not just forms)
  without `_csrf_token: 'true'` access checks in `*.routing.yml`.
- Flag use of `t()`/placeholders where `@variable`, `%variable`, `:variable`
  are misapplied (e.g. `%variable` for a URL, `:variable` for arbitrary HTML).

### Security of generated PHP files
- Flag code that writes/generates `.php` files (e.g. via `file_put_contents`)
  into web-accessible directories, or disables Drupal's protections for the
  `php/twig` compiled-template/cache directories.

### Secure configuration for site builders
- Review `*.permissions.yml` and route/entity access callbacks for overly
  broad permissions (e.g. custom permissions granted to `authenticated user`
  that should be restricted), and missing access checks on new routes/forms.
- Flag debug/development settings left enabled for production (e.g.
  `error_level` set to display errors, Twig `debug`/`auto_reload` on) in
  `settings.php` / `sites/*/settings*.php`.

### Preventing execution of untrusted PHP
- Flag any use of the `php_eval`/PHP filter format, `eval()`, `create_function()`,
  or unserializing untrusted input (`unserialize()` on request data — prefer
  JSON).

### Securing authentication credentials
- Flag API keys, tokens, or passwords hardcoded in custom module PHP, JS, or
  committed config (`.yml`) instead of `settings.php`/environment variables/
  Key module. See `references/project-modules.md` for which integrations to
  check in particular for hardcoded secrets.
- Scan the exported config in `./config` (all `*.yml` files) for committed
  secrets: API keys, client secrets/ids, tokens, passwords, private keys, or
  SMTP/webhook credentials sitting directly in config values instead of being
  referenced via the Key module or environment/`settings.php` overrides. See
  `references/project-modules.md` for which config prefixes to pay
  particular attention to.

### Auditing config export for security-relevant permissions
- Cross-check `./config/user.role.*.yml` and `./config/*.permissions` entries
  against the "Secure configuration for site builders" guidance: flag broad
  permissions (e.g. "administer site configuration", "access administration
  pages", "bypass node access") granted to non-admin roles.
- Flag exported text-format config (`./config/filter.format.*.yml`) that
  grants a filtered/untrusted role access to the PHP filter or full HTML
  without appropriate restriction (see "Configuring text formats for
  security").

### Securing file permissions and ownership
- Flag custom code that changes file permissions to world-writable, or
  writes uploaded files without validating extension/mime type via Drupal's
  File API validators.

### Session management
- Flag custom code that alters session/cookie lifetime, `session.cookie_secure`,
  or bypasses Drupal's session handling insecurely.

### Password management
- Flag custom login/registration/password-reset code that stores passwords in
  plain text, logs passwords, or implements custom hashing instead of using
  Drupal's `PasswordInterface` service. See `references/project-modules.md`
  for which modules to check in particular.

### Privacy management / access bypass
- Flag custom access logic that doesn't account for the "deleting users who
  authored content can lead to access bypass" issue — e.g. custom node/entity
  access callbacks keyed only on `uid` without checking current permissions.
- Flag PII (emails, phone numbers, addresses) logged via `\Drupal::logger()`
  or exposed in custom REST/JSON endpoints without access control. See
  `references/project-modules.md` for which endpoints to check in
  particular.

### Securing your site / admin super user
- Flag code that grants `uid: 1`-equivalent bypass-access shortcuts, or
  custom permission checks using `->hasPermission('administer site
  configuration')` where a narrower permission would do.
- Flag hidden debug/admin routes without permission or access requirements
  in `*.routing.yml`.

### Hiding Drupal version / information disclosure
- Flag custom code that exposes stack traces, `phpinfo()`, or verbose error
  output to anonymous users.

## Output format

Present findings as a table:

| # | Severity | File | Lines | Issue | Checklist item |
|---|----------|------|-------|-------|-----------------|

Severities: 🔴 CRITICAL, 🟠 HIGH, 🟡 MEDIUM, ⚪ LOW.
End with a short summary of checklist sections reviewed and any that were
skipped as not applicable.

## Additional Resources

### Reference Files

- **`references/project-modules.md`** - This repository's custom module/theme
  scope paths and which modules to prioritize for each checklist item.
