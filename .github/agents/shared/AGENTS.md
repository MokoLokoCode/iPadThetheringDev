# Shared agent instructions

Applies to all work on this repository regardless of camera. Adapter-specific rules
are in the sibling vendor directories and add to these; they never relax them.

## Reading order

1. Root [README.md](../../../README.md)
2. [STATUS.md](../../project/STATUS.md) — where things actually stand
3. [ARCHITECTURE.md](../../project/ARCHITECTURE.md) — how it is built
4. [DECISIONS.md](../../project/DECISIONS.md) — why it is built that way
5. [PROGRESS.md](../../project/PROGRESS.md) — what is next
6. [VALIDATION.md](../../project/VALIDATION.md) — how to prove it works
7. The applicable `.github/agents/<vendor>/AGENTS.md`

## Engineering rules

- Work only on items listed in PROGRESS.md; reference the `W-NNN` ID in commits — see [CONTRIBUTING.md](../../CONTRIBUTING.md) for the branch and pull-request rules, and pull main before starting work rather than discovering the divergence at push time.
- Any design choice not already in DECISIONS.md gets a new `D-NNN` entry before code lands.
- Never delete or renumber IDs in DECISIONS.md or PROGRESS.md. Supersede instead.
- Update STATUS.md at the end of every working session: what works, what is unverified, next action.
- Keep ARCHITECTURE.md truthful — if the code deviates, update the doc or record a Deviation in the decision.
- No new third-party dependencies without a decision entry.
- Do not duplicate the shared documents per camera. If a camera needs something the shared contract lacks, extend the contract — with evidence.

## Evidence discipline

- Distinguish **documented**, **proposed**, **compiled**, **simulated**, and **hardware-verified**. Compilation does not establish camera compatibility, and one vendor's results never certify another's.
- Verify current Apple and vendor documentation, and the installed SDK, before relying on a signature, availability, entitlement, privacy key, threading rule, or camera operation.
- Record Xcode/SDK, Swift language mode, deployment target, iPadOS, camera firmware, and cable setup for every hardware run.
- Discovery, session-open, and catalog-ready are three different things. Log them independently. A missing callback is a finding, not a reason to discard later events.
- Advertised camera capabilities are clues, not proof of physical-shutter access or safe storage behavior.
- Every `W-NNN` marked Done cites evidence: a VALIDATION.md procedure ID with its observed result, or test output. Hardware-dependent items are not Done until run on the real device.

## Claims about people

- Apply the evidence discipline above to people as well as hardware: assert what the repository shows, not what a person thinks, wants, or is doing.
- State the observable fact. "No open work item references this adapter" is checkable; "nobody is working on it" is not.
- Give the shape of a convention and stop — branch namespace, handle, editor, tooling, settings. Do not fill in anyone's, including your own.
- Attribute a position to a dated source: a review, a message, or a commit before inferring intent. 
- Leave a missing fact about a person blank and ask. Blank is a valid value.

## Safety boundaries

- Never call deletion APIs, enable delete-after-download, format a card, or send reset/format/firmware commands. Do not change capture destinations from software.
- Initial hardware tests use expendable photographs and a backed-up or scratch card.
- Never use a paying client's session as a compatibility test.
- Do not claim RAW remains on the card until it has been checked after tethered captures. A shutter sound, a thumbnail, or an object-added event is not proof of durable card storage.
- Keep client images and filenames local. Do not upload images, logs, or USB traces anywhere without permission; redact serial numbers and personal filenames.
- Do not touch the user's photos outside the app's own session directory.
- Do not promise background capture or recovery of camera-only buffers.

## Scope boundaries

- Do not implement anything in the README's *Out of scope for V1*.
- Do not change an adapter's target camera or bench hardware without asking.
- Do not touch the on-disk session format after it ships without a superseding decision.

## When to stop and ask

- A decision in DECISIONS.md appears wrong or blocks the current item.
- A work item's acceptance criteria are ambiguous.
- A required hardware behavior cannot be verified with available equipment.
- Anything would require touching the user's photos outside the session directory.
- A hardware gate would otherwise be advanced on mocks. Labeled mock tests may be prepared; they cannot clear a gate.
