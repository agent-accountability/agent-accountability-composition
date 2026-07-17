<!-- SPDX-License-Identifier: Apache-2.0 -->
# Seed Text: The WHAT Leg — Content-Addressed Action Digest

This note is proposed seed text for `draft-mih-sato-agent-accountability-composition-00`.
It is scoped to the WHAT leg: what did the agent actually do — a byte-stable
serialization of the *observed* action record, not a replay.

## Design Rule

The WHAT leg is one participating accountability profile at the composition seam.
It answers a single question: *what did the agent actually do*, expressed as a
digest any party holding the same preimage fields can independently recompute. It
is deliberately narrow:

- It does NOT judge whether the agent was permitted to act (CAN), whether a human
  authorized it (WHO), or whether the runtime enforced correctly (AUDIT). Those
  are different legs.
- It commits only to the observed action bytes. Digest equality is a join key —
  it does not, by itself, prove the action was authorized, permitted, or
  sufficient.
- It is a concrete instance of this document's `subject_digest =
  SHA-256(JCS(action))` join key (Composition Model): this leg is the definition
  of what "action" concretely means in that formula, not a competing formula.

The native WHAT record is `action_ref`: the SHA-256 digest of the RFC 8785 (JCS)
canonical serialization of a fixed four-field tuple, verifiable offline by any
party holding the same four fields.

## Conformance Classes

### WHAT Producer

A WHAT Producer emits an `action_ref` and its preimage.

A conforming WHAT Producer MUST state:

- the four preimage fields and their exact string forms:
  - `agent_id` — the terminal executing agent after full delegation resolution
    (not the original delegator; not a display label);
  - `action_type` — the semantic label for what the agent did;
  - `scope` — the terminal executing agent's requested-intent label at the point
    of action (free-form, non-empty; pass `""` if not applicable);
  - `timestamp` — RFC 3339 UTC with exactly 3-digit millisecond precision and a
    mandatory `Z` suffix (`YYYY-MM-DDTHH:MM:SS.mmmZ`) — one valid byte sequence
    per instant, closing the offset-vs-`Z` and fractional-precision ambiguity
    RFC 3339 otherwise admits;
- the canonicalization rule (RFC 8785 JCS: lexicographic key order, no
  whitespace, UTF-8) and the digest algorithm (SHA-256);
- the profile's declared domain (ASCII-only field values, the conformant
  timestamp grammar, no surrogate-pair Unicode, no `-0.0`) — this is the full
  domain, not a convenience subset; and
- the failure behavior when a preimage field falls outside that domain: reject
  with an explicit out-of-profile-domain result before any digest comparison,
  never best-effort canonicalize or delegate to a different implementation's
  string handling.

### WHAT Verifier

A WHAT Verifier recomputes `action_ref` independently of the producer.

A conforming WHAT Verifier MUST be able to produce a result that states:

- whether it could recompute byte-identical output from the stated preimage;
- the exact digest bytes it computed and the canonicalization/hash parameters
  used;
- for a presented `action_ref` that diverges from a recomputed one under
  otherwise-matching context, which preimage field diverged — not a single
  opaque pass/fail. In particular:
  - a **rescoped replay**: an attestation issued for one `scope`, presented
    against another — recomputing `action_ref` over the presented tuple
    diverges from the embedded one;
  - **semantic drift**: `action_type` that changed between issuance and
    verification, yielding a divergent digest for one logical action; and
- whether the preimage falls within the profile's declared domain (an
  out-of-domain result is distinct from a digest mismatch).

The WHAT Verifier MUST keep domain validation, canonicalization, and digest
recomputation as separate results. It MUST NOT collapse them into a single
opaque "valid" boolean.

## Conformance is byte equality, not self-attestation

Conformance is expressed as a versioned, third-party-checkable record rather
than a number restated in prose (a number in a standards document goes stale;
a live record does not): the spec is
[`action-ref.md`](https://github.com/giskard09/argentum-core/blob/main/docs/spec/action-ref.md)
(stable ref `action-ref-v1.0`), and the conformance vectors are at
[`examples/conformance/`](https://github.com/giskard09/argentum-core/tree/main/examples/conformance)
in the same repository — any party may recompute against them and compare
byte-for-byte, the same bar this composition's own Conformance section asks of
a frozen vector (recomputed by at least two independent implementations).

## The WHAT Reference at the Seam

To let a Composition Verifier join a WHAT record to other legs, the WHAT leg
exposes a minimal reference:

- the digest itself (the shared join key) and its declared digest context
  (algorithm, canonicalization rule, profile version);
- the four preimage fields, or, under selective disclosure, a commitment to
  them; and
- the domain-validity assertion: that all preimage fields fell within the
  profile's declared domain at production time.

The reference carries no authorization claim, no permission verdict, and no
sufficiency claim — those belong to the CAN, WHO, and AUDIT legs respectively.

In addition to the composition-level negative classes (see Conformance), a
WHAT profile MUST reject each of the following, and the verifier MUST report
which check failed: a preimage field outside the declared domain (non-ASCII
where the profile requires ASCII; malformed timestamp grammar; an alternative
RFC 3339 encoding of the same instant); a rescoped replay; semantic drift; and
a presented digest that does not recompute from the stated preimage under the
declared canonicalization and hash parameters.
