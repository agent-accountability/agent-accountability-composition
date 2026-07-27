<!-- SPDX-License-Identifier: Apache-2.0 -->
# Seed Text: The CAN Slot — MachineMandate Action-Bound Authority

This note is proposed seed text for Section 5.1 of
`draft-mih-sato-agent-accountability-composition-00`. It describes
MachineMandate as one first-instance CAN profile. It does not define the CAN
slot, assign the slot to one format, or supply PermitReceipt-specific text.

## Design Rule

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

## Producer Requirements

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

## Verifier Requirements

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

```text
CAN = ALLOW
    iff reference_bound
    and native_credential_appraised
    and action_commitment_matches
    and every required_scope_gate_passes
    and relying_party_policy_accepts
```

The CAN verifier evaluates the action presented to the relying party, not a
value supplied by the agent as an asserted hash. The relying party MUST
reconstruct the profile-defined action projection from the request it is about
to authorize, compute the commitment itself, and use the same request values
for all scope gates. It MUST bind an ALLOW result to that request and MUST NOT
reuse the result for a changed action. If effect commitment is delayed beyond
the recorded policy-evaluation time, or if a relevant credential, status, or
policy input can have changed, the relying party MUST re-evaluate before
committing the effect.

## Separation from WHO and AUDIT

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

## Frozen IETF 126 Illustration

One frozen, pre-execution MachineMandate vector uses the credential type:

```text
https://vocab.tyche.institute/vct/machine-mandate
```

Its composition reference commits to the exact 1190-byte issuer-signed JWT
component of the SD-JWT presentation. That component has SHA-256:

```text
5df4d32df57650f27b6a65df041b708de80d69c0ca82a1044334f5e2edef5ce2
```

The authority-reference field carries that digest as unprefixed lowercase
hexadecimal text under an explicitly declared SHA-256 digest context. It is
distinct from the prefixed textual action commitment below.
Because this stable reference covers only the issuer-signed component, it does
not by itself commit to the selected disclosures, Key Binding JWT, verifier
nonce, or audience of a particular presentation. A record claiming
`machine_mandate_appraised` MUST preserve and integrity-protect that separate
presentation evidence.

The action-commitment profile in that vector covers the 91 UTF-8 bytes of:

```json
{"action_id":"pay-invoice/acme-corp","outcome":"eur:250:acme-corp:vienna-interop-2026-001"}
```

and carries the textual commitment:

```text
sha256:a89fbd2bd6f95cdb1ec27b6c7253770ff2a22220937cf065f6e45ef67b37e299
```

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

## Composition and Transparency Seams

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

## Negative Vectors

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

## Current Assurance Boundary

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
for conformance to RFC 8785, RFC 9901,
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

References:

- [MACHINE-MANDATE]:
  https://github.com/tyche-institute/machine-mandate
- [RFC8785]: https://www.rfc-editor.org/rfc/rfc8785.html
- [RFC9901]: https://www.rfc-editor.org/rfc/rfc9901.html
- [I-D.ietf-oauth-sd-jwt-vc-17]:
  https://datatracker.ietf.org/doc/html/draft-ietf-oauth-sd-jwt-vc-17
- [OpenID4VP]:
  https://openid.net/specs/openid-4-verifiable-presentations-1_0-final.html


---

# PM CONTEXT NOTES (not Anton's text — appended at file-drop 2026-07-27)
1. Provenance: delivered by Anton Sokolov per his Jul 18 offer (CAN 5.1, one instance for the slot); file supplied by Steven from email. Fold SUBSTANTIVELY UNCHANGED per the Jul 18 co-author approvals and their boundaries (Songbo's technical acceptance checks apply — verify against his Jul 18 email).
2. COMPLETE for 5.1. Still missing from _work/: anton-section54-audit.md (the AUDIT text — PCR-16 / swtpm / Veraison / AEP). The Section 3 worked illustration is already at anton-section3-illustration.md. If the Section 3 digest-binding matrix import (v0.3) was a separate delivery, it is also still pending — coder flags if Section 3 assembly needs it.
3. Note the text's own discipline: frozen credential expired 2026-07-24 (historical vector expectations, fine); it explicitly claims NO composition result and records the failed 2026-07-23 coordinate honestly — consistent with the composition record and Scott's INTEROP.md wording. Nothing here contradicts the HOLD posture.
4. The attribution line is self-carried in the text ("contributed by Anton Sokolov, Tyche Institute") — keep it; fixes the Shkrob placeholder on this slot too.
