# Pair programming git discipline

`main` is protected: no force-push, changes land only through pull requests.
Each dev works on a personal branch namespaced to its owner, `<owner>/<topic>`.

## Daily loop

1. Pull main
   ```
   git checkout main && git pull
   ```
2. Rebase personal branch onto main
   ```
   git checkout <your-branch> && git rebase main
   ```
3. Force-push the personal branch (never main) with lease, so our independent
   changes always sit on top of the latest main and each of our individual
   histories stays linear
   ```
   git push --force-with-lease
   ```
4. Open a PR from the personal branch into main; merge when the other has looked at it.

## Optional local guard

Git never commits `.git/hooks`, so a shared hook needs a committed directory and one
command per clone. This is opt-in — skip it and nothing changes:

```
git config core.hooksPath .github/hooks
```

`.github/hooks/pre-commit` then refuses a commit while `main` is checked out, which is
the first rule below. It is a reminder, not an authority: `git commit --no-verify` and
`ALLOW_MAIN_COMMIT=1` both get past it, and it runs only for whoever ran the config
line. Anything that must hold for everyone belongs in branch protection or CI.

## Rules

- Never force-push `main`.
- Never rebase or force-push someone else's branch.
- `--force-with-lease`, never bare `--force`.
- Commit messages reference the `W-NNN` work item when one exists.
