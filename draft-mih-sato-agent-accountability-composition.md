<!-- THIN -00 SKELETON — draft-mih-sato-agent-accountability-composition -->
<!-- Purpose: hold the slot at the IETF-126 cutoff (Mon Jul 6 23:59 UTC). Thin is fine; the job of -00 is
     to NAME the contested framing (four-question decomposition + three-digest composition model) so the
     Datatracker timestamp is the provenance record. Flesh after the call. This is kramdown-rfc-style
     markdown authoring content — compile to xml/txt (kramdown-rfc / xml2rfc) and submit via the I-D
     Submission Tool. FILL IN each author's real affiliation + email before submit. Author ORDER + the
     filename (two names: mih-sato) settle among the co-authors by email first. Public-safe: Informational;
     composition + conformance + the anchored/disinterested assurance tier; complements the existing
     audit-architecture work, not a rival architecture; no moat/Authority/reputation content. -->

---
title: "Agent Accountability: Composition and Conformance"
abbrev: "Agent Accountability Composition"
docname: draft-mih-sato-agent-accountability-composition-00
category: info
ipr: trust200902
area: Security
keyword: [agent, accountability, audit, SCITT, composition, conformance, attestation]
stand_alone: yes
author:
 -
    name: Steven Mih
    org: Action State Group, Inc.
    email: steven@actionstate.ai
 -
    name: Toshiyuki (Tom) Sato
    org: MyAuberge K.K.
    email: tomsato@myauberge.jp
 -
    name: Songbo Bu
    org:
    email: bluedognull@gmail.com
 -
    name: Iman Schrock
    org: EMILIA Protocol
    email: team@emiliaprotocol.ai
normative:
informative:
  RFC9943:
  RFC9334:
--- abstract

Autonomous and semi-autonomous software agents increasingly take consequential
actions across administrative and trust domains. Holding such an action
accountable — to a regulator, auditor, or counterparty who does not trust the
operator — requires answering several questions, each answerable by an
independently-verifiable profile: whether the agent was permitted to act (CAN),
which accountable human authorized the specific action (WHO), what the agent
actually did (WHAT), and whether the runtime enforced correctly (AUDIT).

This document specifies, in Informational terms, how such profiles compose — by a
shared action-digest, each verifying independently — and defines a shared
conformance-vector suite against which any profile may be tested. It complements
existing audit-architecture and record-format work rather than replacing it,
reusing existing signing, transport, and transparency mechanisms. Its focus is an
assurance tier those documents leave open: most agent records today are
self-attested by an interested party; this document makes reachable and testable an
anchored, third-party-verifiable tier, in which a record is registered to a
transparency service (SCITT) so a party who trusts neither the agent nor the
operator can verify it. Self-attestation remains a valid baseline; convergence on
the disinterested tier — by any conforming profile — is the goal, not a single
mandated format.

--- middle

# Introduction

Autonomous agents are non-deterministic, act without per-step human oversight, cross
administrative and trust boundaries, and delegate to other agents. The assumptions that
let earlier systems be trusted — predictability, runtime supervision, a nameable human in
the loop — do not hold by default. When behaviour cannot be supervised as it happens, trust
must relocate to evidence that can be checked afterward and, because agents act across
organizational boundaries, checked without trusting the operator.

Identity and authorization are necessary but not sufficient: they establish which agent and
what it was permitted to do, but the risks that characterize agent systems — goal drift,
prompt injection, fabricated tool results, action outside scope — occur in the gap between
what was authorized and what was actually done. Holding a consequential agent action
accountable therefore requires answering several questions, each answerable by an
independently-verifiable profile: whether the agent was permitted to act (CAN), which
accountable human authorized the specific action (WHO), what the agent actually did (WHAT),
and whether the runtime enforced correctly (AUDIT).

This document does not define a new audit architecture; it complements the existing architecture
and record-format work in this space (see Relationship to Existing Work) and specifies the piece
they leave open: how profiles answering these questions compose, by a shared action-digest, into
one record, and how conformance — both to that composition and to an anchored, third-party-verifiable
assurance tier — is tested. Two principles frame it: (1) composition by shared digest, not
containment — each profile verifies independently and refers to the same action by a shared digest;
and (2) producer-agnostic neutrality — no profile is a required root of trust for another. The set
of questions is open and extensible (agent identity and belief-provenance are natural further slots),
and the composed evidence serves both after-the-fact accountability and the forward-looking
authorization and trust decisions that rely on it.

## Terminology

Slot; profile; composition vector; profile-tagged digest; trust root. [Define in a
later revision; align with the constituent-profile terminology.]

# Overview: Questions and Composition

The work centers on a set of interchangeable **slots**, each a question that a
conforming **profile** answers:

- **CAN** — the "may": was the agent permitted to act?
- **WHO** — which accountable human authorized this exact action?
- **WHAT** — the "did": what did the agent actually do (verdict-complete; a byte-stable serialization of the observed record, not a replay)?
- **AUDIT** — did the runtime enforce correctly, in causal order, tamper-evidently?

Any conforming profile may fill a slot; the profiles cited in this document are the
first instances, not the definition. An action fills the slots its trust
requirement calls for; not every action populates every slot. The set is extensible
(see Extension Points).

# The Composition Model

Profiles compose by reference to a shared **subject digest** over the action —
`subject_digest = SHA-256(JCS(action))` — which is the join key all slots refer to.
A profile-tagged **authority-reference digest** binds a slot's evidence to the
registered object it commits to, and a **receipt-payload digest** binds transparency
receipts. Digests committing to signed bytes require deterministic encoding.

[Full three-digest binding rules, profile-label discipline, and raw-bytes-vs-ASCII
-hex rules to be imported from the digest-binding thread / conformance issue in a
later revision.]

# Trust-Root Separation

Each slot may root in a different trust anchor (e.g. a human device key, a kernel
attestation key, a transparency-log operator). The composition holds even if any one
party is compromised or under review. No slot is a required root of trust for
another; profiles remain producer-agnostic.

# Assurance Tiers

A record answering these questions may be produced at different assurance levels, and the
distinction is the crux for a relying party who does not trust the operator:

- **Self-attested (baseline).** The record is signed by the agent or its operator and held by an
  interested party. This is useful telemetry and a reasonable default, but it cannot, by itself,
  satisfy a regulator, counterparty, or insurer who does not trust the producer.
- **Anchored / third-party-verifiable.** The record, or a digest of it, is registered to a
  transparency service — the SCITT substrate ({{RFC9943}}) — yielding a receipt
  that lets a party who trusts neither the agent nor the operator verify the record's existence, its
  content at registration time, and non-equivocation, independent of any single producer's
  infrastructure.

This document does not mandate the anchored tier; self-attestation remains valid. It specifies how any
conforming profile MAY reach the anchored tier by registering to a transparency service, and how that
tier is tested (see Conformance) — so that third-party-verifiability is a property profiles can
converge on, not a single format they must adopt.

# Conformance

Conformance is expressed as a shared vector suite: a positive composition vector
(one action threaded through the populated slots) plus, per slot, the negative-case
classes it MUST expose (e.g. non-deterministic encoding, ASCII-hex-as-bytes,
profile-label mismatch, receipt bound to a different statement, broken join digest).

A conformance vector freezes only after it has been recomputed by at least two
independent implementations. This document specifies no implementation; each slot is
implemented independently, and any party may verify against the vectors.

# Extension Points

Additional question-slots compose by the same digest discipline. Belief-provenance
("why the agent believed what it acted on") is a named extension socket. [Others as
identified.]

# Relationship to Existing Work

This document complements, rather than replaces, existing efforts. An architecture for auditing agent
delegation and interactions is developed separately (the audit-architecture work, with its interaction,
action, delegation, and authorization-transition record types); record and logging formats and
action-lineage protocols are defined in adjacent documents. The four questions here map onto those
record types rather than redefining them.

What this document adds is the piece those leave open: the composition of independently-verifiable
profiles by a shared action-digest, a shared conformance-vector suite, and the anchored,
third-party-verifiable assurance tier (see Assurance Tiers). It defines no new signing, transport, or
transparency mechanism. Specific documents will be cited normatively and informatively in a later
revision.

# Security Considerations

The security properties are those of the composed profiles plus the binding
rules here; no single layer suffices. The agent is not trusted. Distributed trust
roots mean no single verifier or transparency service is assumed sufficient. This
document does not address an adversarial party that refuses to record at its own
boundary, nor collusion across all roles, nor model alignment. [Expand.]

# Privacy Considerations

Records may be rich in information about users and the data an agent processed.
Profiles SHOULD support content-private, hash-only (detached-payload) records so a
registered statement carries only a digest, with content held under deployment
controls. The shared join digest enables cross-slot correlation; pairwise or
encrypted correlation identifiers SHOULD be available where correlation is not
required. [Expand.]

# IANA Considerations

This document has no IANA actions. [A registry of slot identifiers / profile labels
may be proposed in a later revision.]

--- back

# Acknowledgments
{:numbered="false"}

[To be completed with the constituent-profile authors and reviewers, with permission.]
