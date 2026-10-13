---
name: drupal-frontend-dev
description: >-
  Drupal 10/11 frontend and theming: Twig templates, Single Directory
  Components (SDC), libraries.yml asset loading, preprocess hooks, theme
  suggestions, SCSS/JS build pipelines, Drupal behaviors, responsive images,
  Views/Media/Layout Builder/Webform/CKEditor 5 theming, and accessibility
  review. Use for building or debugging anything the user sees or the browser
  runs in a Drupal theme. Not for custom module PHP (use drupal-backend-dev).
---

# Drupal Frontend Development

Baseline: Drupal 10.6+, being migrated to 11. SDC is stable in both. Never use deprecated patterns (`.tpl.php`, `template.php`, `drupal_add_js`, jQuery-dependent core behaviors).

## Quick start

1. Read the project first: active theme, base theme, existing components, build tooling (`package.json`), design tokens/SCSS variables. Reuse before creating.
2. If the task references Figma, load the `figma` skill before writing markup or styles, and map to existing tokens instead of hardcoding values.
3. Pick the right layer (see below), implement, then validate (see "Validate").

## Choosing the layer

| Need | Use |
|---|---|
| Reusable UI piece with defined inputs | SDC component ([references/sdc.md](references/sdc.md)) |
| Markup for an entity/field/view/block | Twig template override, picked by theme suggestion |
| Data shaping before rendering | `hook_preprocess_HOOK()` in `.theme` (thin; heavy logic belongs in a backend service) |
| CSS/JS on specific pages or components | `libraries.yml` + attach in template, preprocess or SDC auto-attach ([references/libraries-js.md](references/libraries-js.md)) |
| Responsive/lazy images | Responsive image styles + media/image formatters ([references/twig-a11y.md](references/twig-a11y.md)) |

## Required standards

- Drupal coding standards (use `drupal-coding-standards` when reviewing); BEM naming (`block__element--modifier`).
- No inline CSS or JS. Attach assets through libraries only.
- Prefer component isolation over global styles; keep DOM minimal and semantic.
- Build mobile-first; meet WCAG 2.1 AA at minimum.
- Never break render caching. If a template or preprocess adds dynamic data, add cache contexts/tags/max-age to the render array. Do not set `max-age: 0` to hide staleness.
- Escape by default: no `|raw` or `Markup::create()` on untrusted content. Translatable strings in Twig use `{{ 'Text'|t }}`.
- JS uses `Drupal.behaviors` with `once()` and declares `core/drupal` and `core/once` dependencies. Do not add jQuery unless an existing dependency forces it.
- Code must pass the project's stylelint, eslint and prettier configs.

## Common CSS/JS pitfalls

- **Media query order:** an `@media` block nested before later declarations in the same rule is overridden by them. Put nested media blocks after the base declarations.
- **SVG icon colour:** inline SVGs with a hardcoded `fill` ignore `stroke`/`color` hover rules. Use `fill: currentColor` (or `stroke: currentColor` for stroke icons) and set `color` on the parent.
- **Breakpoints:** use the theme's breakpoint variables, never raw px; check which devices each one includes (e.g. a 992px "md" excludes 768px tablets).
- **JS-injected markup:** `Drupal.behaviors` and plugins (Owl, Slick, etc.) do not run on HTML injected by your own `fetch`; call the init function after injection, or `Drupal.attachBehaviors(container)`.
- **Flex children with carousels/sliders:** add `min-width: 0` to the flex child, otherwise the slider's wide inner stage stretches the layout.
- **Global component rules:** before styling a reused class (e.g. a button modifier), read its global `:hover`/`:focus` rules; they often change border or background and must be overridden too.

## Debugging checklist

1. **Template not used:** enable Twig debug (`development.services.yml`: `twig.config: { debug: true, auto_reload: true, cache: false }`), read the suggestion comments in the HTML source, rename to the most specific match, rebuild cache (`drush cr`).
2. **Styles/JS not loading:** confirm the library is defined, attached (`{{ attach_library('theme/lib') }}`, `#attached`, or `libraries:` in the theme info), dependency/weight order is right (`weight`, `dependencies`, `SMACSS` groups), the build output exists at the declared path, and aggregation is not hiding a 404 (disable CSS/JS aggregation locally).
3. **Wrong or stale output:** inspect cache metadata (contexts/tags/max-age) on the render array; check preprocess runs for that hook and view mode.
4. **JS not firing:** verify the behavior attaches (`Drupal.behaviors.x.attach`), `once()` selector matches, library dependencies include `core/once`, and the code runs after AJAX/BigPipe replacements.
5. **Component props rejected:** SDC validates against the schema in dev; read the exception, fix the prop type or the schema.

## Validate

- Run the project's build, lint and test commands (look in `package.json`, `Makefile`, `ddev` commands). After changing SCSS/JS, rebuild; after changing YAML or templates, `drush cr`.
- Check the result in a browser at mobile and desktop widths; run Lighthouse or Axe for a11y/performance where available.
- Measure, don't eyeball: at each design frame width (and tablet, e.g. 768px), read `getBoundingClientRect()` and `getComputedStyle()` for the changed elements and compare with the design values. Screenshots miss few-pixel spacing errors and never show hover/focus, so also read the `:hover`/`:focus` rules or force the state in DevTools.
- Verify the component works in other render contexts (Layout Builder, Views, different view modes).

## Reference files (load on demand)

- [references/sdc.md](references/sdc.md): component structure, schema, slots, includes/embeds, auto-attached assets.
- [references/libraries-js.md](references/libraries-js.md): libraries.yml, attaching, behaviors/once, build pipeline.
- [references/twig-a11y.md](references/twig-a11y.md): Twig practices, preprocess/suggestions, images, accessibility, subsystem notes.
