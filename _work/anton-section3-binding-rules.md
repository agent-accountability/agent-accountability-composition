<!-- SPDX-License-Identifier: Apache-2.0 -->
# Seed Text: Composition Digest-Binding Rules

This note is proposed seed text for the Composition Model in
`draft-mih-sato-agent-accountability-composition-00`. It defines the three
digest roles, profile-label discipline, and byte-representation rules needed
for cross-profile joins. The ORPRG worked illustration and attribution below
use wording approved by Yong Bok (Scott) Lee.

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

## ORPRG Worked Illustration

On the permit side, the abstract PermitReceipt architecture
([I-D.lee-orprg-permit-receipts]) leaves canonicalization and action-digest
construction to a selected profile; it does not mandate JCS or any other single
canonicalization. A verifier that cannot establish canonicalization-profile
compatibility is required to return DENY rather than treat digest values as
comparable across an unestablished profile boundary.

In the frozen CP-JSON-2 public-evaluation profile
([ORPRG-EVAL-V226])—one evaluation profile of that architecture, not a universal
construction of it—the action digest is the 64-character lowercase hexadecimal
encoding of SHA-256 over the exact canonical request bytes. That profile
prepends no additional domain-separation bytes to the action-digest preimage.

This profile-specific construction does not imply byte identity with JCS-based
profiles. For a particular test vector, digest equality across profiles may
serve as a direct join for that vector only when the complete digest contexts
are compatible and the compared preimage byte sequences are demonstrated to be
identical. Relevant context includes the field set, digest algorithm,
canonicalization profile, domain-separation rule, encoding, and digest
representation. Otherwise, the profiles compose through an explicit,
cryptographically protected cross-reference.

In [ORPRG-EVAL-V226], `receipt_core.action_digest` is the unprefixed 64-character
lowercase hexadecimal text, while `authorization_ref.action_commitment` is the
literal ASCII prefix `sha256:` followed by the same 64 hexadecimal characters.
Neither textual representation is the raw 32-byte digest.

The digest preimage is the exact byte sequence designated by the selected
profile or frozen vector. Human-readable renderings, pretty-printed documents,
console output, and files containing added line terminators are not
interchangeable with that preimage unless the profile explicitly designates
those exact bytes.

ORPRG profile-specific worked illustration based on
[I-D.lee-orprg-permit-receipts] and [ORPRG-EVAL-V226]. The permit-side
construction and the ORPRG-specific implementation facts concerning profile
compatibility and digest representation reflected in this illustration were
identified and documented in the permit-side review and were supplied and
owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity Group.

## Review Provenance and Scope

The cross-profile binding discussion in this section was informed by the ORPRG
row of a versioned digest-binding matrix and by the subsequent multi-party
composition review. The ORPRG row and its supporting permit-side observations
were supplied and owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity
Group.

This illustration states profile-specific implementation facts. It makes no CAN
slot proposal, conformance or interoperability claim, endorsement claim,
production-readiness claim, joint-ownership claim, or patent or license claim.

References:

- [I-D.lee-orprg-permit-receipts]:
  https://datatracker.ietf.org/doc/draft-lee-orprg-permit-receipts/
- [ORPRG-EVAL-V226]:
  https://github.com/meridianverity/permit-receipt/releases/tag/v2.2.6-public-eval
  (`permit-receipt-ref-eval-v2_2_6-public-eval.zip`, SHA-256
  `e5c40eca74fe2f451a0723db915c64b201e1d52f382cee24062e4dfc61fc632f`)


---

# PM CONTEXT NOTES (not Anton's text — appended at file-drop 2026-07-27)
1. Provenance: Anton Sokolov's Section 3 digest-binding rules import (the v0.3 matrix work productized as seed text); file supplied by Steven from email. Its own header states the ORPRG worked illustration and attribution wording are Scott-approved — the Jul 18 condition ("Scott's nod before Scott-confirmed rows appear") is satisfied on its face; coder cross-checks the ORPRG wording against anton-section3-illustration.md (same approved language should match).
2. Fold SUBSTANTIVELY UNCHANGED. This supplies the Section 3 deferred items named in -00: three-digest binding rules, profile-label discipline, raw-bytes-vs-ASCII-hex rules.
