---
name: figma
description: Use the Figma MCP server to fetch design context, screenshots, variables, and assets from Figma, and to translate Figma nodes into production code. Trigger when a task involves Figma URLs, node IDs, design-to-code implementation, or Figma MCP setup and troubleshooting.
metadata:
  short-description: "Use Figma MCP for design-to-code work"
  author: OpenAI
  source: https://github.com/openai/skills/tree/main/skills/.curated/figma
---

# Figma MCP

Use the Figma MCP server for Figma-driven implementation. For setup and debugging details (env vars, config, verification), see `references/figma-mcp-config.md`.

## Figma MCP Integration Rules
These rules define how to translate Figma inputs into code for this project and must be followed for every Figma-driven change.

### Required flow (do not skip)
1. Run get_design_context first to fetch the structured representation for the exact node(s).
2. If the response is too large or truncated, run get_metadata to get the high-level node map and then re-fetch only the required node(s) with get_design_context.
3. Run get_screenshot for a visual reference of the node variant being implemented.
4. Only after you have both get_design_context and get_screenshot, download any assets needed and start implementation.
5. Extract a spec table from get_design_context (see "Exact measurements") before writing any code.
6. Translate the output (usually React + Tailwind) into this project's conventions, styles and framework (CSS, SCSS, Less, utility classes, etc.). Reuse the project's color tokens, components, and typography wherever possible.
7. Verify the built result against the spec table (see "Verification") before marking complete.

### Exact measurements
- The screenshot is for orientation only. Never take sizes, gaps or colours from it by eye.
- Read every value from the get_design_context output (and get_variable_defs for tokens): width, height, gap, padding, margin, border, radius, font family/size/weight/line-height/letter-spacing/case, colour, opacity, shadow, icon size, and layout direction/alignment.
- Record them as a table per element (element | property | Figma value | project token or raw value used). Include interactive and edge states (hover, focus, disabled, empty, error) and each breakpoint that has its own frame.
- Map each value to an existing project token when it is equal. When no token matches, use the raw value and flag it in the table. Do not round or "adjust minimally" without noting it.
- When a value is missing from the Figma data, say so and ask; do not guess.

### Verification
- Render the result at the design frame's width (and each other frame's width).
- Read the actual rendered values for the same elements (bounding box and computed styles in a browser, or the equivalent for the platform) and compare them with the spec table.
- Compare a screenshot of the result next to the Figma screenshot.
- Report every mismatch with the Figma value, the actual value and the reason. Fix all that are not deliberate; list the rest as deviations.

### Implementation rules
- Treat the Figma MCP output (React + Tailwind) as a representation of design and behavior, not as final code style.
- Replace Tailwind utility classes with the project's preferred utilities/design-system tokens when applicable.
- Reuse existing components (e.g., buttons, inputs, typography, icon wrappers) instead of duplicating functionality.
- Use the project's color system, typography scale, and spacing tokens consistently.
- Respect existing routing, state management, and data-fetch patterns already adopted in the repo.
- Strive for 1:1 visual parity with the Figma design. When conflicts arise, prefer design-system tokens and adjust spacing or sizes minimally to match visuals.
- Validate the final UI against the Figma screenshot for both look and behavior.

### Asset handling
- The Figma MCP Server provides an assets endpoint which can serve image and SVG assets.
- IMPORTANT: If the Figma MCP Server returns a localhost source for an image or an SVG, use that image or SVG source directly.
- IMPORTANT: DO NOT import/add new icon packages, all the assets should be in the Figma payload.
- IMPORTANT: do NOT use or create placeholders if a localhost source is provided.

### Link-based prompting
- The server is link-based: copy the Figma frame/layer link and give that URL to the MCP client when asking for implementation help.
- The client cannot browse the URL but extracts the node ID from the link; always ensure the link points to the exact node/variant you want.

## References
- `references/figma-mcp-config.md` — setup, verification, troubleshooting, and link-based usage reminders.
- `references/figma-tools-and-prompts.md` — tool catalog and prompt patterns for selecting frameworks/components and fetching metadata.
