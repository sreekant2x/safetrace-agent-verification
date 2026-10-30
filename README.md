# SafeTrace — Formal Verification of Safety Guardrails for LLM Agents

**Team:** SafeTrace
**Course:** Software Verification — MSc Computer Science, RPTU Kaiserslautern-Landau
**Method:** Model checking with TLA+ / TLC

---

## What this project is

Autonomous LLM-based agents increasingly take real actions — calling APIs, sending
messages, modifying data — based on model outputs we cannot predict or test
exhaustively. The safety of such a system **cannot rest on the language model being
"well-behaved."** It must rest on the **guardrail logic** that decides which proposed
actions are actually executed.

Ordinary testing cannot establish this, because an unsafe behaviour may depend on a
specific ordering of events (e.g. a race between an approval check and an execution step)
that a test suite never happens to trigger.

So we do **formal verification**, not testing. We model the guardrail/orchestration layer
of an LLM agent as a state-transition system in **TLA+**, treat the language model itself
as an **adversarial, nondeterministic actor** that may propose *any* action, and use the
**TLC model checker** to verify — across *all* reachable states and *all* interleavings —
that the system can never violate a set of precisely stated safety constraints.

## What we are (and are not) verifying

> **We verify the guardrail logic, not the language model.**

This distinction is the heart of the project and we are strict about it:

- **In scope:** the control/orchestration logic that gates the agent's actions. We prove
  it cannot be driven into an unsafe state *no matter what the model proposes*.
- **Out of scope:** the real-world behaviour of the language model, the correctness of any
  external API, and anything we did not model. A machine-checked guarantee about our model
  is **not** a guarantee that a deployed agent is "safe" or "ethical." We will state the
  boundary of our guarantee explicitly in the report.

## Safety properties we intend to prove

1. **No irreversible action executes without a recorded approval.**
   `□ (Executed(a) ∧ Irreversible(a) ⇒ ApprovalGranted(a))`
2. **No blocklisted action ever executes.**
   `□ ¬ (Executed(a) ∧ a ∈ Blocklist)`
3. **One approval authorises at most one action (no replay).**

**Stretch goals** (we have the time budget for these): a **liveness** property (every
legitimate request eventually executes or is rejected — no deadlock), and a small
**Python harness** that wires a real LLM agent to the exact guardrail logic verified here,
so the demo shows the verified model and a running system side by side.

## The demonstration

To show *why* model checking beats testing, we will introduce a **subtle flaw** into the
guardrail (for example, making the approval check and the execution step non-atomic) and
show that **TLC automatically produces a concrete counterexample trace** — the exact
sequence of steps by which a forbidden action slips through. Testing would almost never
find this; the model checker finds it mechanically.

## Repository structure

```
spec/     TLA+ specifications (.tla) and TLC model configs (.cfg)
docs/     Learning notes, design decisions, references
report/   The project report and its outline
```

## Status

Early stage. Topic locked and proposal submitted; TLA+ modelling begins next. See
`docs/learning-notes.md` for the learning roadmap.

## Getting started with the tools

- **TLA+ Toolbox** (IDE + TLC model checker): https://lamport.azurewebsites.net/tla/toolbox.html
- **Learn TLA+** (Hillel Wayne, the recommended beginner tutorial): https://learntla.com/
- **Official TLA+ site** (Leslie Lamport): https://lamport.azurewebsites.net/tla/tla.html

## Team members

- Sreekant Saha — sreekantsaha2024@gmail.com
- Manish  —
