# Specifications

This folder holds the TLA+ specifications and their TLC model-check configurations.

Planned files:

- `AgentGuardrail.tla` — the core model: the agent's decision loop and the guardrail that
  gates its actions. The language model is modelled as a nondeterministic actor that may
  propose any action from the action set.
- `AgentGuardrail.cfg` — the TLC configuration: constants (the action set, the blocklist,
  bounds), the initial predicate, the next-state relation, and the invariants/properties
  to check.
- Later: a `*_Broken.tla` variant with a deliberately introduced flaw, to produce a
  counterexample trace for the demonstration.

## The model, in words (to be formalised)

**State variables (first draft):**
- `pc` — where the agent is in its loop (`Idle`, `Proposed`, `AwaitingApproval`, `Done`).
- `proposed` — the action the model has currently proposed (or none).
- `approvals` — the set/record of approvals granted and whether each has been consumed.
- `executed` — the log of actions actually executed.

**Transitions (first draft):**
- *Propose*: nondeterministically pick any action `a` from `Actions` and propose it
  (this stands in for the adversarial language model).
- *Classify/Route*: the guardrail classifies `a` (reversible / irreversible / blocklisted)
  and routes it — blocklisted is rejected, irreversible needs approval, reversible may run.
- *Approve*: grant an approval for a pending irreversible action.
- *Execute*: execute an action **only** when the guardrail's precondition holds.

**Properties to check** (see the project README for the formal statements): no irreversible
action without approval; no blocklisted action ever; no approval reuse; (stretch) liveness.

## Keeping the state space finite

TLC explores every reachable state, so we must keep the model small and bounded — a handful
of action types and at most one or two concurrent requests — or the state space explodes.
The bounds we choose, and what they do and do not let us conclude, will be documented here
and in the report.
