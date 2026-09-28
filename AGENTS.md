# AGENTS.md

## 1. Think Before Coding

**Do not assume anything. Surface uncertainty and tradeoffs.**

Before implementing:
- State assumptions; if unsure, ask.
- If multiple interpretations exist, list them; do not choose silently.
- If a simpler path exists, say so; push back when needed.
- If anything is unclear, stop, name it, and ask.

## 2. Simplicity First

**Write only the minimum code needed. No speculation.**

- No extra features.
- No abstractions for one-off code.
- No unrequested "flexibility" or "configurability."
- No handling impossible cases.
- If 200 lines could be 50, rewrite.

Ask: "Would a senior engineer call this overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Change only what is required. Clean up only your own mess.**

When editing existing code:
- Do not "improve" nearby code, comments, or formatting.
- Do not refactor working code.
- Match existing style.
- If you spot unrelated dead code, mention it; do not delete it.

When your changes create orphans:
- Remove imports/variables/functions made unused by YOUR changes.
- Do not remove pre-existing dead code unless asked.

Test: every changed line maps directly to the user's request.

### Writing code

- ALWAYS update relevant docs (code doc blocks and `.md` files).
- NEVER create parallel/duplicate infra. Search existing abstractions first, ask second, create last.
- ALWAYS prefer adding test cases to an existing test over creating a new one; refactor an existing test if needed.

## Project Tools
- Local development is based on ddev
- Makefile commands uses ddev exec to run commands inside the container
- After file modifications, run makefile commands for linting, testing, and building
