# Review checklist (seven dimensions)

Baseline: Drupal 10.6+ migrating to 11. Judge APIs against the version found in the project.

## Which dimensions apply

| Input | Check |
|---|---|
| Custom module (PHP) | All seven |
| Twig template | Security (XSS), Coding errors, Efficiency, Complexity, Duplication, Documentation |
| Config YAML | Security (access), Coding errors (schema, deps), Duplication, Documentation |
| `*.install` / update hooks | Coding errors (idempotency), Efficiency, Documentation |
| Patch / MR diff | All that apply to the changed lines and their callers |
| Test files | Testing, Documentation, Duplication |

Custom code is reviewed against Drupal standards. Contrib code also needs to meet Drupal.org contribution requirements (README, CHANGELOG, issue-linked `@todo`, no site-specific assumptions).

## Score anchors (every dimension)

| Score | Meaning |
|---|---|
| 9-10 | Exemplary. Nothing to report. |
| 7-8 | Minor findings only. |
| 5-6 | Several Minor findings, or one Major. |
| 3-4 | More than one Major, or pervasive Minor issues. |
| 1-2 | A Blocker is present, or the problem is systemic. |
| 0 | The dimension is entirely absent (e.g. no tests at all). |

## 1. Security (weight 25, blocking)

Any confirmed vulnerability is a Blocker.

**SQL injection**
- Interpolated or concatenated queries (`$connection->query("... $nid")`). Fix: placeholders (`:nid`).
- `LIKE` without `escapeLike()`; `ORDER BY` or identifiers from user input instead of an allow-list.

**XSS**
- `|raw` on user data; `{{ include(user_input) }}` (SSTI).
- `#markup` with user input; `Markup::create()` on unsanitized strings; raw HTML in `drupalSettings`.
- Fix: Twig autoescape, `Xss::filter()` / `Xss::filterAdmin()` / `Html::escape()` / `#plain_text`.

**Access control**
- Routes without `requirements:`, or `_access: 'TRUE'` on a sensitive route.
- `_role` where `_permission` is correct; permission borrowed from another module instead of defined in `*.permissions.yml`.
- Entity data returned without `->access('view', $account)`; entity queries without explicit `accessCheck()`.
- Privileged form elements missing `#access` (disabling a field is not access control); permission enforced only in the theme layer.
- `AccessResult` without `addCacheableDependency()`.
- State-changing GET routes without `_csrf_token`.

**CSRF**
- Custom POST handling that bypasses Form API tokens; REST/JSON:API write endpoints without `_csrf_request_header_token`.

**Secrets and config**
- Credentials/tokens in code, `drupalSettings`, committed `settings.php` or exported config.
- `trusted_host_patterns` missing on production; sensitive config not excluded from `drush cex`.

**File handling**
- Uploads without `FileExtension`/`FileMimeType` validators; sensitive files on the public scheme; unsanitized filenames in paths; user-controlled destinations.

**Injection-adjacent**
- `unserialize()` on request data, `eval()`, `exec()`/`shell_exec()` with input, `include` on dynamic paths, open redirects.

## 2. Coding errors (weight 20)

**Deprecated or removed APIs** (check against target version)
- `db_query()`/`db_select()`/`db_insert()`/`db_update()`/`db_delete()` (use injected `Connection`), `drupal_set_message()`, `l()`, `format_date()`, `file_load()`, `node_load()`, `entity_load()`, `arg()`, `drupal_render()`, `\Drupal::entityManager()`.
- Plugin annotations where attributes apply (attributes are fine on 10.6, so annotations in new code are a finding).
- Hooks: procedural hooks are correct on 10.6 and 11.0. Flag them only if the project is on 11.1+ and has moved to `#[Hook]` classes (then `hooks_converted: true` applies). Flag `#[Hook]` classes if the project still supports 10.

**Types and signatures**
- Signature incompatible with parent (LSP), missing return type, wrong nullability, missing return path.
- `@param`/`@return` disagreeing with the signature.
- Field access without a `hasField()` guard where the field may not exist.

**Render and cache**
- Render arrays or responses missing `#cache` tags/contexts/max-age: a correctness bug, not a nit.
- `#markup` where `#plain_text` or a renderable `#type` is right; `#attached` placed where it won't bubble.

**Config and schema**
- Config read/written with no `config/schema/*.schema.yml` entry or install default.
- Hardcoded UUIDs or config names; missing/wrong `core_version_requirement`; wrong dependency keys.

**Services and DI**
- Missing `arguments:` for constructor dependencies; constructor/service-definition mismatch (including `drush.services.yml`).
- `\Drupal::service()` in a class that could take the dependency.

**Translation**
- `t()` as a global in a class (use `$this->t()` / `StringTranslationTrait`).
- Placeholder misuse: `@` escapes, `%` escapes and emphasizes, `:` is URL-only; `!` is never allowed. `t()` wrapping dynamic or user strings.

**Update path**
- Schema/data/config change with no `hook_update_N()` or `hook_post_update_NAME()`; non-idempotent updates; missing docblock explaining the change.
- Swallowed exceptions returning success-shaped defaults.

## 3. Efficiency (weight 15)

**Queries**
- `load()` inside a loop (N+1): use `loadMultiple()`, `loadByProperties()` or an entity query.
- Queries inside loops, `hook_entity_view`, preprocess or a block's `build()`.
- Unbounded result sets (no `range()`/pager); loading full entities for one field value.
- Custom tables in `hook_schema()` without indexes on queried columns.

**Caching**
- Expensive computation with no memoization or cache.
- `max-age: 0` on non-user-specific content; missing `addCacheableDependency()`.
- Over-broad tags (invalidating everything on every save); `user` context where `user.roles` / `user.permissions` suffices.
- Cache writes on every request.

**Views and rendering**
- Unpaginated or unbounded Views; `views_embed_view()` in a loop.
- Heavy logic or deep loops in Twig; a library attached per render item instead of once.
- Aggregation-hostile assets.

**Background work**
- `hook_cron` doing unbounded synchronous work (queue it); blocking HTTP calls on the render path.

## 4. Complexity (weight 12)

- Functions over ~40 lines, nesting beyond three levels, branches an early return would flatten.
- `\Drupal::` statics inside service classes: the most common Drupal complexity smell.
- God classes; classes with more than one reason to change.
- Controllers or forms holding business logic; hook bodies containing logic instead of delegating.
- `switch`/`if-else` chains on bundle, entity type or plugin id (want a plugin, tagged service or map).
- Mysterious names, boolean traps (`doThing(TRUE, FALSE)`); comments explaining *what* not *why*; commented-out code.
- Premature abstraction: interface with one implementation, config nobody sets.
- Feature logic living in a shared or generic module.
- A refactor that relocates complexity is not a simplification. Count the concepts a reader must hold.

## 5. Duplication (weight 10)

- Copy-pasted hook bodies or controller actions; repeated query or cache-metadata building.
- Duplicated permission, route or service definitions; duplicated schema across bundles.
- Logic a core or installed contrib module already provides (search before accepting bespoke code).
- A near-duplicate of a canonical helper in the same codebase is **Major**, not Nit: two implementations of one rule drift apart. Extract on the third occurrence, not the first.

## 6. Testing (weight 10)

Use the `drupal-testing` skill for bootstrap-level guidance.

- **Existence:** tests for the changed logic. New untested logic scores 0-3.
- **Right type:** Unit (no bootstrap), Kernel (services/entities, DB), Functional / FunctionalJavascript (UI), ExistingSite. A Functional test for pure logic is Major.
- **Behavior, not implementation:** no assertions on private internals or exact call order.
- **Edge cases:** empty, null, boundary, permission-denied, exception paths. Happy-path-only is Major.
- **Security paths:** access callbacks, form validation, sanitization must be tested.
- **Regression test** for every bug fix (fails before, passes after); missing is Major.
- **Assertion quality:** deprecated `assertEqual()`, meaningless assertions (`assertTrue(TRUE)`), assertions that cannot fail, tests that pass vacuously (zero assertions, wrong bootstrap).
- **Testability:** code made untestable by `\Drupal::` statics or hard-coded dependencies is itself a finding. Fix the code, not the test.
- **Independence:** no ordering dependence, leaked global state or leftover temp files.
- Never acceptable: weakening, skipping or deleting an assertion to make a suite pass.

## 7. Documentation (weight 8)

- File and class docblocks stating purpose; method docblocks with imperative summary, `@param`, `@return`, `@throws`.
- Property docblocks with `@var` type (required by Drupal standards).
- Hook implementations say what they do and link the hook's API page.
- Update hooks explain what changes and why.
- README (install, config, usage), CHANGELOG for contributed modules; project docs updated per the repo's `AGENTS.md`.
- Inline comments for the *why* behind workarounds, core bugs, unusual queries.
- Config schema entries with meaningful `label`/`description`; `@todo` tied to an issue link.
- Docblock types that match the code. A wrong docblock is worse than none because it is trusted.
