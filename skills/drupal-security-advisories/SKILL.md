---
name: drupal-security-advisories
description: Check drupal.org security announcements (core SA-CORE, contrib SA-CONTRIB, PSA) for a date or window against the project's composer.json/composer.lock and report what applies, verdict first. Use when the user asks to check for Drupal security releases, advisories or updates, or runs /drupal-security-advisories. Read-only unless the user explicitly says to apply updates.
compatibility: Requires web access to drupal.org, jq, and a Drupal project with composer.json and composer.lock. Updates need ddev.
allowed-tools: Bash Read Grep WebFetch
---

# Drupal security advisories

Check Drupal security announcements against this project. Input:

- **window**: a single date (e.g. `2026-10-07`), a range, or a number of days. Default: the last 30 days up to today. Always cover recent releases, not just today's, so nothing is missed between scans.
- **scans**: any of `core`, `contrib`, `psa`. Default all three. Run each independently.
- **apply** (optional): update affected packages. Without it, never modify files.

## 1. Prep (before reading any feed)

Run from the project root:

- Direct requirements: `jq -r '(.require + ."require-dev") | to_entries[] | "\(.key) \(.value)"' composer.json`
- Locked versions: `jq -r '.packages[] | "\(.name) \(.version)"' composer.lock`

## 2. Scans

**core** — https://www.drupal.org/security/core
1. List every SA-CORE entry in the window (ID, date, risk, type). Follow `?page=1` and onward until past the window start.
2. Fetch each advisory for affected and fixed versions. Include bundled fixes (Symfony, Twig, etc.) when the advisory names them.
3. Compare to the locked `drupal/core` and `drupal/core-recommended`, plus `drupal/core-composer-scaffold` and `drupal/core-project-message` (pinned to the same version). Core is pinned exactly in `composer.json`, so updating means changing those constraints. Report the required version; edit only with `apply`.

**contrib** — https://www.drupal.org/security/contrib
1. List every SA-CONTRIB entry in the window (ID, date, machine name, risk, type). Paginate as above.
2. Match machine names against `drupal/<name>` in the prep output.
3. For each match, fetch `https://www.drupal.org/sa-contrib-<year>-<number>` for affected versions, fixed version, risk and exploit prerequisites. Compare to the locked version.

**psa** — https://www.drupal.org/security/psa
1. List every PSA in the window (ID, date, title, summary). There is no fixed version, so judge relevance.
2. Fetch each and say whether it concerns core, a module or library in the lockfile, or the PHP/hosting stack. Flag required actions and deadlines.

## 3. Compare before reporting

Check every advisory in the window against the locked versions before writing any output. Classify each:

- 🔴 affected: locked version is inside the affected range
- 🟢 fixed: locked version is at or above the fixed release
- 🟡 needs manual check: for example an advisory page could not be fetched
- ⚪ not installed

Do not skip older advisories because a newer one was fine. Never mark 🟢 or ⚪ without having compared it.

## 4. Report

Output is rendered as markdown, so use emoji, bold and tables (no ANSI codes). Lead with the verdict. Use exactly this structure:

**Risk colours:** 🟥 Highly critical / Critical, 🟧 Moderately critical, 🟨 Less critical, ⬜ Not critical.

1. **Verdict heading** (H1), the first line:
   - `# 🔴 Action needed` if anything is 🔴 (say how many)
   - `# 🟡 Manual check needed` if nothing is 🔴 but something is 🟡
   - `# ✅ No action needed` otherwise

   Then an italic line with the window and whether anything was modified, e.g. `*Scan window: 2026-09-07 → 2026-10-07. Nothing was modified.*`
2. **Summary table**, one row per scan run: `| Scan | Advisories | 🔴 Affected | 🟢 Already fixed | ⚪ Not installed |`. Add a 🟡 column only if needed.
3. **Matching advisories** (H2 prefixed with the worst status, e.g. `## 🔴 Affected` or `## 🟢 Advisories that match our project (all already fixed)`): one table across all scans, only advisories matching our lockfile: `| ID | Package | We have | Fixed in | Risk | Issue |`. 🔴 rows first with the ID in bold. Keep cells to a few words; put exploit prerequisites below the table, only for 🔴/🟡 rows. If none match, write `🟢 Nothing applies`.
4. **⚪ Ignored** (H2), short bullets: count of advisories for modules we do not have (do not list them), PSAs that do not apply with a one-line reason, and near-name matches ruled out (e.g. `inline_entity_form` vs Inline Entity Form Dialog).
5. **📝 Optional follow-up** (H2), only if concrete, e.g. `drush updb` for update hooks. For 🔴 items use `## 🔴 Required actions` with the exact fix version and command.

Do not print a per-advisory table of everything in the window unless asked.

## 5. Applying updates (only with `apply`)

- Use ddev only; never run composer or php on the host. Prefer Makefile targets when one exists.
- Update only affected packages, without `--with-dependencies`: `ddev composer update drupal/<a> drupal/<b>`. If the fix is outside the `composer.json` constraint, stop and report, except for core, where the exact-pin constraints must change: show the intended edit and make it only because `apply` was given.
- Verify with `git diff composer.lock` and report any package other than the targets that changed.
- Run `ddev drush updb -y && ddev drush cr`. If drush cannot bootstrap (empty local DB, "key_value table not found"), do not retry; report that DB updates still need to run against a real DB.
- Do not commit unless asked. Call out modules whose update hooks matter (e.g. `menu_link_attributes` 1.8.0 cleans unsafe config).
