---
name: feature-work
description: Articulate and define a single feature within spec-driven development — plan.md, requirements.md, and validation.md in a dated feature directory under specs/. Trigger with /feature-work, "init feature", "start a feature work", or "initialize the feature development".
---

# Spec-Driven Development — Feature Work

Defines a single unit of feature work as its own spec, downstream of the project constitution (`specs/mission.md`, `specs/tech-stack.md`, `specs/roadmap.md` — see the `spec-driven` skill). This skill does not implement the feature; it only produces the spec the implementation will follow.

Creates `specs/MM-DD-YYYY-feature-name/` containing:

- `requirements.md` — scope, decisions, and context
- `plan.md` — a series of numbered task groups
- `validation.md` — how to know the implementation succeeded and can be merged

## Rules

1. **Never write to disk before all three Q&A rounds are complete.** Ask first, in three separate `AskUserQuestion` rounds — one per document (Requirements, then Plan, then Validation) — and only create files after the user has answered all three.
2. **Ground everything in the constitution and prior feature work.** Before asking anything, read `specs/mission.md` and `specs/tech-stack.md` if they exist, plus the existing feature specs under `specs/` (other `MM-DD-YYYY-feature-name/` directories). Use them to sanity-check scope (does this feature serve the mission?), constraints (does the plan fit the committed stack?), and consistency/overlap with what's already been specced or built. If mission/tech-stack don't exist yet, tell the user and ask whether to proceed anyway or run `spec-driven` first.
3. **Don't assume — surface tradeoffs.** If the user's ask has multiple reasonable interpretations, list them in the question rather than picking one silently. If something is genuinely out of scope for this feature, name it as a non-goal rather than quietly dropping it.
4. **Task groups must be small and numbered.** Each group in `plan.md` should be independently reviewable — not "1. Build the feature" but discrete, ordered steps a reviewer could check off one at a time. Push back on task groups that are too large or vague.
5. **Validation must be concrete and checkable.** Every item in `validation.md` should be something you can actually verify (a test, a manual check, a specific behavior) — not "make sure it works."
6. **No speculative content.** Only include what the user confirmed. Leave genuinely unresolved items as an explicit "Open questions" line rather than inventing an answer.

## Process

### Step 0 — Recon

Read `specs/mission.md` and `specs/tech-stack.md` if present, to ground the feature in existing context and constraints. Read the existing feature specs under `specs/` (other `MM-DD-YYYY-feature-name/requirements.md` and `plan.md` files) for guidance — naming/structure conventions already in use, decisions already made elsewhere that this feature should stay consistent with, and any overlap or naming collisions with in-flight or completed work.

### Step 1 — Requirements Q&A (`AskUserQuestion`, header group "Requirements")

Ask what's needed to write `requirements.md`:

- What is the feature, in one line, and what problem does it solve for the user?
- What's in scope for this feature specifically, and what's explicitly out of scope (non-goals)?
- Any decisions already made (approach, library, data model) that should be locked in rather than re-litigated during implementation?
- Any relevant context (dependencies on other features, constraints from mission/tech-stack, prior discussion) the implementer needs?

### Step 2 — Plan Q&A (`AskUserQuestion`, header group "Plan")

Ask what's needed to write `plan.md`:

- What's the natural breakdown into task groups (propose one based on requirements + tech-stack, and confirm/adjust with the user)?
- What order do the groups need to happen in — any hard dependencies?
- Is there a task group already done or in progress?

Push back per Rule 4 on any group that isn't independently reviewable, and re-ask before moving on.

### Step 3 — Validation Q&A (`AskUserQuestion`, header group "Validation")

Ask what's needed to write `validation.md`:

- What automated checks must pass (existing test suite, new tests, linting/type checks)?
- What manual checks are needed, if any (UI walkthrough, specific edge case, data check)?
- What's the merge bar — who/what needs to sign off before this is considered done?

### Step 4 — Write

Only after all three rounds are answered:

1. Determine today's date and a short kebab-case feature name; create `specs/MM-DD-YYYY-feature-name/`.
2. Write `requirements.md`, `plan.md`, `validation.md` using only confirmed answers. Plain, direct prose/lists — no filler sections the user didn't ask for.
3. Report back the directory created, a one-line summary of each file, and any open questions deliberately left unresolved.

## File skeletons

`requirements.md`:
```markdown
# Requirements — <feature name>

## Problem
...

## Scope
...

## Non-goals
...

## Decisions
...

## Context
...
```

`plan.md`:
```markdown
# Plan — <feature name>

1. **<task group>** (status: not started)
   - ...
2. **<task group>** (status: not started)
   - ...
```

`validation.md`:
```markdown
# Validation — <feature name>

## Automated checks
- [ ] ...

## Manual checks
- [ ] ...

## Merge bar
...
```
