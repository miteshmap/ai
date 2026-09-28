---
name: jira-brief
description: Generates a concise Jira ticket summary for the changes in the current branch, ready to paste as a PR review comment. Use this when the user asks for a jira brief, jira summary, or PR comment summary.
---

When this skill is invoked, automatically do the following without asking for input:

1. Run `git rev-parse --abbrev-ref HEAD` to get the current branch name.
2. Determine base branch:
   - First try `origin/main`
   - Fall back to `origin/master` if `main` does not exist or returns no diff range
3. Run `git log --first-parent --oneline --no-merges <base>..HEAD` to list commits authored on the branch path (excluding merge commits).
4. Run `git diff <base>...HEAD --name-only` to list changed files from the branch tip against merge-base (tree diff, not merge-commit history).
5. Run a focused diff for source files only:
   - `git diff <base>...HEAD -- '*.php' '*.js' '*.ts' '*.twig' '*.yml' '*.yaml'`
   - Exclude generated/compiled files from analysis (`dist/`, `build/`, `*.min.*`, lock files) even if they appear in changed files.
6. If the focused diff is too large, run additional **read-only** helper commands to summarize accurately (for example `git diff --stat`, `git diff --name-status`, `git diff <base>...HEAD -- <specific file>`, `rg` on diff output). Do not ask the user for permission for these helper commands.
7. Output a short Jira ticket comment as raw markdown source, wrapped in a fenced code block (using a ```markdown fence) so the literal syntax (`**`, `-`, etc.) is preserved and copy-pasteable as-is, in exactly this format inside the fence:

---

**Branch:** `<branch-name>`

**Summary:**
One or two sentences describing what this change does and why.

**Changes:**
- Bullet points covering the key technical changes (what files/logic changed and the effect)

**Testing / Acceptance Criteria:**
- Bullet points describing how to verify the change works correctly

---

Keep the output tight — this is a PR comment, not a full spec. No preamble, no explanation outside the code fence, just the fenced brief.

Quality bar:
- Prioritize business-impacting changes over mechanical refactors.
- Mention backend payload/API/data-shape changes explicitly when present.
- Mention user-visible behavior and validation changes explicitly when present.
- Keep bullets specific to changed logic; avoid generic wording.
