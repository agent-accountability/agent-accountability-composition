# Composition -01 fold-in — source-vs-fold fidelity report

Task: `[composition-01-fold-fidelity]`. Adversarial clause-by-clause comparison of the
`composition-01-foldin` fold (`bbddf67`) against Anton Sokolov's three source files
(`_work/anton-section3-binding-rules.md`, `anton-section51-can.md`, `anton-section54-audit.md`)
and Songbo Bu's four Jul-18 acceptance checks (`_work/songbo-jul18-acceptance-checks.md`).

## Bottom line

The fold is **substantively faithful — a near-verbatim carry of Anton's CAN, AUDIT, and
Section-3 normative text**, NOT a condensation. The PM's four suspected drops are all in fact
**present/verbatim** (see adjudication). Three fixes were required and **have been applied on
`composition-01-fold-fidelity`**; one Songbo-Check-1 item is a **co-author gap** (not in
Anton's source either) and is flagged for Steven/Anton — NOT inserted autonomously.

## PM-flagged four items (adjudication)

| # | Item | Verdict |
|---|---|---|
| a | raw-bytes vs 64-ASCII-hex "MUST NOT be substituted" | PRESENT / VERBATIM (§3) |
| b | hardware-root disclaimers | CAN "not a manufacturer-provisioned physical TPM" PRESENT/VERBATIM (§5.1); AUDIT vTPM limit PRESENT/VERBATIM (§5.4). The specific **swtpm-≠-hardware-root** framing Songbo Check 1 wants is **ABSENT — and was never in Anton's AUDIT source** → RESTORE-1 (co-author) |
| c | CAN scope-gate specifics (allowed_actions, max_spend, machine_mandate_spend) | PRESENT / VERBATIM (§5.1, incl. the four named gates + the frozen over-limit case) |
| d | "one instance, not the slot definition" normative sentence | PRESENT / VERBATIM (§5.1: "MachineMandate is one CAN instance, not the CAN slot…") |

## Fixes applied (this branch, `composition-01-fold-fidelity`)

- **RESTORE-2 (structure):** restored the demoted `### Current Assurance Boundary` heading in §5.4 — the vTPM assurance-boundary paragraph had been hanging under `### Negative Vectors`.
- **RESTORE-3 (dropped source text):** restored Anton/Scott's §3 no-claims disclaimer to the Worked Profile Illustration: "This illustration states profile-specific implementation facts. It makes no CAN slot proposal, conformance or interoperability claim, endorsement claim, production-readiness claim, joint-ownership claim, or patent or license claim."
- **Fold-introduced conflict (removed):** the fold coder had *added* a preamble line `subject_digest = SHA-256(JCS(action))` that contradicted Anton's profile-defined `HASH(subject_preimage)` + "JCS … is not imposed." Reworded the preamble to defer to the per-profile definition; also removed the duplicated "Digest equality is a join key…" paragraph (Anton's authoritative copy remains in Three Digest Roles).

## Flagged — NOT applied (co-author decision)

- **RESTORE-1 (Songbo Check 1 blocker):** the "where a software TPM (`swtpm`) is used, it validates the composition plumbing and verifier logic but is NOT evidence of a hardware trust root" statement is **missing from §5.4 AUDIT and absent from Anton's AUDIT source** (his source frames only vTPM; the `swtpm` mention lives in the CAN source's assurance boundary). Songbo Check 1 explicitly requires it. This is a **content addition to Anton's contributed slot**, so it needs Anton/PM sign-off (or framing as Songbo's requested amendment that Anton accepts) — it is not a mechanical restore and was deliberately not inserted.

## Songbo four-check verdict (post-fix)

| # | Check | Verdict |
|---|---|---|
| 1 | AUDIT separation + swtpm≠hw-root + nonce/quote/PCR-16/outcome binding + scope-bound result | **PARTIAL** — separation, binding, scope-bound all SATISFIED (verbatim); swtpm≠hw-root MISSING → RESTORE-1 (co-author) |
| 2 | CAN one-instance; no normative dep on SD-JWT VC/OpenID4VP; four gates each name input+rejection+result | **SATISFIED** |
| 3 | §3 pins bytes/algorithms/domain-sep/version/raw-vs-hex; digest = join key only | **SATISFIED** (JCS-preamble hazard now removed) |
| 4 | §7 conformance vectors (positive + per-gate rejection + replay/freshness + permit-ref + 64-hex-vs-32-raw) | **OUT OF SCOPE** — §7 vector suite; Songbo scoped it to a separate import PR; not part of this fold |

Deliverables committed to this branch: this report, the re-rendered `.txt` + `.xml`, and
`diff-composition-00-to-01.txt` (regenerated). Worktree HELD for manager review.
