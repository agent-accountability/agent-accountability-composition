# Agent Accountability Composition

A neutral IETF Internet-Draft — **draft-mih-sato-agent-accountability-composition** — describing how
independently-verifiable profiles for four questions about an autonomous agent's action bind together
by a **shared action-digest**, each verifying on its own, expressed *within* the existing agent-audit
architecture (`draft-kuehlewind-audit-architecture`) rather than as a new architecture above it.

## The four questions

- **CAN** — the "may": was the agent permitted to act?
- **WHO** — which accountable human authorized this exact action? (distinct from *which agent*)
- **WHAT** — the "did": a byte-stable serialization of the *observed* action record.
- **AUDIT** — did the runtime enforce correctly, in causal order, tamper-evidently?

These are **requirements a format maps *itself* against**, not slots anyone is assigned to. Formats
compose by referencing a shared action-digest; each is independently verifiable; no format is redefined
here.

## What this repo is (and isn't)

- **Is:** the shared home for the composition draft and its interoperability test-vector suite, a
  neutral seam multiple profiles compose across.
- **Isn't:** a record format, an identity system, an authorization protocol, or any single company's
  product. It composes with those; it replaces none.

## The registered ("anchored") tier

The piece worth standardizing: registering a record to a SCITT transparency service under a stated
policy so a third party who doesn't trust the operator can independently verify *registration* —
tamper-evident and datable — without mandating a format. Self-attestation stays valid; this makes the
registered tier reachable and testable for any profile.

## Status

- **-00** targeted for the IETF 126 (Vienna) cutoff. Co-authored, multi-organization; author list
  settled from -00.
- **First open issue:** the digest input and canonicalization (no default until format authors weigh
  in).
- Governance and the donation-by-design path: see `GOVERNANCE.md`.

## Contributing

Changes by pull request; consensus of the co-authors merges. A leg's text is its owner's authority; the
composition seam is a group decision. IETF process (BCP 78/79) governs the draft; IPR disclosures are
filed with the submission.

*Neutral steward, donate-by-design. This is not a company asset — see GOVERNANCE.md.*
