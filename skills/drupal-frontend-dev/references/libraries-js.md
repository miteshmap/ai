# Libraries, JavaScript and build pipeline

## `my_theme.libraries.yml`

```yaml
global:
  version: VERSION
  css:
    theme:
      dist/css/global.css: {}
  js:
    dist/js/global.js: {}
  dependencies:
    - core/drupal
    - core/once

gallery:
  css:
    component:
      dist/css/gallery.css: {}
  js:
    dist/js/gallery.js: { attributes: { defer: true } }
  dependencies:
    - core/drupal
    - core/once
```

- CSS categories in order: `base`, `layout`, `component`, `state`, `theme`. Use `weight` only to fix a real ordering problem.
- Never reference build input (`src/`) in libraries; point at compiled output. Commit or build compiled output according to project convention.
- Use `version` for cache-busting external or hashed assets; hashed filenames from the bundler need a manifest step or a stable output name.
- External libraries: `{ type: external, minified: true }` and a `license` block, or better, install via npm and bundle.

## Attaching

```twig
{{ attach_library('my_theme/gallery') }}
```

```php
function my_theme_preprocess_node(array &$variables): void {
  if ($variables['view_mode'] === 'full') {
    $variables['#attached']['library'][] = 'my_theme/gallery';
  }
}
```

- Global assets: `libraries:` in `my_theme.info.yml`.
- Prefer attaching in the template that needs it (per component/region) so unused pages stay lean. SDC attaches its own files automatically.
- Override or remove base-theme or core assets with `libraries-override` / `libraries-extend` in the info file, not by copying CSS.

## Drupal behaviors

```js
((Drupal, once) => {
  Drupal.behaviors.myGallery = {
    attach(context) {
      once('my-gallery', '.gallery', context).forEach((el) => {
        // initialise el
      });
    },
    detach(context, settings, trigger) {
      if (trigger === 'unload') {
        // clean up listeners/timers for elements in context
      }
    },
  };
})(Drupal, once);
```

- Always scope to `context` and guard with `once()`; behaviors re-run after AJAX, BigPipe and Views updates.
- Pass server data via `drupalSettings` (`$variables['#attached']['drupalSettings']['myTheme']['x']`), not data embedded in inline scripts.
- Use `Drupal.t()` for user-facing strings; use `Drupal.announce()` for live-region messages.
- Avoid jQuery in new code; vanilla JS is enough and `core/jquery` need not load.

## Build pipeline

- Use whatever the project already has (Vite, webpack, esbuild, Sass CLI). Look at `package.json` scripts before adding tooling.
- Expect: SCSS to CSS (+ PostCSS autoprefixer), JS bundled/transpiled to ES2017+ output, source maps in dev only, minification in prod.
- Tailwind: configure `content` globs to include `templates/`, `components/` and any module templates that render markup; otherwise classes are purged.
- Lint with stylelint, eslint, prettier; fix at source, not by disabling rules.
- Do not hardcode colors, spacing or breakpoints; use the project's SCSS variables, mixins or design tokens.
