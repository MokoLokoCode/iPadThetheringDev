# Instructions for implementing agents

This file is intentionally small. It routes; it does not hold rules.

1. Read the root [README.md](README.md) — product, toolchain, repository layout, and the camera integration model.
2. Read [.github/agents/shared/AGENTS.md](.github/agents/shared/AGENTS.md) — the rules that apply to all work, whatever the camera.
3. Read the instructions for the adapter you are working on:
   - [.github/agents/sony/AGENTS.md](.github/agents/sony/AGENTS.md) — Sony a7R III
   - [.github/agents/fujifilm/AGENTS.md](.github/agents/fujifilm/AGENTS.md) — Fujifilm X-T4
4. Shared, camera-neutral documents are authoritative under [.github/project/](.github/project/): ARCHITECTURE, DECISIONS, PROGRESS, STATUS, VALIDATION.
5. Read @.github/CONTRIBUTING.md before your first commit — branch, rebase, and pull-request rules. `main` is protected and more than one person works here, so pull main and rebase before starting, not after.

It lives at the root because agent discovery from nested `.github` directories is
tool-dependent.
