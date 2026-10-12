# Report template

```markdown
## Drupal Code Review: <target>

**Scope:** <paths / diff range> · **Drupal:** <version> · **PHP:** <version> (assumed? say so)
**Tooling run:** PHPCS <result> · PHPStan <result> · PHPUnit <result> (state "not run: reason" where applicable)
**Skills invoked:** drupal-coding-standards <invoked | unavailable: reason> · drupal-security-review <invoked | unavailable: reason>

### Score
| Dimension | Weight | Score | Weighted | Summary |
|---|---|---|---|---|
| Security | 25 | | | |
| Coding errors | 20 | | | |
| Efficiency | 15 | | | |
| Simplify complex code | 12 | | | |
| Duplicate code | 10 | | | |
| Testing | 10 | | | |
| Documentation | 8 | | | |
| **Total** | **100** | | **<n>** | |

### Verdict: <PASS | PASS WITH FIXES | CHANGES REQUESTED | FAIL> — <n>/100
<One or two sentences: the reason, and the cap if a Blocker applied.>

### Findings
#### Blocker
None.
#### Major
#### Minor
#### Nit

Finding format:
- **`path/to/file.php:42`** Problem in one sentence.
  *Why it matters:* impact (quantified where possible).
  *Fix:*
  ```php
  // concrete snippet
  ```

### Confirmed good practices
### Verification story
What was read, what ran, which dimensions were passed over (unreviewed, not clean).
### Recommended next steps
```
