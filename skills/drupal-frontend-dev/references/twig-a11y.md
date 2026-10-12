# Twig, preprocess, images, accessibility, subsystems

## Twig practices

- Keep logic out of templates: print, loop, simple conditions. Reshape data in preprocess.
- Print fields with `{{ content.field_x }}` (keeps cache metadata and field wrapper). Use `{{ content|without('field_x') }}` to render the rest. Use `{{ node.field_x.value }}` only for raw values and remember that bypasses formatters and cache bubbling from the field.
- Use `create_attribute()` for custom attribute sets; merge with `attributes.addClass()` and `.setAttribute()`.
- `{% trans %}` or `|t` for strings; never concatenate translated fragments.
- Test emptiness with `{% if content.field_x|render|trim %}` only when needed; `|render` breaks lazy/cache bubbling if overused, so prefer `{% if content.field_x['#items'] is not empty %}` style checks.
- Do not use `|raw`; if markup must be trusted, sanitize in PHP.

## Preprocess and suggestions

```php
function my_theme_preprocess_node(array &$variables): void {
  $node = $variables['node'];
  $variables['reading_time'] = /* computed or from a service */;
  $variables['#cache']['tags'][] = 'config:my_module.settings';
}

function my_theme_theme_suggestions_node_alter(array &$suggestions, array $variables): void {
  $suggestions[] = 'node__' . $variables['elements']['#node']->bundle() . '__' . $variables['elements']['#view_mode'];
}
```

- Keep preprocess small and typed; delegate non-trivial logic to a service in a module.
- Any data that depends on user, URL, language or config needs matching cache contexts/tags.
- Preprocess is per-hook; check it targets the right hook (`node`, `field`, `paragraph`, `views_view_unformatted`, `block`).

## Images and media

- Use responsive image styles (`responsive_image` module) with breakpoints from the theme's `breakpoints.yml`; render via the media/image field formatter so `srcset` and `sizes` are generated.
- Provide width/height (formatters add them) to avoid layout shift.
- Lazy loading: Drupal core adds `loading="lazy"`; set `eager` and `fetchpriority="high"` on the above-the-fold LCP image only.
- Prefer WebP/AVIF image style conversions when the project supports them.
- In Views, set the field formatter to the responsive image style rather than hand-built `<img>` in the Views template.

## Accessibility (WCAG 2.1 AA minimum)

- Semantic landmarks (`header`, `nav`, `main`, `footer`), one `h1`, heading levels in order. Pass `heading_level` as a component prop when a component can appear at different depths.
- Every `img` has `alt`; decorative uses `alt=""`. Icon-only buttons/links need an accessible name (`aria-label` or visually hidden text).
- Interactive elements are real `<button>`/`<a>`; visible `:focus-visible` styles; logical tab order; no keyboard traps in modals/menus.
- Color contrast at least 4.5:1 text, 3:1 large text/UI; do not rely on color alone.
- Use `aria-expanded`, `aria-controls`, `aria-current` correctly and keep them in sync in JS. Do not add ARIA where native semantics exist.
- Respect `prefers-reduced-motion`; provide skip link; announce dynamic updates with `Drupal.announce()` or `aria-live`.
- Verify with Axe DevTools or Lighthouse plus a keyboard-only pass.

## Subsystem notes

- **Views:** override `views-view-unformatted--<view>--<display>.html.twig` or use view modes + field formatters; avoid Views "rewrite as custom text" markup for structural HTML.
- **Layout Builder:** components must not assume a specific page context; check blocks render in sections and in preview.
- **Webform:** theme via `webform-element`/`form-element` suggestions and keep states/validation markup accessible.
- **CKEditor 5:** content styles go in a library listed under `ckeditor5-stylesheets` in the theme info file so the editor matches the front end.
- **Media entities:** theme `media--<bundle>--<view_mode>.html.twig`; keep caption/credit markup semantic (`figure`/`figcaption`).
- **Decoupled:** state whether it is progressively decoupled (JS components mounted via behaviors/`drupalSettings`) or fully headless; for the former, still go through libraries and `once()`.
