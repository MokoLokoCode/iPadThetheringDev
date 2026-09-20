# Decisions

Each decision gets a stable ID. Never delete an entry — mark it **Superseded by D-NNN** instead.

## Template

```
## D-NNN: <title>
- Status: Accepted | Superseded by D-NNN | Rejected
- Date: YYYY-MM-DD
- Context: why a decision was needed
- Decision: what we chose
- Alternatives: what else was considered
- Rationale: why this one
- Deviations: any known departures from the decision in the code, and why
```

## D-001: Repository documentation structure
- Status: Accepted
- Date: 2026-09-20
- Context: Need a shared, agent-readable source of truth for scope, design, and progress.
- Decision: Seven top-level markdown files (README, ARCHITECTURE, DECISIONS, STATUS, PROGRESS, AGENTS, VALIDATION), each with a fixed purpose (see README documentation map).
- Alternatives: Single README; wiki; issue tracker only.
- Rationale: Files live with the code, are diffable, and give an implementing agent a fixed reading order.
- Deviations: None.

<!-- TODO next decisions: camera protocol/SDK, storage location, min iPadOS version, UI framework. -->
