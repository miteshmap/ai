# Single Directory Components (SDC)

Stable in Drupal 10.3+ (core module `sdc`). Components live in `components/<name>/` in a theme or module; the directory name, YAML name and Twig name must match.

```
components/card/
  card.component.yml
  card.twig
  card.scss      -> compiled to card.css (auto-attached)
  card.js        (auto-attached, optional)
  README.md      (optional usage notes)
```

## `card.component.yml`

```yaml
$schema: https://git.drupalcode.org/project/drupal/-/raw/HEAD/core/assets/schemas/v1/metadata.schema.json
name: Card
status: stable
description: Image, title, text and optional call to action.
props:
  type: object
  required: [title]
  properties:
    title:
      type: string
      title: Title
    heading_level:
      type: string
      title: Heading level
      enum: [h2, h3, h4]
      default: h3
    image_url:
      type: string
      title: Image URL
slots:
  body:
    title: Body
  cta:
    title: Call to action
```

- Props are scalars/arrays validated by JSON Schema; render arrays and markup go in **slots**.
- `required` only what the template cannot work without. Use `enum`/`default` to constrain variants.
- Use `libraryOverrides` for extra dependencies (e.g. `dependencies: [core/once]`) or to attach additional files.

## `card.twig`

```twig
{% set attributes = attributes.addClass('card') %}
<article {{ attributes }}>
  {% if image_url %}
    <img class="card__image" src="{{ image_url }}" alt="" loading="lazy">
  {% endif %}
  <div class="card__content">
    <{{ heading_level|default('h3') }} class="card__title">{{ title }}</{{ heading_level|default('h3') }}>
    {% block body %}{{ body }}{% endblock %}
    {% if cta %}<div class="card__cta">{{ cta }}</div>{% endif %}
  </div>
</article>
```

`attributes` is available automatically. Decorative images get `alt=""`; meaningful images need real alt text passed as a prop.

## Using a component

```twig
{# Simple, props and slots by name #}
{{ include('my_theme:card', { title: label, image_url: url }, with_context = false) }}

{# Slots with markup via embed #}
{% embed 'my_theme:card' with { title: label } only %}
  {% block body %}{{ content.body }}{% endblock %}
  {% block cta %}<a href="{{ url }}">{{ 'Read more'|t }}</a>{% endblock %}
{% endembed %}
```

Namespace is `<theme_or_module_machine_name>:<component>`. Always use `only`/`with_context = false` so context does not leak in.

## Rules

- One component = one responsibility. Compose bigger pieces from smaller components with `include`/`embed`.
- Style with BEM scoped to the component; no global selectors in component CSS.
- Component CSS/JS with the same base name is attached automatically when the component renders; do not also add it to `libraries.yml`.
- Keep variants as props (`enum`), not as separate near-duplicate components.
- Add the component's accepted props/slots to `README.md` if the project documents components.
- Validate in dev: invalid props throw, which catches schema drift early. Check that cache metadata of slot content still bubbles (pass render arrays, not rendered strings).
