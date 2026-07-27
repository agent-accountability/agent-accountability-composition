<!-- SPDX-License-Identifier: Apache-2.0 -->
# Seed Text: The AUDIT Slot — AEP/RATS Runtime-Evidence Binding

This note is proposed seed text for Section 5.4 of
`draft-mih-sato-agent-accountability-composition-00`. It is scoped to Anton
Sokolov's proposed first-instance profile: application-layer action evidence
composed with RATS Evidence and an Attestation Result. It deliberately states
the current vTPM assurance limit in the body.

## Design Rule

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
([I-D.sokolov-rats-aep-composition], using the roles and trust model of
[RFC9334]). The AEP is a signed, append-only record of the action, its
authority, and its outcome. Platform Evidence binds an AEP outcome digest and a
fresh per-appraisal value into data covered by an attestation-key signature.
The resulting profile lets a verifier check that the same outcome named by the
action record was present in the appraised execution context. It does not make
the AEP producer or the Attester a truth oracle.

## Producer Requirements

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

## Exercised PCR-16 Binding

One exercised AEP/AAC binding folds the raw 32-byte action-response digest from
an Agent Action Capsule ([I-D.mih-scitt-agent-action-capsule]) into TPM PCR 16,
starting from the all-zero PCR value, and places the action capsule identifier
in the TPM quote's `extraData`. For SHA-256 this yields:

`PCR16 = SHA-256(0x00 * 32 || response_digest)`

The PCR selection is an instance parameter: this AEP/AAC interop vector uses
PCR 16, while the separate Project Veraison exercise documented in
[I-D.sokolov-rats-aep-composition] uses PCR 4.

The quote's signed `pcrDigest` then commits to the selected PCR value. A profile
using this construction MUST distinguish the raw response-digest bytes from
their 64-character hexadecimal display form, identify the PCR selection, and
state whether `extraData` carries a fresh challenge, a unique action identifier,
or another binding value. An identifier provides freshness only when the
relying-party policy ensures that it is fresh for the appraisal.

## Verifier Requirements

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

## Composition and Transparency Seams

At the composition join, the AUDIT slot exposes the subject digest and context,
the profile label, the authority-reference digest for the native AEP/RATS
evidence, the appraised outcome digest, the freshness result, and the native
appraisal result. If the evidence or a detached digest of it is registered with
a SCITT transparency service, its receipt supplies the separate
receipt-payload digest. The receipt proves registration under the service's
policy; it does not prove that the runtime enforced correctly, that the
attestation was fresh, or that the relying party should accept it.

## Negative Vectors

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

## Current Assurance Boundary

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

The first-instance AEP/RATS AUDIT profile and this slot text were contributed by
Anton Sokolov, Tyche Institute.

References:

- [I-D.sokolov-rats-aep-composition]:
  https://datatracker.ietf.org/doc/draft-sokolov-rats-aep-composition/
- [I-D.mih-scitt-agent-action-capsule]:
  https://datatracker.ietf.org/doc/draft-mih-scitt-agent-action-capsule/
- [RFC9334]: https://www.rfc-editor.org/rfc/rfc9334.html


---

# PM CONTEXT NOTES (not Anton's text — appended at file-drop 2026-07-27)
1. Provenance: Anton Sokolov's 5.4 AUDIT delivery per his Jul 18 offer; file supplied by Steven from email. Fold SUBSTANTIVELY UNCHANGED. Governing boundary from the Jul 18 approvals: IMAN'S CONDITION — the emulated-swtpm/vTPM assurance limit must be stated in the body of the text itself (it is; verify it survives the fold). Songbo's Jul 18 AUDIT acceptance checks apply.
2. This completes the three Anton deliveries: Section 3 illustration (anton-section3-illustration.md), Section 3 binding rules (anton-section3-binding-rules.md), 5.1 CAN (anton-section51-can.md), 5.4 AUDIT (this file). -01 assembly fully unblocked.
