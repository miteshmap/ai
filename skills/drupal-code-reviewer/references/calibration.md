# Calibration: rationalizations and red flags

## Common rationalizations (the author's and your own)

| Rationalization | Reality |
|---|---|
| "It works, that's good enough." | Drupal's failure modes (cache metadata, access checks, escaping) work fine until they don't. |
| "The tests pass, so it's correct." | Tests don't check architecture, security or cache correctness. A green suite with no access-control test proves nothing about access control. |
| "It's only a small addition to this file." | Small diffs still tangle control flow and grow files past what anyone can hold in context. |
| "We'll clean it up later." | Require the cleanup now, or a filed issue with an owner. |
| "AI-generated code is probably fine." | Generated code needs more scrutiny: it is fluent and confident about APIs it invented. Verify every API it calls exists in the target version. |
| "The refactor makes it cleaner." | Relocating complexity is not reducing it. If the reader holds more concepts afterwards, it got worse. |
| "Security can review it later." | By then it's a release blocker. Access control and escaping are review-time checks. |
| "It's just a version bump." | A bump is behavior you did not write. Read the changelog. |

## Drupal red flags (look closer when you see one)

- `\Drupal::` static calls in a service class.
- `|raw` anywhere in Twig.
- A query built with string interpolation.
- A route without `requirements:`.
- A render array without `#cache`.
- `hook_cron` doing real work synchronously.
- A test that mocks the thing it is supposed to test.
- A `hook_update_N()` with no docblock and no idempotency guard.
- A permission reused from another module instead of defined locally.
- A file over ~1000 lines, or a class with more than one reason to change.
- Business logic in a Twig template instead of preprocess or a service.

## Honesty rules

- No rubber-stamping: "LGTM" without evidence is a failed review.
- Never soften a real defect because the author explained intent.
- Do not comment on code you did not read; say which parts were not reviewed.
- Do not inflate nits; one structural finding plus ten style nits means the structural finding is the review.
- Score honestly: a dimension with a Blocker scores 1-2; an untested module scores 0.
- A verdict is mandatory.

## Reviewing your own code

An author cannot review their own work objectively. If this session wrote the code under review, say so at the top of the report and recommend a fresh-context review (a new session or another reviewer) for a second opinion. Do not delegate to a subagent that inherits this context.
