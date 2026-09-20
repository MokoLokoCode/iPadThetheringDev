# Instructions for the implementing agent

## Reading order

Read, in this order, before changing anything: README.md → STATUS.md → ARCHITECTURE.md → DECISIONS.md → PROGRESS.md → VALIDATION.md.

## Engineering rules

- Work only on items listed in PROGRESS.md; reference the `W-NNN` ID in commits.
- Any design choice not already in DECISIONS.md gets a new `D-NNN` entry before code lands.
- Never delete or renumber IDs in DECISIONS.md or PROGRESS.md.
- Update STATUS.md at the end of every working session: what works, what's unverified, next action.
- Keep ARCHITECTURE.md truthful — if the code deviates, update the doc or record a Deviation in the decision.
- No new third-party dependencies without a decision entry.

## Scope boundaries

- Do not implement anything in README.md "Non-goals".
- Do not change the target camera/iPad from the equipment table without asking.
- Do not touch on-disk session format after M2 without a superseding decision.

## Validation requirements

- Every `W-NNN` marked Done must cite evidence: a VALIDATION.md procedure ID and observed result, or a test output.
- Hardware-dependent items are not Done until run on the real device listed in README.md.

## When to stop and ask

Stop and ask the owner before proceeding when:

- A decision in DECISIONS.md appears wrong or blocks the current item.
- A work item's acceptance criteria are ambiguous.
- A required hardware behavior can't be verified with available equipment.
- Anything would require touching the user's photos outside the app's session directory.
