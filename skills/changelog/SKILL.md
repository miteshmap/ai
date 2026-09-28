---
name: changelog
description: Maintain CHANGELOG.md at the project root, grouped by date. Bootstraps it from git history if missing, otherwise appends the current branch's unmerged commits under today's date. Manually invoked before merging. Trigger with /changelog, "update the changelog", or "log this branch's changes".
---

# Changelog

Keeps a single `CHANGELOG.md` at the project root, with one `##` heading per date and a bullet per commit under it, newest date first. This is invoked manually, once per branch, right before merging — it is not run automatically on every commit.

## Rules

1. **Read before writing.** If `CHANGELOG.md` exists, read the whole thing first so you know which dates/entries already exist and don't duplicate them.
2. **One bullet per commit, no rewriting the history.** Use the commit's subject line as the bullet (trimmed, not reworded into marketing copy). Exclude merge commits (`git log --no-merges`) — they're noise, not work.
3. **Group strictly by date, newest first.** Heading format: `## YYYY-MM-DD`. Within a date, list commits in the order they were made.
4. **Never duplicate an entry.** If a commit's subject already appears under its date, skip it. This matters on repeat invocations of this skill on the same branch (e.g. after adding a fixup commit).
5. **Don't touch unrelated sections.** Only add/update date headings relevant to the commits being logged. Leave the rest of the file exactly as it is.
6. **No fabricated summaries.** Don't invent a bullet for uncommitted working-tree changes — only committed commits get logged. If there's uncommitted work, tell the user to commit it first if they want it included.

## Process

### Step 1 — Determine mode

Check whether `CHANGELOG.md` exists at the repo root.

- **Missing → Bootstrap mode.**
- **Exists → Branch-log mode.**

### Step 2a — Bootstrap mode

1. Run `git log --no-merges --date=short --pretty=format:'%ad|%s'` over the whole repo history (or ask the user if they want it scoped to a shorter range, e.g. "since last tag" — only ask if the repo has a very long history and a full dump seems excessive).
2. Group commits by date, newest date first, each as `## YYYY-MM-DD` followed by one `- <subject>` bullet per commit for that date, in commit order.
3. Write the result as `CHANGELOG.md` with a top-level `# Changelog` heading.

### Step 2b — Branch-log mode

1. Identify the base branch (`main` or `master` — check which exists; ask if neither is obviously the base and the user hasn't said).
2. Run `git log --no-merges --date=short --pretty=format:'%ad|%s' <base>..HEAD` to get this branch's unmerged commits.
3. For each commit's date: if a `## YYYY-MM-DD` heading for that date already exists in `CHANGELOG.md`, append the bullet under it (skip if that exact subject is already there per Rule 4); if not, create a new heading in the correct newest-first position.
4. Write the updated `CHANGELOG.md`.

### Step 3 — Report

Tell the user which commits were added (or that there was nothing new to log), and which file/headings changed.

## File skeleton

```markdown
# Changelog

## 2026-09-27
- LSS-119: Update composer.json for normalise and add README file
- LSS-119: Update drupal core version to 10.6.17

## 2026-09-20
- LSS-116: upgrade honeypot module to latest version
```
