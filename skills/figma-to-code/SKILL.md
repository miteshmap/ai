---
name: figma-to-code
description: This skill should be used when a task includes a Figma URL or node ID, or asks to "implement this Figma design", "convert this Figma section into a component", "match the design", or "get tokens/assets from Figma". Defines the workflow for calling the Figma MCP tools (design context, variables, assets, screenshots) before writing markup or styles.
---

# Figma to Code

Use the Figma MCP tools before writing any markup or styles. Framework-specific implementation (Twig, React, etc.) and project conventions come from the project's instructions and other skills.

## Prerequisites

- The Figma MCP tools may be deferred. Use tool search to load them (`get_design_context`, `get_variable_defs`, `download_assets`, `get_screenshot`) before calling.
- A URL must include a `node-id`. If it does not, ask the user for one. Never guess.
- Extract `fileKey` and `nodeId` from the URL (`?node-id=1-2` means nodeId `1:2`).

## Workflow

1. **Structure and layout:** call `get_design_context`. Treat the output as a reference for structure, spacing and hierarchy, not as code to paste. Re-implement it in the project's stack and conventions.
2. **Tokens:** call `get_variable_defs`. Map every colour, font, spacing and radius to the project's existing design tokens or SCSS/CSS variables. Never hardcode values. If nothing matches, report it rather than inventing a token.
3. **Assets:** call `download_assets` for every icon and image. Never hand-write or recreate SVGs from memory. Place them in the project's asset location.
4. **Verify:** call `get_screenshot` for the node and compare it with the rendered result (desktop and mobile where the design provides both). Fix visible differences before finishing.

## Rules

- Do not start coding until steps 1-3 are done.
- Prefer existing components over new ones; check for matches first.
- Flag design gaps (missing states, breakpoints, unclear tokens) to the user instead of assuming.
- For large frames, fetch child nodes separately rather than one huge request.
