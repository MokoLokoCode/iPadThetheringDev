# Pair programming git discipline

`main` is protected: no force-push, changes land only through pull requests.
Each of us works on a personal branch (`julian/*`, `<pair>/*`).

## Daily loop

1. Pull main
   ```
   git checkout main && git pull
   ```
2. Rebase personal branch onto main
   ```
   git checkout julian/dev && git rebase main
   ```
3. Force-push the personal branch (never main) with lease, so our independent
   changes always sit on top of the latest main and each of our individual
   histories stays linear
   ```
   git push --force-with-lease
   ```
4. Open a PR from the personal branch into main; merge when the other has looked at it.

## Rules

- Never force-push `main`.
- Never rebase or force-push someone else's branch.
- `--force-with-lease`, never bare `--force`.
- Commit messages reference the `W-NNN` work item when one exists.
