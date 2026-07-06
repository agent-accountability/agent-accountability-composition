An agent acts across a trust boundary. Some time later, someone who
trusts neither the agent nor its operator needs to answer a simple
question: was this action authorized, and can that be shown without
taking the operator's word for it. Knowing who an agent is, and
confirming it had permission to act, doesn't tell you what it actually
did. That's the gap: identity answers who, authorization answers may —
but nothing confirms whether the action taken matches what was
permitted, and nothing records it.

This has stopped being a someday problem. The EU AI Act's Article 12
record-keeping and automatic-logging obligations for high-risk systems,
paired with Article 26 deployer duties, take effect this year. NIST's AI
Agent Standards Initiative and Singapore's IMDA agentic-AI guidance are
moving in the same direction independently. None of these converge on a
specific format — that convergence is cited here as demand, not as a
compliance claim this document makes on anyone's behalf — but the
direction is consistent: regulators are going to ask deployers of
agentic systems to produce records an outside party can check, not
records the operator merely asserts.

No existing layer answers this alone, and it's worth being precise about
why, since each addresses a real and different concern. Runtime
monitoring detects anomalous behavior as it happens — valuable, but it
produces observability data, not verifiable evidence a skeptical third
party can check independently after the fact. The individual identity
and attestation work underway in WIMSE, RATS, and SCITT each answers a
real piece of the picture — whose workload this is, what posture a
runtime attests to, how a statement gets anchored — but none of them,
alone or informally combined, answers the specific question a regulator
or counterparty actually asks: was this exact action authorized, by
whom, and is the record of what happened tamper-evident. That
composition is the gap this work fills.

Four questions decompose that gap into independently answerable,
independently verifiable parts:

* CAN — was the agent permitted to act?

* WHO — which accountable human authorized this exact action, as
  distinct from which agent carried it out?

* WHAT — what did the agent actually do — a byte-stable serialization
  of the observed action record, not a replay of the action,
  sufficient to judge the outcome?

* AUDIT — did the runtime enforce correctly, in causal order, tamper-
  evidently?

Each question is answerable by an independently-verifiable profile, and
a verifier holding only one profile can verify it without trusting any
other profile's producer. This document does not define new record types
to carry those answers. It composes within the existing audit
architecture — draft-kuehlewind-audit-architecture and the record types
it defines — rather than proposing a second architecture above it. Where
the four questions as stated here and that architecture's record types
conflict, the architecture governs; this section, and this draft, are
written to be reconciled against it, not around it.

An answer to any of these four questions is only useful to an outside
party — someone who trusts neither the agent nor its operator — once
it's registered: filed with a SCITT transparency service under a public
policy, so anyone can independently confirm the filing happened without
having to trust the agent or the operator's word for it. This matters
specifically because the actors being audited are not static. Persistent
memory makes agent behavior path-dependent, and agents rewrite their own
scaffolding and spawn sub-agents — the system acting at step N is not
necessarily the one that would be reviewed at step 0. A registered
record, once anchored, stays tamper-evident and datable to its
registration even as the actor that produced it changes underneath it.
Self-attested records remain valid and useful as a baseline;
registration is what makes the stronger claim reachable and testable,
for any conforming profile, without mandating a particular format.

Two limits matter here, stated plainly. First, a registered record only
proves a signed claim existed at a given time — it doesn't prove the
claim is true. Second, registration stops someone from tampering with a
record after it's filed, but it doesn't guarantee every action that
should have been recorded actually was, and it doesn't rule out a
second, contradictory record existing somewhere else. Making sure
nothing was left out is a separate problem — one for disclosure rules
and monitoring, not something a transparency service can solve on its
own, and not something claimed here.

In short: this section explains why four separate questions are needed,
and what registering an answer to one of them actually gives a skeptical
outside verifier. How the profiles technically link together — the
shared digest, how it's calculated — is a separate, still-open question
the group will work out together in the sections that follow, not
something assumed here.
