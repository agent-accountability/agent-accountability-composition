# Interoperability Evidence

Rows record cross-implementation test runs, framework reviews, and artifact verifications
against the composition model's shared digest discipline. Each row is pending counterparty
confirmation before freeze; coordinates link to the public record from which the claim is
drawn. Claims never outrun the linked artifact.

**Evidence ladder:**
- `independently ran and verified` — byte-level agreement under stated digest context,
  two independent codebases, public artifact coordinates.
- `framework mapping reviewed` — an external review framework was applied; no
  byte-agreement result is claimed.
- `reference suite replayed` — an independent replay of a published reference suite;
  subject to the caveats stated in the row.

Status key: `pending confirmation` = a recorded run — row drafted from public record,
counterparty confirmation not yet received; `confirmed (<name>, <date>)` = confirmed by
the named counterparty on the stated date; `reviewed` = framework review completed as
stated.

---

## Rows

### two-TS — Microsoft CCF Two-Transparency-Service Vector

| Field | Value |
|---|---|
| ID | two-TS |
| Description | AAC Class-1 shared vector registered to Microsoft CCF ledger; cross-TS receipt verified against scitt-cose |
| Type | cross-implementation |
| Evidence coordinates | `microsoft/scitt-ccf-ledger` PR #4; `shared-vector.json` in that PR |
| Digest context | ccf.v1 + RFC9162_SHA256 |
| Status | **pending Tom Sato confirmation** |
| Notes | Row drawn from public record. Counterparty confirmation required before freeze. |

### APS — Agent Passport System Bidirectional

| Field | Value |
|---|---|
| ID | APS |
| Description | Agent Passport System bidirectional AUDIT-prep run; both run pins recorded |
| Type | cross-implementation |
| Evidence coordinates | [AUDIT-prep issue #9, pinned run exchange](https://github.com/mirjak/audit-bof-preparation/issues/9#issuecomment-5028863240): APS corpus `4b9dbb0`, AAC runner `43b6eba`; ASG vectors `529515b`, APS verifier `139c78a` |
| Digest context | As recorded for each linked run; profile-boundary differences are not silently treated as failures |
| Status | **pending Tymofii Pidlisnyi (aeoess) confirmation of this row** |
| Notes | The linked exchange records both run directions. It is not confirmation of this final Composition row; obtain the named counterparty's review before freeze. |

### GAR — GAR Session Block Seal

| Field | Value |
|---|---|
| ID | GAR |
| Description | GAR Session Block seal at leaf 166; gar-core.ts verified at commit fe18f24 |
| Type | cross-implementation |
| Evidence coordinates | leaf 166 in the GAR transparency log; `gar-core.ts` at commit `fe18f24` |
| Digest context | per gar-core.ts @ fe18f24 |
| Status | **pending Tom Sato confirmation** |
| Notes | Row drawn from public record. Tom Sato confirmation required before freeze. |


### PB — Principal-Binding Review (Bu)

| Field | Value |
|---|---|
| ID | PB |
| Description | Songbo Bu's principal-binding review framework applied to the WHO-slot mapping |
| Type | framework-review |
| Evidence coordinates | `draft-bu-agentproto-security-principal-binding-03`; AAC Class-1 repository commit `10342f504b051a24908053465927efdaea3ec2f6` |
| Digest context | n/a (framework review, not byte-agreement) |
| Status | **confirmed (Songbo Bu, 2026-08-18)** |
| Notes | **Must not say "ran and verified."** Verifier-facing claim, carrier, verifier, binding, accepted-result, and failure boundaries from `draft-bu-agentproto-security-principal-binding-03` were used to review the WHO-slot mapping. The AAC Class-1 repository was independently replayed at the stated commit, but no independent principal-binding byte-agreement result is claimed. Status: framework mapping reviewed; AAC reference suite independently replayed. |

---

*Freeze discipline: no row is frozen until its counterparty has confirmed the row text.
Rows pending confirmation are clearly marked. HOLD discipline absolute on anything
three-way until owners' review completes.*
