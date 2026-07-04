# Governance — Agent Accountability Composition

This repository holds **draft-mih-sato-agent-accountability-composition**, a multi-organization,
multi-author IETF Internet-Draft describing a *composition profile* over the existing agent-audit
architecture — how independently-verifiable profiles for four questions (**CAN** / **WHO** / **WHAT** /
**AUDIT**) bind by a shared action-digest, each verifying on its own.

## Neutral by intent

The composition is a **neutral interoperability seam, not any single company's product**, and it must
stay that way to be worth composing with. Accordingly:

- **No single leg — or single company — controls the composition.** The repository is stewarded in a
  **neutral namespace independent of any one leg's authors** (including the initial steward's own).
- **Multi-organization authorship from -00.** Co-authors are listed by the author list the group
  settles; the repository slug is a filename handle, not a ranking or an ownership claim.
- **Each leg's format stays its authors' own.** The composition references record types and profiles
  by digest; it does **not** absorb, redefine, or claim any leg's format. No format is mapped into the
  composition without its author in the room.

## Donate-by-design

Modeled on the Linux-Foundation pattern (and the sibling `agentactioncapsule.org` governance): the
draft, the repository, and any associated name/mark are **intended to transfer to a neutral foundation
home** as the work matures and the group ratifies it. The initial steward holds it in trust, openly and
neutrally governed, and gives it away when a neutral home is selected — it is not a company asset.

## How we work (v1 — ratify or amend as a group)

- **Change by pull request; consensus of the co-authors merges.** Substantive changes to a leg's text
  are the authority of that leg's owner; changes to the composition seam (digest binding, the four
  questions, the registered/anchored tier) are group decisions.
- **The digest input and canonicalization are the first open issue** — no default until the format
  authors weigh in (JSON/JCS, CBOR, and per-format hashing all on the table); no format inherits a
  retrofit.
- **Even-handed toward adjacent work.** Related record formats are cited as live adjacent work, not
  position; their authors are invited to review the digest/mapping issue — or to decline, with absence
  implying nothing about a format.
- **IETF process governs the draft.** BCP 78/79 apply from first contribution; required IPR disclosures
  are filed with the submission. The draft is licensed under the IETF Trust (trust200902) and is freely
  implementable.

## Roles

- **Co-authors** — the four legs' representatives, listed on the -00.
- **Editor/steward (initial)** — stands up and maintains the repository and CI, neutrally, pending the
  foundation transfer above. The steward has no more authority over a leg than that leg's owner.

Conduct: be excellent to each other; report concerns to the steward. A full Code of Conduct
(Contributor Covenant) travels with the repository.
