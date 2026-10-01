---
name: flowchart
description: Build a multi-lane SVG flowchart (e.g. browser/backend/third-party request flows) as a standalone local HTML file — no Artifact publish required. Use when the user asks for a "flow chart", "flowchart", or "request flow diagram" for a route, controller, or user journey, especially when they want it saved locally instead of published.
---

Build a self-contained HTML file with an inline hand-authored SVG flowchart, saved to disk. This does not use the Artifact tool — the output is a plain file the user opens directly in a browser (`open path/to/file.html`) or views via Read/a local server. Only publish as an Artifact if the user explicitly asks for a shareable link.

## When to use this vs. Artifact + artifact-diagramming

- User says "save it locally", "don't publish", "no artifact URL", or the repo already has a `docs/` convention for this → use this skill, write a plain file.
- User wants something shareable/private-hosted with a link → still build the SVG the way this skill describes, but pass the file to the `Artifact` tool instead of just `Write`-ing it (load `artifact-design`/`artifact-diagramming` first in that case).

## Step 1 — trace the mechanism before drawing

Do not diagram from memory or guesswork. Read the actual route/controller/JS involved (grep the module's `*.routing.yml`, read the controller method(s), read the client-side JS or Drupal behaviors/libraries driving any AJAX calls). Identify:

- The lanes: usually **Browser**, the app's own **backend controller**, and any **external service** (a third-party API, payment gateway, etc.) — drop a lane that doesn't do anything.
- The sequence of steps top-to-bottom.
- Every branch point (access check, validation, success/failure) and what happens on each side.
- Which branches are dead ends (redirect/error and nothing continues) vs. which merge back into the main flow.

Prefer delegating this trace to an Explore/general-purpose agent in the foreground when the controller is large (several hundred+ lines) — get back a structured, factual description (route paths, method names, branch conditions, external API calls) before writing any SVG.

## Step 2 — match complexity to the journey

A 5-step controller gets one clean top-to-bottom column. A large multi-phase journey (e.g. a multi-page checkout flow) should be **linearized, not branched into parallel sub-columns** — sub-columns invite crossing arrows and are hard to keep aligned. Use this decision rule:

- Every diamond has at most one "continue" edge, which always goes straight down the main column.
- Every other edge from a diamond goes **right**, to a **self-contained, dead-end box** that states the outcome in its own text (e.g. "redirect → error page — no further calls"). Do not draw an arrow from that box back into the main column, even if the real code eventually converges — describe the convergence in the box's text instead ("same as main path").
- If a sub-flow genuinely needs multiple steps of its own (e.g. a multi-step sub-process), draw it as its own short vertical mini-chain in that same right-hand zone, ending in its own terminal box. Don't merge it back visually.
- For journeys with distinct phases (e.g. "page load", "form build", "submit"), add lightweight divider rules with a small caption between phases rather than more lanes or columns.
- Collapse steps with no real mechanism (pure client-side form fields, no backend call) into one descriptive box instead of one box per field/step.

## Step 3 — layout mechanics (avoids the alignment bugs that show up otherwise)

These are lessons from diagrams that had to be fixed after the fact — apply them up front:

- **Never place two arrows on the same or near-same y-coordinate between two boxes.** A request arrow and its response arrow between two boxes at the same row need at least ~20px of vertical separation, and both must be strictly horizontal (same y at both ends) — a diagonal "shortcut" between mismatched y's reads as sloppy alignment.
- **Anchor every label to its arrow, not to the page edge.** A label for a vertical arrow goes just to the right of the line (`x = line_x + 10`), never left-aligned near `x=0`/the lane's left edge — it'll look disconnected from what it's labeling.
- Keep one consistent diamond size and one consistent box height per "kind" of node (e.g. all decision diamonds ~70px tall with points at `center_y ± 35`; all single-line boxes ~46-52px; two/three-line boxes 52-70px) so rows visually rhyme down the column.
- Space rows with a consistent rhythm: ~34-40px of arrow between a box's bottom edge and the next node's top edge.
- Lane columns (reuse across diagrams for consistency): Browser `x=70` width `160`; divider; main backend column centered around `x=510` width `~240`; a right-hand "outcome" zone starting around `x=810` width `220-300` for both redirect/error dead-ends AND external-service round-trips (differentiate by fill color, not x-position — this matches how the reference diagrams below do it); divider; external-service lane further right.

## Step 4 — visual system (reuse verbatim for consistency across diagrams)

Use inline `<svg viewBox="0 0 W H">` with `currentColor` strokes/text so it themes correctly, per the `artifact-diagramming` mechanics (arrowhead via `<marker>`, `role="img"` + `aria-label` on the `<svg>`, wrapped in `<figure>`/`<figcaption>`). Even for a locally-saved file (not going through the Artifact tool), still support both light and dark `prefers-color-scheme` — the user may open it in either.

Reuse this token set and figure chrome (drawn from prior diagrams in this codebase) so multiple flowcharts in the same repo look like one family:

```css
:root {
  --bg: #f6f5f2; --surface: #ffffff; --border: #dcd8d0;
  --ink: #23211d; --ink-soft: #625d54; --ink-faint: #928c81;
  --accent: #1f5f5b; --accent-soft: #e4efee; --accent-line: #1f5f5b;
  --warn: #9a5b1f; --warn-soft: #f6ead9; --warn-line: #b5742c;
  --error: #a13a3a; --error-soft: #f8e6e2; --error-line: #a13a3a;
  --code-bg: #efece5;
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: #17181a; --surface: #1f2123; --border: #33352f;
    --ink: #ece9e2; --ink-soft: #b1ab9f; --ink-faint: #7c766a;
    --accent: #6fc3bc; --accent-soft: #22302e; --accent-line: #6fc3bc;
    --warn: #e0a862; --warn-soft: #332a1c; --warn-line: #e0a862;
    --error: #e08282; --error-soft: #362221; --error-line: #e08282;
    --code-bg: #26282a;
  }
}
:root[data-theme="dark"] { /* same values as the dark media block */ }
```

Color meaning (keep consistent): plain outline box = neutral logic step; `--accent-soft` fill = external-service round trip or a success/no-further-action outcome; `--warn-soft` fill = redirect or a destructive/no-call outcome; `--error-soft` fill = hard failure/terminal error. Put a small legend under the figure listing these.

Page chrome around the SVG: an eyebrow (module/controller name), h1, a monospace "route" pill showing the entry route, a one-sentence lede, the diagram in a bordered card with a caption, then a short "Worth knowing" section — 3-4 cards, each one non-obvious mechanism a reader would otherwise have to reconstruct from the code (a shared/reused sub-routine, an ordering hazard, a re-check that's conspicuously absent, an idempotency mechanism). Skip generic restated-obvious observations.

## Step 4c — Field Mappings and API Endpoints sections (standard, include by default)

Every flowchart gets two reference sections after "Flow" and before "Worth knowing," rendered as tables (not more diagram) — the diagram shows control flow, these two show the data:

**API Endpoints** — every distinct network call touched anywhere in the journey, grouped into two separate tables (own `<table>`, own `colspan` header row): one for the Drupal site's own browser-facing routes (from `*.routing.yml`), one for every downstream external-service call (named after the service). Never merge them into one undifferentiated list — the whole point is a reader can see at a glance which calls are internal vs. leave the system. Each row: HTTP method, exact path/pattern (as called in code, including query-string shape like `?_pl=...` where relevant), which controller method or client-side call site triggers it, a **Fields sent** column, and a one-clause purpose.

Trace external calls to their real endpoint by reading the Drupal service/helper class the controller calls into (injected services, `\Drupal::service()`, `\Drupal::httpClient()`), not just the controller's method name — grep for the HTTP client calls (`->request(`, `->get(`, `->post(`) and read the literal URL and payload. Don't guess field lists from what "seems plausible".

For the **Fields sent** column: if the endpoint's payload is already fully documented in a Field Mappings table above, don't duplicate it — write `see Field mappings above`. Otherwise list the actual fields/params inline: query `SELECT`/field lists (abbreviate long ones after ~6 with `&hellip; (N total)` rather than dumping every field), query-string param names, or a small PATCH/POST body's field names. If a route decodes a base64 JSON blob (`?d=...`, `?_pl=...`), name the parameter and list what's inside it. Write `none` (not a blank cell) when a call genuinely sends no fields (e.g. a GET with the identifier in the path).

**Field Mappings** — for every payload the journey sends to the external service, a source-field -> external-field table: what the value is read from (a Form API field, a Drupal entity field, config, a hardcoded constant) and the exact target field name it's written to, including any transform applied in between (e.g. a ternary, a hardcoded literal, a computed/concatenated value). Group into one table per distinct payload shape (e.g. one for a create call, one for an update call) rather than one giant table — if two call sites build near-identical payloads, one table is fine with a note on where they diverge rather than duplicating the whole table twice.

Style: reuse the same `--surface`/`--border`/`--code-bg` tokens for a plain bordered table (header row in `--ink-faint` uppercase, monospace for field/endpoint names, alternating nothing fancy — no zebra striping). An HTTP method reads well as a small monospace pill using the same treatment as the route pill in the page header.

## Step 4b — use HTML entities, not raw Unicode symbols

Write `&rarr;`, `&mdash;`, `&ndash;`, `&middot;`, `&hellip;`, `&ge;`, `&ne;`, etc. instead of typing the literal characters (`→`, `—`, `–`, `·`, `…`, `≥`, `≠`) directly into the HTML/SVG source. This applies everywhere in the file — page chrome (`<title>`, `<h1>`, eyebrow, lede, route pill, "Worth knowing" notes, footer) just as much as the `<svg>` `<text>` elements. The page chrome is easy to miss because it reads as "just prose," but the rule has no exceptions: nothing outside the ASCII range gets typed literally anywhere in the file.

**Before treating the file as done, verify it, don't just trust the writing pass** — search the finished file for any character outside the ASCII range (e.g. `grep -oP '[^\x00-\x7F]'` won't catch multi-byte runs reliably; use a small script/one-liner that iterates codepoints, such as `python3 -c "print(set(c for c in open('f.html', encoding='utf-8').read() if ord(c) > 127))"`). If that returns anything, replace it with its entity and re-check — do not assume the writing pass already caught every instance, especially on prose text written outside the SVG block.

## Step 5 — where to save

Default: `docs/flowcharts/<slug>-flow.html` in the current repo (create the directory if it doesn't exist). If the repo has its own doc convention, follow that instead. Tell the user the path at the end, and mention they can open it directly (`open docs/flowcharts/foo-flow.html` on macOS) — no server or publish step needed.

Do not call the `Artifact` tool for this path. Only reach for `Artifact` (and then load `artifact-design` + `artifact-diagramming` first) if the user asks for something shareable/hosted instead of a local file.
