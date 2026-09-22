# Pair programming git discipline

`main` is protected: no force-push, changes land only through pull requests.
Each dev works on a personal branch namespaced to its owner, `<owner>/<topic>`.

This is enforced by the repository ruleset **Protect Main**, not by convention. It
targets `refs/heads/main` with no bypass actors — the owner included — and blocks
deletion and non-fast-forward pushes. A pull request needs one approving review, with
review threads resolved. Pushing new commits to a branch **dismisses an existing
approval**, so avoid adding commits to a pull request that has already been approved
unless you are answering review feedback.

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
line. It also only exists on branches that contain it, so a branch cut before the hook
landed is unguarded.

It is not what protects `main` — the ruleset above does that, on the server. The hook
just fails earlier: a commit refused locally is easier to deal with than a push
rejected after the fact.

## Rules

- Never force-push `main`.
- Never rebase or force-push someone else's branch.
- `--force-with-lease`, never bare `--force`.
- Commit messages reference the `W-NNN` work item when one exists.
