# External API clients and exposing APIs

## Consuming external APIs

- Model auth and business endpoints separately; interface for the client, domain services on top.
- Inject `http_client`; set `timeout`/`connect_timeout`; catch `GuzzleException`, log endpoint + status code + entity ID (never secrets), then throw a domain exception.
- Treat non-JSON or wrongly shaped payloads as errors, not partial success (`json_decode(..., flags: JSON_THROW_ON_ERROR)`).
- Normalize payloads into stable internal arrays/DTOs before mapping to entities; keep field mapping in one method per sync manager.
- Retries: only for idempotent calls, with backoff; otherwise queue and retry via `RequeueException`.
- Credentials: Key module or env via `settings.php`; never in exported config.

### OAuth client-credentials flow

1. POST form params to the token endpoint.
2. Cache `access_token` with `expire = now + expires_in - buffer` (e.g. 60s) in `cache.default`.
3. Send `Authorization: Bearer <token>`; on 401, drop the cached token and retry once.
4. Keep any API-specific body fields (company codes, API keys) in the request body if the API requires both.

## Exposing APIs

- Prefer core JSON:API (+ JSON:API Extras for aliases/field control) for entity data.
- Custom endpoints: a controller returning `CacheableJsonResponse`, with `_permission` or `_custom_access`, `methods: [GET]`, and `_format: json`.
- REST resource plugins (`#[RestResource]`) only when you need the REST module's authentication/serialization features.
- Authentication for machine clients: Simple OAuth. Never roll custom token checks.
- Version the path (`/api/v1/...`) and validate request bodies explicitly.
