# Caching

Every render array, controller response and computed result must declare what it varies by and what invalidates it.

## Render metadata

```php
$build = [
  '#theme' => 'item_list',
  '#items' => $items,
  '#cache' => [
    'contexts' => ['user.permissions', 'languages:language_interface'],
    'tags' => $node->getCacheTags(),   // or ['node_list:article']
    'max-age' => Cache::PERMANENT,
  ],
];
```

- **Contexts**: what the output varies by (`user`, `user.permissions`, `url.query_args:page`, `languages:language_interface`). Pick the narrowest.
- **Tags**: what invalidates it. Use entity `getCacheTags()` / `getListCacheTags()`; custom tags via `Cache::invalidateTags(['my_module:thing'])`.
- **Max-age**: only for time-bound data. `0` disables caching and bubbles up the whole page; avoid it.
- Merge dependency metadata with `CacheableMetadata::createFromObject($entity)->applyTo($build)` or `addCacheableDependency()`.

## Responses

Controllers returning JSON should use `CacheableJsonResponse` and `addCacheableDependency()`, not plain `JsonResponse`, when the data is cacheable.

## Custom data caches

- Inject `cache.default` (or a custom bin declared as a service with tag `cache.bin`).
- Always pass tags to `set()`; never rely on expiry alone for entity-derived data.
- Cache short-lived tokens with `expire = request time + ttl - buffer`.

## Lazy builders

For per-user or highly dynamic fragments inside cacheable pages, use `#lazy_builder` with a `TrustedCallbackInterface` class (`#[TrustedCallback]` or `trustedCallbacks()`), so the rest of the page stays cacheable.

## Pitfalls

- `\Drupal::request()` reads without a matching context make output wrong for other users.
- Not caching because "it's custom" is wrong; uncached custom blocks hurt every page that renders them.
- Do not use `drupal_static()`/property memoization as a substitute for the cache API across requests.
