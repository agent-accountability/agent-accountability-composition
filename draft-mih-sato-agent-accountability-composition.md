---
title: "Agent Accountability: Composition and Conformance"
abbrev: "Agent Accountability Composition"
docname: draft-mih-sato-agent-accountability-composition-01
category: info
ipr: trust200902
area: Security
keyword: [agent, accountability, audit, SCITT, composition, conformance, attestation]
stand_alone: yes
submissiontype: IETF
author:
 -
    name: Steven Mih
    org: Action State Group, Inc.
    email: steven@actionstate.ai
 -
    name: Tom Sato
    org: MyAuberge K.K.
    country: Japan
    email: tomsato@myauberge.jp
 -
    name: Songbo Bu
    org: Independent
    email: bluedognull@gmail.com
 -
    name: Iman Schrock
    org: EMILIA Protocol, Inc.
    email: team@emiliaprotocol.ai
normative:
informative:
  RFC9943:
  RFC9334:
  I-D.kuehlewind-audit-architecture:
  I-D.sharif-agent-audit-trail:
  I-D.bates-atp:
  I-D.aylward-aiga:
  I-D.schrock-human-authorization-binding:
  I-D.schrock-ep-authorization-receipts:
  I-D.mih-scitt-agent-action-capsule:
  I-D.bu-agentproto-security-principal-binding-03:
    title: "Security Principal Binding for Agent Protocols"
    author:
      name: Songbo Bu
    date: 2026
    target: https://datatracker.ietf.org/doc/draft-bu-agentproto-security-principal-binding/
  I-D.lee-orprg-permit-receipts:
  I-D.sokolov-rats-aep-composition:
  RFC8785:
  RFC9901:
  I-D.ietf-oauth-sd-jwt-vc-17:
  OpenID4VP:
    title: "OpenID for Verifiable Presentations 1.0"
    target: https://openid.net/specs/openid-4-verifiable-presentations-1_0-final.html
  MACHINE-MANDATE:
    title: "MachineMandate"
    author:
      org: Tyche Institute
    target: https://github.com/tyche-institute/machine-mandate
  ORPRG-EVAL-V226:
    title: "v2.2.6 Public Evaluation — IETF 126 PermitReceipt Review Packet"
    author:
      org: Meridian Verity Group
    date: 2026-07-10
    target: https://github.com/meridianverity/permit-receipt/releases/tag/v2.2.6-public-eval
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

Profiles compose either by reference to a shared **subject digest** over the action
— the join key the slots refer to — or through an explicit, cryptographically
protected cross-reference. A profile-tagged **authority-reference digest** binds a
slot's evidence to the registered object it commits to, and a **receipt-payload
digest** binds transparency receipts. Digests committing to signed bytes require
deterministic encoding. The subject-digest construction (`subject_digest =
HASH(subject_preimage)`) is defined per profile, as set out in the following
subsections; no single canonicalization is imposed.

## Three Digest Roles

Profiles compose either by reference to a shared **subject digest** over the
action or through an explicit, cryptographically protected cross-reference
between profile-native subject digests. A subject digest is:

`subject_digest = HASH(subject_preimage)`

where the profile defines the subject data model, the exact preimage bytes, the
hash algorithm, any domain-separation bytes, and the digest representation. JCS
is one possible canonicalization choice; it is not imposed on profiles that
select another byte construction.

The composition carries three distinct digest roles:

- The **subject digest** identifies the action or action projection to which a
  slot's assertion applies.
- A profile-tagged **authority-reference digest** commits to the native evidence
  object or statement that supports the slot assertion.
- A **receipt-payload digest** commits to the exact bytes submitted to a
  transparency service and covered by its receipt.

These digest values MAY differ. A profile MUST state which object and exact byte
sequence each digest covers, and a composition verifier MUST NOT infer equality
or transitive coverage merely because two fields use the same hash algorithm.
Where one signed object links the roles, the protected portion of that object
MUST cover the relevant digest values and their profile labels.

## Digest Context and Representation

Every digest comparison requires a **digest context** consisting at least of the
profile label and version, covered field set or projection, canonicalization
profile, hash algorithm, domain-separation rule, digest encoding, and digest
representation. Profile labels are protocol inputs, not display metadata. A
missing, unknown, or incompatible profile label is a failed join, not permission
to apply a local default.

Raw digest bytes and textual encodings are different values. In particular, a
32-byte SHA-256 output, the 64 ASCII characters of its lowercase hexadecimal
encoding, and the ASCII string formed by prepending `sha256:` to that encoding
MUST NOT be substituted for one another. A profile MUST state which
representation appears in each field and which representation, if any, is
included in a further digest preimage.

Two profiles may use digest equality as a direct join only when their complete
digest contexts are compatible and the compared preimage byte sequences are
demonstrated to be identical, for example by a shared frozen test vector.
Otherwise, they compose through an explicit, cryptographically protected
cross-reference that names both profiles and binds both digest values. A
cross-reference proves the stated association; it does not make the native
digest constructions identical.

Digest equality is a join key: it does not, by itself, prove truth,
authorization, sufficiency, completeness, or policy compliance. Native profile
verification, digest recomputation, receipt or transparency verification,
completeness and sequencing checks, and relying-party acceptance remain
separate results.

## Cross-Profile Reviews

The following entries record the application of external review frameworks to the
composition model's slot mappings. Each entry is contributed by the reviewing author
and records only what that author's analysis found; no entry implies byte-agreement
results or conformance claims not explicitly stated.

### Principal-Binding Review (Bu)

Principal-binding review framework (Bu): verifier-facing claim, carrier, verifier,
binding, accepted-result, and failure boundaries from
{{I-D.bu-agentproto-security-principal-binding-03}} were used to review the WHO-slot
mapping. The AAC Class-1 repository was independently replayed at commit
10342f504b051a24908053465927efdaea3ec2f6, but no independent principal-binding
byte-agreement result is claimed. Status: framework mapping reviewed; AAC reference
suite independently replayed.

[Additional cross-profile review entries in later revision.]

## Worked Profile Illustration

On the permit side, the abstract PermitReceipt architecture
({{I-D.lee-orprg-permit-receipts}}) leaves canonicalization and action-digest
construction to a selected profile; it does not mandate JCS or any other single
canonicalization. A verifier that cannot establish canonicalization-profile
compatibility is required to return DENY rather than treat digest values as
comparable across an unestablished profile boundary.

In the frozen CP-JSON-2 public-evaluation profile
({{ORPRG-EVAL-V226}}) — one evaluation profile of that architecture, not a universal
construction of it — the action digest is the 64-character lowercase hexadecimal
encoding of SHA-256 over the exact canonical request bytes. That profile prepends no
additional domain-separation bytes to the action-digest preimage.

This profile-specific construction does not imply byte identity with JCS-based
profiles. For a particular test vector, digest equality across profiles may serve as
a direct join for that vector only when the complete digest contexts are compatible
and the compared preimage byte sequences are demonstrated to be identical. Relevant
context includes the field set, digest algorithm, canonicalization profile,
domain-separation rule, encoding, and digest representation. Otherwise, the profiles
compose through an explicit, cryptographically protected cross-reference.

In {{ORPRG-EVAL-V226}}, `receipt_core.action_digest` is the unprefixed 64-character
lowercase hexadecimal text, while `authorization_ref.action_commitment` is the
literal ASCII prefix `sha256:` followed by the same 64 hexadecimal characters.
Neither textual representation is the raw 32-byte digest.

The digest preimage is the exact byte sequence designated by the selected profile or
frozen vector. Human-readable renderings, pretty-printed documents, console output,
and files containing added line terminators are not interchangeable with that preimage
unless the profile explicitly designates those exact bytes.

This illustration states profile-specific implementation facts. It makes no CAN
slot proposal, conformance or interoperability claim, endorsement claim,
production-readiness claim, joint-ownership claim, or patent or license claim.

Attribution: "ORPRG profile-specific worked illustration based on
{{I-D.lee-orprg-permit-receipts}} and {{ORPRG-EVAL-V226}}. The permit-side
construction and the ORPRG-specific implementation facts concerning profile
compatibility and digest representation reflected in this illustration were
identified and documented in the permit-side review and were supplied and
owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity Group."

Acknowledgment: "The cross-profile binding discussion in this section was informed by
the ORPRG row of a versioned digest-binding matrix and by the subsequent multi-party
composition review. The ORPRG row and its supporting permit-side observations were
supplied and owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity Group."

# Trust-Root Separation

Each slot may root in a different trust anchor (e.g. a human device key, a kernel
attestation key ({{RFC9334}}), a transparency-log operator). The composition holds even if any one
party is compromised or under review. No slot is a required root of trust for
another; profiles remain producer-agnostic.

# Slot Profiles

The profiles in this section are first instances filling the slots named above,
recorded so the composition can be tested against something concrete. They are not
the slot definitions; any conforming profile may fill a slot (see Overview). Each
profile's text is contributed and maintained by its authors.

## The CAN Slot

### Design Rule

The CAN slot asks whether a declared authority issued a bounded grant that
covers the requested action at the authorization decision point, before the
external effect is committed, and whether the relying party accepts that grant
under its stated trust and policy inputs.
It does not identify the accountable human who authorized the action (WHO),
prove what action occurred (WHAT), or prove that the runtime enforced correctly
(AUDIT). A CAN result also does not establish that the declared action
description equals the real-world effect; that binding remains an obligation of
the relying party that performs the effect.

The first-instance profile is MachineMandate: a holder-bound, short-lived
authorization credential whose signed claims identify an agent subject, declare
a credential type and bounded scope, and commit to a profile-defined action
projection. The selected composition profile separately pins the credential
format and profile version; the frozen MachineMandate `vct` string shown below
is not itself versioned. A presentation can use SD-JWT VC and OpenID for
Verifiable Presentations (OpenID4VP), including verifier-provided nonce and
audience values. A relying party verifies the native credential and
presentation, appraises the issuer under its authorization policy, recomputes
the action commitment, and evaluates each declared scope dimension before
returning ALLOW or DENY.

MachineMandate is one CAN instance, not the CAN slot. Other authorization
formats may fill the slot if they expose equivalent independently verifiable
inputs and results.

### Producer Requirements

A conforming MachineMandate CAN producer MUST state:

- the credential-format profile, version, media type, and credential-type
  identifier;
- the issuer identifier, key-discovery or trust-anchor mechanism, and the
  profile-specific role or policy under which that issuer is authorized to
  grant the declared scope;
- the agent subject and the proof-of-possession or holder-binding mechanism;
- the scope fields and the semantics, units, currency, comparison rule, and
  default-deny behavior of every scope dimension;
- the action field set or projection covered by the action commitment;
- the exact action-commitment preimage bytes, canonicalization profile, digest
  algorithm, domain-separation rule, encoding, and digest representation;
- any authorization-relevant action dimension evaluated outside the action
  commitment, and the separate gate that evaluates it;
- the issued-at and expiry semantics, any not-before rule, and the status or
  revocation mechanism, if one is used;
- the semantics of any credential identifier or one-time-use field and the
  state required to enforce those semantics;
- the exact native authority object referenced by the composition, including
  its profile-tagged authority-reference digest and byte preimage;
- when that authority-reference preimage excludes presentation-specific
  material, the exact disclosures, holder-binding proof, verifier nonce,
  audience, and other transcript inputs needed to reproduce the native
  presentation appraisal, together with an integrity-protected reference to
  those inputs; and
- all issuer-role, policy, status, and trust inputs needed to reproduce the
  authorization appraisal, including the policy-evaluation time.

A producer MUST NOT describe a credential identifier as single-use unless the
selected verifier profile maintains and checks the state needed to reject a
second use. It MUST NOT describe a short validity window as revocation. An
absent, unknown, or incompatible profile, scope unit, trust input, or
action-commitment rule is a failed CAN appraisal, not permission to apply a
local default.

### Verifier Requirements

A conforming MachineMandate CAN verifier MUST report separately:

- `machine_mandate_reference_bound`: whether the protected composition
  reference identifies the expected MachineMandate artifact type, profile,
  digest algorithm, exact authority-reference preimage, and digest;
- `machine_mandate_appraised`: whether the native credential and presentation
  validate under the selected credential-format profile, including issuer
  signature, disclosure processing, proof of possession or holder binding,
  verifier nonce and audience, temporal validity, credential status when
  applicable, required-claim presence, and issuer-role or trust-policy checks;
- `machine_mandate_action_hash`: whether the verifier's recomputation over the
  declared action projection, under the exact profile and byte rules, equals
  the issuer-protected action commitment and, when the profile carries a set of
  permitted action commitments, whether that commitment is a member of the
  issuer-protected set; and
- one separately named result for every authorization-relevant scope dimension,
  including `machine_mandate_spend` when the profile declares a spending limit.

The verifier MUST return DENY if any required gate fails or cannot be
evaluated. It MUST NOT collapse reference binding, credential validation,
issuer appraisal, action-commitment recomputation, and scope evaluation into
one opaque "authorized" boolean.

Each reported gate MUST distinguish at least PASS, DENY, and NOT_EVALUATED.
When evaluation stops after an earlier rejection, a later gate is
NOT_EVALUATED; it is not a second rejecting gate. A run record that reports a
first rejecting gate MUST preserve this distinction.

When SD-JWT VC and OpenID4VP are selected, the verifier MUST apply the
validation rules of the pinned SD-JWT, SD-JWT VC, and OpenID4VP profiles,
including strict algorithm and type checks, issuer-identifier-to-key binding,
rejection of uncommitted or conflicting disclosures, required-claim
validation, and key binding. The first-instance profile described here requires
holder binding even though SD-JWT permits profiles in which key binding is
optional. Merely decoding the JWT claims, successfully verifying one signature,
or observing a known credential-type string does not establish
`machine_mandate_appraised`.

The final CAN result is:

    CAN = ALLOW
        iff reference_bound
        and native_credential_appraised
        and action_commitment_matches
        and every required_scope_gate_passes
        and relying_party_policy_accepts


The CAN verifier evaluates the action presented to the relying party, not a
value supplied by the agent as an asserted hash. The relying party MUST
reconstruct the profile-defined action projection from the request it is about
to authorize, compute the commitment itself, and use the same request values
for all scope gates. It MUST bind an ALLOW result to that request and MUST NOT
reuse the result for a changed action. If effect commitment is delayed beyond
the recorded policy-evaluation time, or if a relevant credential, status, or
policy input can have changed, the relying party MUST re-evaluate before
committing the effect.

### Separation from WHO and AUDIT

An issuer, principal, or mandate claim does not by itself answer WHO. A
MachineMandate CAN profile MAY carry or selectively disclose a principal
reference, but a named-human authorization claim belongs in a separately
verified WHO profile unless the MachineMandate profile independently meets
that profile's requirements.

Runtime attestation is likewise not a prerequisite for verifying the native CAN
credential. The current MachineMandate research demonstrator combines
credential, issuer-role, runtime-attestation, and scope gates in one end-to-end
verdict. In this composition, the credential, issuer-role, action-commitment,
and scope results map to CAN; RATS/TPM freshness and platform appraisal map to
AUDIT. The composition MAY require both results for a relying-party decision,
but a failed or absent AUDIT result MUST NOT be mislabeled as failure to parse
or cryptographically verify the CAN credential.

### Frozen IETF 126 Illustration

One frozen, pre-execution MachineMandate vector uses the credential type:

    https://vocab.tyche.institute/vct/machine-mandate


Its composition reference commits to the exact 1190-byte issuer-signed JWT
component of the SD-JWT presentation. That component has SHA-256:

    5df4d32df57650f27b6a65df041b708de80d69c0ca82a1044334f5e2edef5ce2


The authority-reference field carries that digest as unprefixed lowercase
hexadecimal text under an explicitly declared SHA-256 digest context. It is
distinct from the prefixed textual action commitment below.
Because this stable reference covers only the issuer-signed component, it does
not by itself commit to the selected disclosures, Key Binding JWT, verifier
nonce, or audience of a particular presentation. A record claiming
`machine_mandate_appraised` MUST preserve and integrity-protect that separate
presentation evidence.

The action-commitment profile in that vector covers the 91 UTF-8 bytes of:

    {"action_id":"pay-invoice/acme-corp","outcome":"eur:250:acme-corp:vienna-interop-2026-001"}


and carries the textual commitment:

    sha256:a89fbd2bd6f95cdb1ec27b6c7253770ff2a22220937cf065f6e45ef67b37e299


The profile declares `scope.allowed_actions`,
`scope.action_commitments`, and `scope.max_spend`, with spending values fixed
by the vector's mapping profile to EUR minor units. The requested amount is not
part of this vector's action-commitment preimage; it is evaluated independently
by `machine_mandate_spend`. Therefore, the action commitment alone MUST NOT be
described as committing to the payment amount. The combined CAN decision binds
the declared action projection and separately applies the amount limit.

The public MachineMandate repository contains another action profile used by
the paper/demo path, where the action projection is
`{tool, amount_eur, to}`. That digest context is not compatible with this frozen
vector's `{action_id, outcome}` projection. A draft or test vector MUST identify
which profile it uses and MUST NOT compare, substitute, or make transitive
claims across the two action commitments merely because both use SHA-256 and a
JSON canonicalization rule.

The text `eur:250:acme-corp:vienna-interop-2026-001` in the frozen vector is an
opaque outcome descriptor. A verifier MUST NOT infer amount or currency
semantics from that string; those semantics are supplied only by the separately
declared amount, currency, unit, and mapping-profile inputs.

The frozen credential was issued at `2026-07-18T13:37:15Z` and expires at
`2026-07-24T23:59:59Z`. In its credential self-check record, the positive case
requests 25000 EUR minor units and expects all MachineMandate gates to pass.
The frozen over-limit case requests 75000 against
`scope.max_spend = 50000`; it expects the reference, native appraisal, and
action-commitment gates to pass, and `machine_mandate_spend` to be the sole
rejecting MachineMandate gate. These are frozen vector expectations and
credential self-check inputs, not a completed interoperability result.

The frozen PermitReceipt and MachineMandate action constructions use different
preimages. Their relationship is therefore an explicit protected
cross-reference, not digest equality. The frozen proposed composition profile
specifies a signed Agent Action Capsule payload that co-binds the typed
PermitReceipt reference and the typed MachineMandate reference. This does not
absorb PermitReceipt into MachineMandate, make either format the CAN slot, or
cause one native appraisal to imply the other.

### Composition and Transparency Seams

At the composition join, a MachineMandate CAN profile exposes:

- its profile and credential-type identifiers;
- the subject digest and complete digest context for the action projection;
- the profile-tagged authority-reference digest for the exact native
  credential object;
- an integrity-protected reference to the exact presentation evidence when it
  is not included in the authority-reference preimage;
- the protected scope fields or their disclosure-aware commitments;
- the separately named native-appraisal, action-commitment, and scope-gate
  results; and
- the relying party's final CAN result and policy inputs.

If a MachineMandate statement or a detached digest of it is registered with a
SCITT transparency service, the SCITT receipt supplies the separate
receipt-payload digest. The receipt proves registration under the service
policy. It does not establish issuer authority, credential validity, action
coverage, scope sufficiency, or CAN acceptance.

### Negative Vectors

In addition to the composition-level negative classes, a MachineMandate CAN
profile MUST include vectors for at least:

- a protected reference to the wrong credential bytes;
- an unsupported or mislabeled credential profile, credential type, media
  type, or signature algorithm;
- an invalid issuer signature;
- a disclosure not committed by the issuer-signed SD-JWT;
- duplicate or conflicting disclosures for one claim name;
- a required claim that is missing, selectively hidden when the profile
  requires disclosure, or present under an unexpected type;
- invalid proof of possession or holder binding;
- a valid issuer-signed component paired with a presentation transcript,
  disclosure set, or Key Binding JWT different from the one appraised;
- a mismatched verifier nonce or audience;
- an expired or not-yet-valid credential;
- a revoked or suspended credential when the selected profile claims status
  enforcement;
- an issuer key that verifies cryptographically but is not accepted for the
  required authorization role;
- a changed action field after issuance;
- a canonicalization, profile-label, or digest-representation mismatch;
- a requested action outside `allowed_actions`;
- a missing required action commitment;
- an amount above `max_spend`;
- a currency or unit mismatch;
- a second use when the selected profile claims one-time semantics;
- a scope field omitted and then supplied from an undeclared local default;
- a later scope gate skipped after an earlier rejection but incorrectly
  reported as an independently evaluated DENY; and
- a transparency receipt bound to a different payload.

### Current Assurance Boundary

The public MachineMandate repository and paper are research artifacts. The
current issuer key, holder key, `qtsp://issuer` identifier, and trust-list inputs
used by the frozen composition credential are synthetic, run-specific inputs.
They do not establish a real qualified trust-service provider, national trust
framework, production issuer authorization, or production status service. In
particular, the demonstrator's synthetic `AgentRuntimeEndorser` trust-list role
is not evidence that the same issuer is authorized by a production ecosystem to
issue machine mandates.

The repository's credential code is an implementation used to exercise the
construction; this text does not claim that the implementation has been tested
for conformance to {{RFC8785}}, {{RFC9901}},
`draft-ietf-oauth-sd-jwt-vc-17`, or OpenID4VP. The repository describes its
JSON canonicalization as an RFC 8785
subset and its credential implementation as simplified; the exact frozen bytes
and profile identifiers, rather than a generic conformance assumption, control
the vectors. The artifact does not implement a production revocation service or
a persistent single-use replay cache. Its short validity window and credential
identifier MUST NOT be promoted into either claim.

At the initial 2026-07-23 hostile-review point,
`vocab.tyche.institute` did not resolve in DNS. Later that day, Tyche published
minimal Type Metadata at the exact frozen `vct` URL; the endpoint returns HTTP
200 and `application/json`. The metadata identifies and displays the research
credential type. It does not define a production issuer trust framework,
establish implementation conformance, or version the profile. The frozen
credential does not carry `vct#integrity`, so a consumer cannot infer a
content-pinned metadata version from that credential. A deployment whose policy
requires Type Metadata MUST still reject when it cannot retrieve or fully
process the metadata through a trusted, profile-defined method.

The action commitment proves equality to a declared action projection under a
named byte profile. It does not prove that the relying party executed that
description faithfully or that the real-world effect was semantically correct.
The MachineMandate repository's embedded runtime-attestation fixtures use
`swtpm`; the separate PCR-16 AAC/AEP composition instance uses a vTPM. Neither
is a manufacturer-provisioned physical TPM claim. The formal three-owner IETF
126 evidence-generating run did not produce a valid result at the proposed
2026-07-23 coordinate because its complete pre-run freeze was not issued.
Credential self-checks and engineering rehearsals remain separately classified;
no successful composition result is claimed here.

The first-instance MachineMandate CAN profile seed text was contributed by
Anton Sokolov, Tyche Institute.

## The WHO Slot: Named-Human Authorization

The WHO slot answers a single question: which named, accountable human — or quorum
of distinct humans — authorized this exact action before it ran. It is deliberately
narrow. It does not define the composition model itself, a sufficiency or policy
decision, a new audit-record format, or a replacement for agent or workload
identity: "which agent acted" is a different slot, and "was this authorization
sufficient for this action" is a layer above the composition. It binds the
authorization to the exact observed action by the composition's shared action
digest — the subject digest of the Composition Model — and exposes the binding
metadata a composition verifier needs, and nothing more. Digest equality itself
neither authorizes the action nor proves completeness.

In the first-instance profile ({{I-D.schrock-human-authorization-binding}}, with
the receipt format in {{I-D.schrock-ep-authorization-receipts}}), the WHO record is
an authorization receipt: a device-bound signature by a named principal — or a set
of distinct principals — over the canonical bytes of one action, verifiable offline
against the signer's public key. Any record form meeting the producer and verifier
requirements below conforms.

A conforming WHO producer MUST state: the authorizing principal identifier(s) — the
named human(s), not the agent; for a quorum, the quorum descriptor (an M-of-N
threshold or an ordered sequence) and the eligible or actual signer identifiers;
the subject of the action being authorized; the covered action bytes or data model,
the canonicalization rule (if any), the digest algorithm and version, and the
domain-separation context; the binding between the subject digest and the receipt
signature(s) — the signed payload MUST cover the digest; the validity window and
any freshness or one-time-use semantics; and the failure behavior when a required
binding input, signer, or quorum member is absent — fail closed: absence of
authorization is not authorization.

A conforming WHO verifier MUST be able to produce a result that states: whether
each signature validates under the profile rules; the exact digest bytes it
recomputed and the canonicalization and hash parameters used; whether the digest is
covered by each signature; for a quorum, whether the threshold is met, whether the
counted signers are distinct principals, whether every counted signer signed the
same canonical action bytes under the same digest context, and — for an ordered
quorum — whether the required order held; whether the receipt is within its
validity window and any one-time-use constraint; and the verified-versus-accepted
distinction (below). The verifier MUST keep signature validation, digest
recomputation, quorum evaluation, and freshness as separate results, and MUST NOT
collapse them into a single opaque "authorized" boolean.

The WHO slot separates two claims a composition verifier must never conflate:
VERIFIED — the signature(s) and the digest binding hold, given a public key;
objective and offline — and ACCEPTED — the relying party additionally trusts the
authorizing principal(s) via out-of-band key pinning; a relying-party decision, not
a property of the receipt. A WHO verifier MUST surface these separately: a valid
signature over the bound digest proves VERIFIED and never implies ACCEPTED, and
neither implies the authorization was sufficient for the action.

At the composition join, the WHO slot exposes a minimal, disclosure-aware
reference: the subject digest and its declared digest context; the authorizing
principal identifier(s) — or, under selective disclosure, a commitment to them; the
quorum descriptor, if any, with a distinctness assertion; and the binding assertion
that the signature(s) cover the subject digest. The reference carries no agent
identity, no policy verdict, and no sufficiency claim.

Where a WHO record is also registered to a transparency service (see Assurance
Tiers), the transparency receipt proves registration of the submitted statement
under the service policy; it does not prove that a named human authorized the
action. A WHO verifier MUST keep native signature validation, digest recomputation,
and transparency-receipt validation as separate results.

In addition to the composition-level negative classes (see Conformance), a WHO
profile MUST reject each of the following, and the verifier MUST report which check
failed: semantically similar action input with different canonical bytes; a changed
subject; a changed authorizing-principal reference; replay of the receipt under a
different action (a different subject digest); a quorum satisfied by a non-distinct
principal filling two slots; an ordered quorum satisfied out of order; a threshold
not met; a mismatched or absent receipt signature; a signature that verifies but
whose signed payload does not cover the subject digest (an unbound signature); a
stale receipt; a post-hoc ratification presented as pre-execution authorization; a
reusable authorization presented under one-time semantics, or a one-time
authorization presented as reusable; and WHO digest bytes that do not match an
adjacent slot's digest for the same claimed action under compatible digest contexts
(per the binding rules of the Composition Model, to be imported). [The WHO
positive-vector classes are imported with the conformance suite in a later
revision.]

## The WHAT Slot

[Profile text to be contributed by the slot's owners.]

## The AUDIT Slot

### Design Rule

The AUDIT slot asks whether the runtime produced independently appraisable
evidence that its declared enforcement path was applied to this action, in the
claimed causal order, without undetected alteration. It does not establish that
the policy was sufficient, that every relevant event was recorded, or that the
action was semantically correct. Those are separate completeness and
relying-party judgments. Platform attestation also does not, by itself, prove
the truth of an application-layer record; the binding between the two is the
load-bearing claim.

The first-instance AUDIT profile composes an application-layer action evidence
package (AEP) with RATS Evidence and an Attestation Result
({{I-D.sokolov-rats-aep-composition}}, using the roles and trust model of
{{RFC9334}}). The AEP is a signed, append-only record of the action, its
authority, and its outcome. Platform Evidence binds an AEP outcome digest and a
fresh per-appraisal value into data covered by an attestation-key signature.
The resulting profile lets a verifier check that the same outcome named by the
action record was present in the appraised execution context. It does not make
the AEP producer or the Attester a truth oracle.

### Producer Requirements

A conforming AUDIT producer MUST state:

- the covered action and outcome fields;
- the subject-digest context defined in the Composition Model;
- the AEP signature and chaining construction;
- the predecessor or sequence value that establishes the claimed causal order;
- the platform Evidence format and selected measurements;
- the exact transformation that binds the outcome digest into those
  measurements;
- the attestation key and its trust-chain inputs;
- the freshness value and where it appears in signed Evidence;
- the Verifier and appraisal scheme; and
- any Reference Values, Endorsements, or policy inputs needed to reproduce the
  appraisal.

### Exercised PCR-16 Binding

One exercised AEP/AAC binding folds the raw 32-byte action-response digest from
an Agent Action Capsule ({{I-D.mih-scitt-agent-action-capsule}}) into TPM PCR 16,
starting from the all-zero PCR value, and places the action capsule identifier
in the TPM quote's `extraData`. For SHA-256 this yields:

`PCR16 = SHA-256(0x00 * 32 || response_digest)`

The PCR selection is an instance parameter: this AEP/AAC interop vector uses
PCR 16, while the separate Project Veraison exercise documented in
{{I-D.sokolov-rats-aep-composition}} uses PCR 4.

The quote's signed `pcrDigest` then commits to the selected PCR value. A profile
using this construction MUST distinguish the raw response-digest bytes from
their 64-character hexadecimal display form, identify the PCR selection, and
state whether `extraData` carries a fresh challenge, a unique action identifier,
or another binding value. An identifier provides freshness only when the
relying-party policy ensures that it is fresh for the appraisal.

### Verifier Requirements

A conforming AUDIT verifier MUST report separately:

- whether the AEP signature and hash chain validate, including predecessor and
  sequence checks;
- the subject and outcome digest bytes it recomputed, with their digest
  contexts;
- whether the attestation signature validates under the supplied attestation
  key and whether that key is accepted under the relying party's trust policy;
- whether the quoted PCR digest matches the selected PCR values and whether the
  declared outcome-to-PCR transformation recomputes;
- whether the outcome digest extracted from the action record equals the digest
  bound into the signed platform Evidence under compatible contexts;
- the Verifier's native appraisal result;
- whether freshness was actually enforced by comparing the value recovered
  from the raw signed Evidence with the expected per-appraisal value; and
- the relying party's final acceptance result and policy inputs.

These checks MUST NOT be collapsed into one opaque "audited" boolean. In
particular, an affirming Attestation Result is not evidence of freshness unless
the selected appraisal scheme checked the relevant nonce or the relying party
performed and reported that comparison separately. Re-deriving freshness from
the raw TPM quote bytes is therefore a distinct check when the Attestation
Result does not expose or enforce the quote's signed `extraData`.

### Composition and Transparency Seams

At the composition join, the AUDIT slot exposes the subject digest and context,
the profile label, the authority-reference digest for the native AEP/RATS
evidence, the appraised outcome digest, the freshness result, and the native
appraisal result. If the evidence or a detached digest of it is registered with
a SCITT transparency service, its receipt supplies the separate
receipt-payload digest. The receipt proves registration under the service's
policy; it does not prove that the runtime enforced correctly, that the
attestation was fresh, or that the relying party should accept it.

### Negative Vectors

In addition to the composition-level negative classes, an AUDIT profile MUST
include vectors for at least:

- a changed action or outcome after signing;
- a broken or reordered AEP chain;
- ASCII hexadecimal text substituted for raw digest bytes;
- a changed PCR selection;
- a PCR value inconsistent with the declared extension;
- a quote signature that does not validate;
- a quoted outcome different from the action record's outcome;
- a replayed quote whose signed freshness value differs from the expected
  value;
- an affirming Attestation Result paired with the wrong action evidence; and
- a transparency receipt bound to a different payload.

### Current Assurance Boundary

The exercised first-instance vectors use a virtual TPM (vTPM), including
appraisal by a locally operated Project Veraison instance. They exercise
genuine TPM 2.0 quote structures, attestation-key signatures, digest binding,
appraisal, and negative cases. The evidence bundle does not establish a
manufacturer-provisioned physical TPM root for that vTPM and therefore does not
establish a hardware-rooted guarantee, production readiness, conformance by the
Veraison project, or endorsement by it. A hardware-backed profile would
additionally need to establish its attestation-key provenance, Endorsements,
Reference Values, measured workload coverage, and deployment-specific trust
policy.

The swtpm-based exercise validates the verifier logic and evidence plumbing; it is not evidence of a hardware root of trust.

The first-instance AEP/RATS AUDIT profile and this slot text were contributed by
Anton Sokolov, Tyche Institute.

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
delegation and interactions is developed separately ({{I-D.kuehlewind-audit-architecture}}, with its
interaction, action, delegation, and authorization-transition record types); record and logging formats
and action-lineage protocols are defined in adjacent documents (e.g.,
{{I-D.sharif-agent-audit-trail}}, {{I-D.bates-atp}}, {{I-D.aylward-aiga}} — cited as live adjacent
work, not positioned). The four questions here map onto those record types rather than redefining
them.

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
required. Producer context admitted to any WHAT-leg record follows the capsule
data-admission floor defined in the Privacy Considerations of
{{I-D.mih-scitt-agent-action-capsule}}. [Expand.]

# IANA Considerations

This document has no IANA actions. [A registry of slot identifiers / profile labels
may be proposed in a later revision.]

--- back

# Acknowledgments
{:numbered="false"}

[To be completed with the constituent-profile authors and reviewers, with permission.]
