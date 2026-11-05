# SafeTrace — Roadmap (v2)

**This version is built around the project description you submitted:** a verified *shield*
between the agent and its tools, a small *policy language* with LTL-style semantics, the shield
*proved correct in Dafny*, an *optional TLA+ cross-check*, and a *Python harness* evaluated
against prompt-injection. The earlier v1 of this file was TLA+-first; that work is not wasted —
TLA+ is now Component C below.

This is a "start here" guide for a complete beginner, and it is also the thing to show the
professor. Section 1 is the one-page version for the meeting; the rest is the real plan behind it.

---

## 1. The one-page version (what to show the professor)

**Problem.** LLM agents browse, read files, and call tools from outputs we cannot predict or
test exhaustively. We cannot verify the LLM. So we treat it as an **untrusted, fully
nondeterministic** component and verify the **shield** that gates its actions: a layer between
the agent and its tools that blocks any action violating a formal safety policy.

**Approach — four components:**

| # | Component | What it delivers | Status |
|---|---|---|---|
| **A** | **Policy language** | a small DSL for safety rules (e.g. "after reading sensitive data, never send to an external host"; "every payment must be preceded by a user confirmation"), with semantics given as **LTL-style trace properties** | core |
| **B** | **Verified shield (Dafny)** | the shield implemented in Dafny, *proved* that for **any** sequence of actions the agent proposes, the trace the shield lets through satisfies the policy | core |
| **C** | **TLA+ cross-check** | model-check the agent+shield composition in TLA+/TLC as an independent confirmation and to produce counterexample traces for broken variants | optional |
| **D** | **Python harness** | compile/port the verified shield to Python, wire it to a real web agent in a local sandbox, evaluate on benign tasks **and prompt-injection attacks** | optional / demo |

**The honest guarantee.** We prove a property of the *shield logic model*, not of the LLM, not
of external APIs, not of the deployed system. We state that boundary explicitly.

**Phasing (realistic for a 2-person beginner team):** core = A + B. C and D are stretch. The
money-shot demo is a **broken shield** that fails verification (Dafny) and/or yields a
counterexample trace (TLA+), showing a bug that testing would almost never catch.

**Two questions to settle with the professor at the meeting** — ask these out loud:
1. Is **Dafny the required verification tool**, or is a policy-language + **TLA+** route acceptable
   on its own? (This changes which component is the core — see the risk note in Section 3.)
2. For a team of two beginners, is **A + B** an acceptable core with **C + D** as stretch, or does
   he expect all four?

---

## 2. The mental model (understand before any tool)

- A **trace** is the sequence of actions that have actually executed so far.
- A **policy** is a property every trace must satisfy — a safety property ("nothing bad ever
  happens"), written in the policy language and meaning an **LTL trace property** underneath.
- The **shield** is a function: given the trace so far and a proposed action, it returns allow or
  deny. It only ever *appends* an allowed action to the trace.
- **The claim we verify:** no matter what the (nondeterministic) agent proposes, every trace the
  shield produces satisfies the policy.
- **Two ways to establish that claim**, and you are using both:
  - **Deductive proof (Dafny):** state an **inductive invariant** on the trace, prove it holds at
    the start, is preserved by every shield-allowed step, and implies the policy. An SMT solver
    (Z3) discharges the proof obligations. This is Component B.
  - **Model checking (TLA+/TLC):** build a finite model and let the tool explore *every* reachable
    state and ordering. This is Component C.

**Blunt difference, and why it matters for your time:** model checking is push-button over a
finite model; deductive proof in Dafny needs you to *invent the invariant* and sometimes hand Z3
hints. Dafny is the harder skill. See Section 3.

---

## 3. Honest risks (read before you commit the plan)

1. **Dafny is the hard part.** Deductive verification for a beginner is a real jump: you write
   invariants, occasionally lemmas, and fight solver timeouts. Budget the most time here, and keep
   policies simple at first. Do **not** promise the professor a finished Dafny proof of several
   policies by a near deadline.
2. **LTL-in-Dafny tension.** LTL trace properties are most naturally handled by a *model checker*
   (TLA+/SPIN), not a deductive prover. Proving an LTL-style property in Dafny means encoding the
   trace semantics and proving an inductive invariant that implies it. Doable, but keep the
   property forms few and simple (safety/precedence), and avoid liveness in Dafny.
3. **Four deliverables is a lot.** A + B + C + D is an ambitious scope for two beginners. Protect
   the core (A + B). Treat C and D as stretch and say so.
4. **Fallback that is already built:** if the Dafny proofs stall, the **TLA+ route is scaffolded**
   in `spec/` and can model-check the same shield + policy and still give a legitimate,
   demonstrable verification result with counterexamples. TLA+ is your safety net, not a detour.

---

## Milestone 0 — Concepts (no software yet)
**Time:** 2–3 hrs. Own these: trace; safety property; LTL at the "always / after / precedes" level;
inductive invariant; deductive proof vs. model checking; where Dafny and TLA+ each fit.
**Checkpoint 0:** explain, in three sentences, (a) what the shield guarantees, (b) the difference
between proving it in Dafny and checking it in TLC, (c) what the guarantee does *not* cover.

## Milestone 1 — Tools, one green example each
**Time:** 1–2 hrs.
- **Dafny:** install VS Code + the **Dafny** extension. Run one tiny verified example (a method
  with a pre/postcondition that verifies, then break the postcondition and watch Dafny reject it).
- **TLA+ (for Component C):** TLA+ Toolbox (IDE + TLC), per `docs/learning-notes.md`.
**Checkpoint 1:** you can make Dafny verify a method, then make it *fail* and read the error. That
"fails to verify" state is the Dafny half of your demo.

## Milestone 2 — Component A: the policy language
**Time:** 3–6 hrs. Define a **small** DSL — a handful of rule templates, each with an LTL meaning:
- `NEVER <action>` → `G ¬ action` (e.g. a blocklisted tool call).
- `<action> REQUIRES-PRIOR <action>` → `G(pay → O confirm)` (payment preceded by confirmation).
- `AFTER <event> NEVER <event>` → `G(readSensitive → G ¬ sendExternal)`.
Write 3–4 concrete example policies in your DSL and their LTL translation beside each. Put this in
`docs/policy-language.md`.
**Checkpoint 2:** for each example policy, state in one line the exact trace that would violate it.

## Milestone 3 — Component B: the Dafny shield (the core work)
**Time:** 8–16 hrs (the big one). In a new `dafny/` folder:
1. Model `Action`, and a trace as `seq<Action>`.
2. Write `PolicyHolds(trace)` as a predicate (start with the `NEVER` policy — easiest).
3. Write the `Shield` step: it appends a proposed action only when allowed.
4. State an **inductive invariant** and prove, with Dafny `assert`s/lemmas, that it holds initially,
   is preserved by every shield-allowed step, and implies `PolicyHolds`.
Start with one policy (`NEVER` / blocklist), get it fully verified, *then* add precedence
(`REQUIRES-PRIOR`), where the shield tracks whether the prerequisite has occurred.
**Checkpoint 3:** Dafny verifies the shield for the blocklist policy with no errors, and you can
point at the invariant line that carries the proof.

## Milestone 4 — The demonstration (money-shot)
**Time:** 1–2 hrs once M3 verifies. Introduce **one** subtle flaw (e.g. the shield checks the
prerequisite but a reordering lets the action slip through). Show either Dafny **failing to
verify** the flawed shield, or — via Component C — **TLC printing a concrete counterexample trace**.
Save it. This is the single most persuasive artifact: testing would almost never hit that ordering.
**Checkpoint 4:** a saved failure (Dafny error or TLC trace) you can walk through step by step.

## Milestone 5 — Component C: TLA+ cross-check (optional, already scaffolded)
Use `spec/AgentGuardrail.tla` (finish `Route`/`Approve`/`Execute`, see the v1 notes in git history)
to model-check the same shield + policy and generate counterexamples for broken variants.
**Checkpoint 5:** TLC runs green on the correct model and red (with a trace) on a broken one.

## Milestone 6 — Component D: Python harness + prompt-injection eval (optional)
Port the verified shield logic to Python, wire it to a simple web agent in a **local sandbox**,
and evaluate on benign tasks and prompt-injection attacks. This is engineering for the demo, not
verification — never let it blur into "so the agent is verified safe." Only the shield *logic* is.
**Checkpoint 6:** the harness blocks a scripted prompt-injection attack that tries a policy-violating
action, and you can show the shield denying it.

## Milestone 7 — Report + viva
Fill `report/OUTLINE.md`. The two sections that earn the grade: **Results** (what you proved in
Dafny / checked in TLC, with the counterexample) and **Limitations & honest scope** (you verified
the shield logic model — not the LLM, not external APIs, not the deployed system).
**Viva questions to rehearse:** why a shield and not "verify the AI"? Why is the agent
nondeterministic? What does your inductive invariant say and why does it imply the policy? Dafny
proof vs. TLC check — when each? What do your bounds / assumptions cost you? Walk me through the
counterexample.

---

## Time budget (honest)

| Phase | Realistic beginner time |
|---|---|
| M0 concepts | 2–3 hrs |
| M1 tools | 1–2 hrs |
| M2 policy language (A) | 3–6 hrs |
| M3 Dafny shield (B) | 8–16 hrs |
| M4 demo | 1–2 hrs |
| M5 TLA+ cross-check (C) | 6–12 hrs (optional) |
| M6 Python harness (D) | 8–15 hrs (optional) |
| M7 report + viva | 4–8 hrs |

Core (A + B + demo + report): **~20–35 hrs**. All four components: **35–60+ hrs** across two
people — a semester project, not a one-week one. Anyone who tells you the Dafny proof is quick is
wrong.

## For the meeting tomorrow
1. Present Section 1 (problem, four components, phasing, honest guarantee).
2. Ask the two questions in Section 1 — especially whether Dafny is required or a TLA+ route is OK.
3. Propose **A + B as the core, C + D as stretch**, and let the professor calibrate the scope.
