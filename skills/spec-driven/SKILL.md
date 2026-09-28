---
name: spec-driven
description: Initialize the project "constitution" for spec-driven development — mission.md, tech-stack.md, and roadmap.md in a specs/ directory. Trigger with /spec-driven, "init constitution", "set up spec-driven development", or "initialize the spec directory".
---

# Spec-Driven Development — Constitution Init

Establishes the foundational spec documents a project works from before any feature-level spec is written:

- `specs/mission.md` — what the product is, who it's for, why it exists
- `specs/tech-stack.md` — the stack and conventions the project commits to
- `specs/roadmap.md` — high-level implementation order, broken into small phases

This skill only initializes or updates these three files. It does not write feature specs, plans, or tasks — that's a separate, later skill/workflow.

## Rules

1. **Never write to disk before all three Q&A rounds are complete.** Ask first, in three separate `AskUserQuestion` rounds — one per document (Mission, then Tech Stack, then Roadmap) — and only create/update files after the user has answered all three.
2. **Don't assume — but don't ask what's already obvious from the repo either.** Before asking, inspect the repo (`composer.json`, `package.json`, `AGENTS.md`/`CLAUDE.md`, existing `README.md`, lockfiles, `Makefile`, CI config) for facts you can pre-fill. Present detected facts as a default option in the relevant question rather than silently assuming them, so the user can correct you.
3. **If `specs/mission.md`, `specs/tech-stack.md`, or `specs/roadmap.md` already exist**, read them first and tell the user what's already there before asking anything. Ask (as a normal question, not necessarily via the Q&A tool) whether to keep, revise, or fully redo each file — don't overwrite silently.
4. **Roadmap phases must be small.** Each phase should be shippable and independently verifiable — not "Phase 1: Backend" but something like "Phase 1: User can log in with email/password." Push back if the user proposes large, vague phases.
5. **No speculative content.** Only include what the user confirmed or what you detected and they accepted. Leave genuinely unknown items as an explicit "Open questions" line in the relevant file rather than inventing an answer.

## Process

### Step 0 — Recon

Check for an existing `specs/` directory and read any of the three files that already exist. Skim the repo root for stack signals (`composer.json`, `package.json`, `requirements.txt`, `Makefile`, `.ddev/`, CI configs, `AGENTS.md`/`CLAUDE.md`) to form draft defaults — do not present these as final, only as pre-filled options in Step 1–3 questions.

### Step 1 — Mission Q&A (`AskUserQuestion`, header group "Mission")

Ask what's needed to write `specs/mission.md`. Cover, in as few questions as possible (merge where sensible, max 4 per call):

- What is this product/project, in one line, and what problem does it solve?
- Who is it for (primary users/personas)?
- What makes it different from doing nothing or from the obvious alternative?
- What is explicitly out of scope / a non-goal right now?

### Step 2 — Tech Stack Q&A (`AskUserQuestion`, header group "Tech Stack")

Ask what's needed to write `specs/tech-stack.md`, presenting anything detected in Step 0 as a default/first option rather than asking blind:

- Core language(s)/framework(s) and version constraints (confirm detected values).
- Data storage (DB, cache, search, file storage) if relevant.
- Local dev / deployment tooling (confirm detected, e.g. ddev, Docker, CI provider).
- Notable conventions or constraints the team already committed to (coding standards, package manager, hosting).

### Step 3 — Roadmap Q&A (`AskUserQuestion`, header group "Roadmap")

Ask what's needed to write `specs/roadmap.md`:

- What is the very first phase — the smallest thing that proves the mission works end-to-end?
- What's the intended phase order after that (list 3-6 phases)?
- Is there a phase already in progress or done? Which one?
- Any hard external constraints on ordering (dependency, deadline, compliance gate)?

Push back on any phase that isn't small/shippable per Rule 4, and re-ask that part before moving on.

### Step 4 — Write

Only after all three rounds are answered:

1. Create `specs/` if it doesn't exist.
2. Write `specs/mission.md`, `specs/tech-stack.md`, `specs/roadmap.md` using only confirmed answers. Use plain, direct prose/lists — no filler sections the user didn't ask for.
3. For `roadmap.md`, structure as an ordered list of small phases, each with a one-line description of the shippable outcome and its status (done / in progress / not started).
4. Report back a short summary of what was written and where, and name any open questions you deliberately left unanswered.

## File skeletons

`specs/mission.md`:
```markdown
# Mission

## Problem
...

## Who it's for
...

## Why this, not the alternative
...

## Non-goals
...
```

`specs/tech-stack.md`:
```markdown
# Tech Stack

## Language / Framework
...

## Data
...

## Tooling / Deployment
...

## Conventions
...
```

`specs/roadmap.md`:
```markdown
# Roadmap

Small, shippable phases in implementation order.

1. **Phase 1 — <name>** (status: done/in progress/not started)
   <one-line outcome>
2. **Phase 2 — <name>** (status: ...)
   <one-line outcome>
...
```
