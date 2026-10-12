# Security checklist

Run `drupal-security-review` after substantial changes. Baseline rules:

## Access
- Every route has `_permission`, `_custom_access`, `_entity_access` or `_access_checks`. Never `_access: 'TRUE'` unless the page is genuinely public.
- Entity queries: always call `->accessCheck(TRUE)` for user-facing results; `FALSE` only for deliberate system tasks, with a comment.
- Check `$entity->access('view|update|delete')` before exposing or changing entities in custom code paths.

## CSRF
- State-changing GET routes need `_csrf_token: 'TRUE'`.
- Use Form API for forms (token handled automatically). Custom AJAX/POST endpoints need `_csrf_request_header_token: 'TRUE'` or equivalent.

## Input
- Validate and type-cast request input (`$request->query->getInt()`, allow-lists for enum values).
- Validate in `validateForm()`; never trust `#default_value` round-trips.
- Uploaded files: use `file.validator`s, restrict extensions, private scheme for sensitive files.

## Output
- Render arrays escape by default. Use `#markup` only with trusted strings; for user text use `#plain_text` or `Xss::filter()`.
- `Markup::create()` / `|raw` only on sanitized content.
- Placeholders in `t()`: `@` (escaped), `%` (emphasized, escaped); `:` for URLs. Never `!`.

## Database
- Entity API first. If Database API is needed: placeholders and `->condition()`, never string concatenation; `$connection->escapeLike()` for LIKE.

## Secrets and logging
- Credentials via environment/Key module/settings.php, never in exported config or code.
- Log endpoint, status and entity ID; never tokens, passwords or full payloads containing personal data.
- External HTTP calls: set timeouts, verify TLS, catch `GuzzleException` specifically.

## Misc
- No `unserialize()` on user data; use JSON.
- Redirect targets from user input must be validated (`UrlHelper::isExternal()`/trusted redirect response).
- Don't expose stack traces or internal IDs in error responses.
