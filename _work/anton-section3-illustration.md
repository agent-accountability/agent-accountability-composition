# Anton Sokolov — Section 3 PermitReceipt profile-specific worked illustration (VERBATIM SOURCE for composition -01)
Provenance: email from Anton Sokolov <anton.sokolov@tyche.institute> to steven@actionstate.ai, 2026-07-27, transcribed verbatim by PM at Steven's request (file-drop). Carries Scott Lee's owner approval per its own first line. Eng: fold the illustration text, informative reference, attribution, and acknowledgment SUBSTANTIVELY UNCHANGED; this replaces the "Anton Shkrob" placeholder scaffolding (fix the surname to Sokolov everywhere).

---

Hi Steven,

Per Scott Lee's owner approval, here is the Section 3 PermitReceipt profile-specific worked illustration for inclusion in the -01. The wording, informative reference, attribution, and acknowledgment are carried substantively unchanged. This is a profile-specific illustration only; it makes no composition-result, interoperability, conformance, joint-ownership, or production-readiness claim.

On the permit side, the abstract PermitReceipt architecture ([I-D.lee-orprg-permit-receipts]) leaves canonicalization and action-digest construction to a selected profile; it does not mandate JCS or any other single canonicalization. A verifier that cannot establish canonicalization-profile compatibility is required to return DENY rather than treat digest values as comparable across an unestablished profile boundary.

In the frozen CP-JSON-2 public-evaluation profile ([ORPRG-EVAL-V226]) — one evaluation profile of that architecture, not a universal construction of it — the action digest is the 64-character lowercase hexadecimal encoding of SHA-256 over the exact canonical request bytes. That profile prepends no additional domain-separation bytes to the action-digest preimage.

This profile-specific construction does not imply byte identity with JCS-based profiles. For a particular test vector, digest equality across profiles may serve as a direct join for that vector only when the complete digest contexts are compatible and the compared preimage byte sequences are demonstrated to be identical. Relevant context includes the field set, digest algorithm, canonicalization profile, domain-separation rule, encoding, and digest representation. Otherwise, the profiles compose through an explicit, cryptographically protected cross-reference.

In [ORPRG-EVAL-V226], receipt_core.action_digest is the unprefixed 64-character lowercase hexadecimal text, while authorization_ref.action_commitment is the literal ASCII prefix sha256: followed by the same 64 hexadecimal characters. Neither textual representation is the raw 32-byte digest.

The digest preimage is the exact byte sequence designated by the selected profile or frozen vector. Human-readable renderings, pretty-printed documents, console output, and files containing added line terminators are not interchangeable with that preimage unless the profile explicitly designates those exact bytes.

Informative reference:

[ORPRG-EVAL-V226] Meridian Verity Group, "v2.2.6 Public Evaluation — IETF 126 PermitReceipt Review Packet," frozen public-evaluation release, tag v2.2.6-public-eval, public-evaluation ZIP permit-receipt-ref-eval-v2_2_6-public-eval.zip, ZIP SHA-256 e5c40eca74fe2f451a0723db915c64b201e1d52f382cee24062e4dfc61fc632f, 10 July 2026, https://github.com/meridianverity/permit-receipt/releases/tag/v2.2.6-public-eval

Attribution:

"ORPRG profile-specific worked illustration based on [I-D.lee-orprg-permit-receipts] and [ORPRG-EVAL-V226]. The permit-side construction and the ORPRG-specific implementation facts concerning profile compatibility and digest representation reflected in this illustration were identified and documented in the permit-side review and were supplied and owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity Group."

Acknowledgment:

"The cross-profile binding discussion in this section was informed by the ORPRG row of a versioned digest-binding matrix and by the subsequent multi-party composition review. The ORPRG row and its supporting permit-side observations were supplied and owner-confirmed by Yong Bok (Scott) Lee, Meridian Verity Group."

Best,
Anton

---

# PM CONTEXT NOTES (not Anton's text)
1. This also ANSWERS the open CPB question: [ORPRG-EVAL-V226] with ZIP SHA-256 e5c40eca... IS the immutable public source for CP-JSON-2 provenance — owner-supplied via Anton with Scott's approval. The CPB -01 (Scott closures branch) currently uses Scott's safe-default rephrase; if Scott confirms in his reply, the citation can swap in per the offer already made to him. Do NOT swap without Scott's word.
2. Co-author boundaries from Jul 18 still govern the fold-in (Iman's emulated-swtpm caveat on 5.4; Songbo's technical acceptance checks; Tom's assent).
3. Sections 5.1 (CAN) and 5.4 (AUDIT) source texts still pending file-drop.
