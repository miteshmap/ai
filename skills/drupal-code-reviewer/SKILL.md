---
name: drupal-code-reviewer
description: >-
  Independent, read-only review of Drupal code with a weighted 0-100 score and
  a merge verdict (PASS, PASS WITH FIXES, CHANGES REQUESTED, FAIL). Use to
  review or gate a custom module, diff, patch, branch or merge request before
  merging, especially code written earlier in the same session. Runs PHPCS,
  PHPStan and tests, then checks security, correctness, efficiency,
  complexity, duplication, tests and docs. Does not modify code.
---

# Drupal Code Reviewer

Find what is wrong with the code, grade it honestly, return a verdict the author can act on. Judge what the code does, not what the author intended.

## Rules

- **Read-only.** Never edit, stage, checkout or switch branches. Use `git diff`, `git show`, `git log` and file reads. To inspect another revision, use a separate temporary directory. Report each fix as a snippet in the review.
- **Do the review yourself.** Do not delegate parts of the diff to subagents. For a large diff, make multiple passes and say so.
- **Sub-skills report, they don't fix.** When `drupal-security-review` or `drupal-coding-standards` say to fix findings, record them in the report instead.

## Before you start

1. **Scope:** exact paths, diff range or patch. If none was given, ask. Do not default to the whole repo.
2. **Versions:** Drupal and PHP from `composer.json` / `core_version_requirement`. Deprecations depend on it. If unknown, assume Drupal 10.6+/11 and PHP 8.3 and state the assumption.
3. **Tooling first,** using the project's own commands (check `Makefile`, `composer.json`, `phpcs.xml.dist`, `phpstan.neon.dist`): PHPCS (`Drupal,DrupalPractice`), PHPStan, PHPUnit. Style and type noise should not use review attention. Report what ran and what didn't. A failing test suite is a Blocker. Never imply a tool passed when it was unavailable.
4. **Read the changed files and their callers.** A changed contract that breaks an untouched caller is a finding.

## Review passes

1. **Must invoke** `drupal-coding-standards` (Skill tool) for the changed PHP, YAML, Twig, JS and CSS files; take its findings as Minor/Nit unless they cause defects.
2. **Must invoke** `drupal-security-review` (Skill tool) for the changed scope; take its findings into the Security dimension.

Do not substitute your own reading for these two invocations. In "Tooling run" of the report, state that each was invoked. If one cannot be invoked (missing or errors), say so in the report and mark that area unreviewed instead of scoring it clean.
3. Work through the dimensions that apply to the input type in [references/checklist.md](references/checklist.md) (it includes the input-type table and per-dimension score anchors).
4. Check the change against [references/calibration.md](references/calibration.md): red flags, rationalizations, and what to do when the code under review was written in this session.

## Scoring

Score each dimension 0-10, then `Weighted = Score / 10 x Weight`. Total is out of 100.

| Dimension | Weight |
|---|---|
| Security | 25 |
| Coding errors | 20 |
| Efficiency | 15 |
| Simplify complex code | 12 |
| Duplicate code | 10 |
| Testing | 10 |
| Documentation | 8 |

**Any Blocker caps the total at 49 and forces FAIL.** A dimension with a Blocker scores 1-2; a change with no tests scores 0 in Testing. A dimension you did not review is listed as unreviewed, not scored clean.

| Verdict | Condition |
|---|---|
| PASS | Total >= 85, no Blocker or Major |
| PASS WITH FIXES | Total >= 70, no Blocker |
| CHANGES REQUESTED | Total 50-69, no Blocker |
| FAIL | Any Blocker, or total < 50 |

Severity: **Blocker** (vulnerability, data loss, failing tests, fatal error), **Major** (wrong behavior, broken caching/access, real duplication), **Minor**, **Nit**.

## Report

Use [references/report-template.md](references/report-template.md). Every finding has `file:line`, the problem, why it matters, and a concrete fix snippet. Empty sections say "None."; never omit them.

## Calibration

- No rubber-stamping: if you did not read it, do not approve it.
- Do not soften a real defect because the author explained intent.
- Do not inflate nits; one structural finding outweighs ten style nits.
- Lead with a genuine strength. Quantify impact where possible ("N+1: ~1 query per item").
- Surface conflicts between parts of the change instead of resolving them silently.
- A verdict is mandatory.

## Verify before concluding

Every Blocker is documented; every finding has `file:line`; the arithmetic matches the stated total; cited tool results actually ran; skipped dimensions are named.
