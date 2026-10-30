# SafeTrace — Roadmap from Zero

This is your single "start here" guide. It assumes you know **nothing** about TLA+ or
formal verification, and it is tied directly to the files already in this repo. Work
through it top to bottom. Every milestone ends with a **checkpoint** — a thing you must be
able to *do* or *explain* before moving on. If you can't pass a checkpoint, don't advance;
the next step won't make sense.

---

## 0. Read this first — the deadline reality (no sugarcoating)

You said the deadline "moved to today." There are two very different things that could mean,
and the honest answer depends on which one:

- **If "today" is the idea / proposal submission** (team name, members + emails, topic,
  short description, Git repo link): **you are already done.** The repo, README, scope, and
  learning plan all exist. Fill in your teammate Manish's email in `README.md`, and submit
  the repo link. Nothing in this roadmap blocks that. Go submit it.

- **If "today" is the *finished, verified project* with report and demo:** be realistic —
  that is **not achievable from zero in one day**, and pretending otherwise would set you up
  to fail a viva you can't fake. Full model checking from a standing start is days of
  learning plus days of modelling. Anyone claiming a beginner can produce a defensible
  TLA+ verification project in an afternoon is lying to you.

**What you *can* truthfully achieve in one focused day** (≈6–8 hrs) if forced: install the
tools, finish the spec's three TODO actions, get TLC to go green on properties 1 and 2, and
capture one counterexample from a broken variant. That is a real, demonstrable result. The
report polish, non-replay property, liveness, and Python harness are *not* one-day work.

Decide which deadline you're actually facing before you touch anything else. The rest of
this roadmap is the real, honest arc — not a one-day crash plan.

---

## 1. The one-paragraph mental model (understand this before any tool)

You are **not** verifying that an AI is "safe" or "ethical." You are building a small
**state machine** that represents the *guardrail* sitting between an LLM and the real world.
The LLM is modelled as an adversary that can propose **any** action at any time. The
guardrail decides what actually runs. You then ask a tool (**TLC**) to mechanically check
*every reachable state and every ordering of events* and confirm the guardrail can never be
pushed into a forbidden state (e.g. a dangerous action executing without approval). Testing
tries *some* orderings; model checking tries *all* of them, within the bounds you set. That
"all of them, within stated bounds" is the entire value proposition — and the honesty about
the bounds is what makes it a real verification project instead of marketing.

If you can say that paragraph back in your own words, you understand the project's point.
Everything below is machinery in service of it.

---

## Milestone 0 — Foundations (concepts only, no software yet)

**Goal:** own five ideas so the rest isn't jargon soup.
**Time:** 2–3 hrs reading + thinking.

Learn these, in this order (`docs/learning-notes.md` lists the resources):

1. **State and transition.** A "state" = the values of all your variables at one instant.
   A "transition" = a rule that takes one state to a next state. A whole system = an initial
   state + a next-state relation. That's it.
2. **Invariant.** A predicate (true/false statement) that must hold in *every* reachable
   state. "No blocklisted action is ever in the executed log" is an invariant.
3. **Safety vs liveness.** Safety = "nothing bad ever happens" (□, *always*). Liveness =
   "something good eventually happens" (◇, *eventually*). Your three core properties are all
   safety. Liveness is a stretch goal — ignore it until the core works.
4. **Reachable state / state space.** All states you can get to from the initial state by
   applying transitions. TLC walks this exhaustively. If it's infinite, TLC never finishes —
   hence you must keep the model small and bounded.
5. **Model checking vs testing.** Testing samples; model checking is exhaustive over a finite
   model. This is the sentence your professor will push on. Be able to defend both its power
   ("for all reachable states") and its limit ("only within the finite bounds I chose").

**Checkpoint 0:** Without looking, write three sentences — (a) what an invariant is, (b) why
testing can miss an ordering bug that model checking catches, (c) what "bounded" costs you in
terms of what you can claim. If you can't write (c) honestly, you'll fail the viva.

---

## Milestone 1 — Tools installed and a first model run (prove the pipeline works)

**Goal:** get *someone else's* working example to model-check green on your machine, so you
know the toolchain is real before you fight your own model.
**Time:** 1–2 hrs.

**What to install:**
- **TLA+ Toolbox** (IDE + the TLC checker bundled): https://lamport.azurewebsites.net/tla/toolbox.html
  — easiest for a beginner; everything in one window.
- *Alternative:* the **TLA+ extension for VS Code** if you prefer VS Code. Either is fine;
  pick one and stop shopping.

**What to do:**
1. Install it. Open it.
2. Go to https://learntla.com/ and do the very first worked example end-to-end — type it in,
   create a model, run TLC, watch it say "No errors."
3. Deliberately break that example (change one line so an invariant fails) and run again, so
   you see what a **failure + counterexample trace** looks like. This is the single most
   important UI skill in the whole project — the demo depends on it.

**Checkpoint 1:** You can create a model, run TLC to green, introduce a bug, and read the
counterexample trace it prints (state 1 → state 2 → … → the violating state). If you can't
read a trace yet, re-do this before touching `AgentGuardrail.tla`.

---

## Milestone 2 — Enough TLA+ to read our own spec (`spec/AgentGuardrail.tla`)

**Goal:** be able to read the existing skeleton line by line and explain it.
**Time:** 3–5 hrs over learntla.com.

From https://learntla.com/, you specifically need (skip the rest for now):
- Modules, `EXTENDS`, `CONSTANTS`, `VARIABLES`.
- `Init` (initial state) and `Next` (next-state relation), and the `Spec == Init /\ [][Next]_vars` idiom.
- Operators you'll actually use: `\E` (there exists), `\A` (for all), `\in`, `\subseteq`,
  `\cup`, set-builder `{ x \in S : P(x) }`, records/sequences (`Seq`, `Len`, `Append`),
  and `IF/THEN/ELSE` or disjunction `\/` for branching.
- How a transition expresses "the next value of a variable" with the prime: `proposed' = a`,
  and `UNCHANGED << ... >>` for variables that don't change.

Now open `spec/AgentGuardrail.tla` and map each piece to what you just learned:
- `CONSTANTS Actions, Irreversible, Blocklist` — the finite sets you'll fix in the `.cfg`.
- `VARIABLES pc, proposed, approved, executed` — `pc` is "where in the loop we are".
- `Init` sets the empty starting state.
- `Propose` is **already written** — read it until you can explain *why* `\E a \in Actions`
  models "the LLM can propose anything" (TLC explores every choice of `a` as a separate branch).

**Checkpoint 2:** Explain `Propose` out loud, including why the existential quantifier is
exactly how you encode an adversarial model. This is a near-certain viva question.

---

## Milestone 3 — Finish the spec: the three TODO actions (the core work)

This is the heart of the project. In `spec/AgentGuardrail.tla`, `Route`, `Approve`, and
`Execute` are stubbed as `FALSE`. You will replace them. Below is the **design and the
reasoning**; write the TLA+ yourself where it says "your task," and run TLC after each change.
Do **not** paste a finished spec you can't explain — the whole point is that you can defend it.

**First, a design decision you must make (and be able to justify):** the skeleton has
`executed \in Seq(Actions)`, a sequence that can grow forever → an infinite state space →
TLC never terminates. Two honest fixes:
- **(A) Single-request model (do this first):** the agent handles exactly one proposed action
  to `"Done"` and stops. Tiny state space, lets you check properties 1 and 2 immediately.
- **(B) Bounded looping model (do this for property 3 + the demo):** after `"Done"`, return to
  `"Idle"` to handle another request, but add a `CONSTRAINT` in the `.cfg` bounding the run
  (e.g. `Len(executed) =< 2`). You need more than one execution to even *express* "an approval
  was replayed."

Start with (A). Here is the recommended shape (states: `"Idle"`, `"Proposed"`,
`"NeedsApproval"`, `"Cleared"`, `"Done"` — you may extend `TypeOK` to add the new states):

**`Route`** — runs from `"Proposed"`. Classify the proposed action and route it:
```
Route ==
    /\ pc = "Proposed"
    /\ \/ /\ proposed \in Blocklist          \* blocklisted → reject, never executes
          /\ pc' = "Done"
          /\ UNCHANGED << proposed, approved, executed >>
       \/ /\ proposed \notin Blocklist
          /\ proposed \in Irreversible         \* irreversible → must be approved first
          /\ pc' = "NeedsApproval"
          /\ UNCHANGED << proposed, approved, executed >>
       \/ /\ proposed \notin Blocklist
          /\ proposed \notin Irreversible      \* reversible → cleared to run directly
          /\ pc' = "Cleared"
          /\ UNCHANGED << proposed, approved, executed >>
```
*Why it's shaped this way:* blocklisted never reaches a state where it can execute — that is
the structural guarantee behind property 2.

**`Approve`** — runs from `"NeedsApproval"`. Record the approval and clear the action:
```
Approve ==
    /\ pc = "NeedsApproval"
    /\ approved' = approved \cup { proposed }   \* record a granted approval
    /\ pc' = "Cleared"
    /\ UNCHANGED << proposed, executed >>
```

**`Execute`** — *your task.* It runs from `"Cleared"`, appends `proposed` to `executed`, and
goes to `"Done"`. The crucial preconditions — write and justify them:
- If `proposed \in Irreversible`, require `proposed \in approved` **and consume it** (remove it:
  `approved' = approved \ { proposed }`). Consumption is the mechanism that stops replay.
- If `proposed` is reversible, just execute (no approval needed).
- Use `executed' = Append(executed, proposed)`.

Write `Execute`, then update `Next` (it already lists all four) and `TypeOK` for the new `pc`
values.

**Checkpoint 3a:** TLC runs on model (A) with `INVARIANT TypeOK` and `INVARIANT NoBlocklisted`
and reports **no errors**. If `NoBlocklisted` fails, your `Route` let a blocklisted action
through — read the trace and fix it.

**Checkpoint 3b:** You can explain, pointing at your own lines, exactly which line guarantees
property 2, and which precondition in `Execute` will guarantee property 1.

---

## Milestone 4 — Write and check the formal properties (properties 1 and 3)

In `spec/AgentGuardrail.tla`, properties 1 and 3 are comments/placeholders. Now make them real.

**Property 1 — no irreversible action executes without an approval having been granted.**
The clean way: define it as an invariant over the execution guarded by your `Execute`
precondition. Simplest beginner version: an invariant stating that whenever an irreversible
action sits in `executed`, the path that put it there required `proposed \in approved`. Because
your `Execute` precondition already enforces this, the honest check is: *remove* the precondition
(that's the broken variant in Milestone 6) and confirm TLC then finds a violation. State the
invariant, add `INVARIANT NoUnapprovedIrreversible` to `AgentGuardrail.cfg`, run green.

**Property 3 — one approval authorises at most one action (non-replay).** This is the one that
*requires model (B)* — you cannot observe a replay with only one execution. Switch to the
bounded looping model, keep the `approved' = approved \ {proposed}` consumption, and check that
no irreversible action can appear in `executed` twice off a single `Approve`. This is genuinely
the hardest property; budget real time, and it's acceptable to present it as "designed and
partially checked" if you run short — just say so honestly in the report.

**Checkpoint 4:** Properties 1 (and, if reached, 3) added to both `.tla` and `.cfg`, TLC green
on the correct spec.

---

## Milestone 5 — The money shot: the broken variant + counterexample (the demo)

**Goal:** the single most persuasive artifact in the whole project.
**Time:** 1–2 hrs once Milestone 3 works.

1. Copy `spec/AgentGuardrail.tla` to `spec/AgentGuardrail_Broken.tla` (and a `_Broken.cfg`).
   `spec/README.md` already anticipates this file.
2. Introduce **one** subtle flaw. The best one: make the approval-check and the execution
   **non-atomic**, or simply **drop the consumption** (`approved' = approved` instead of
   removing it), or drop the `proposed \in approved` precondition.
3. Run TLC. It will print a **counterexample trace** — the exact state-by-state sequence by
   which a forbidden action slips through.
4. Save that trace. Screenshot it. This is your demo: "testing would almost never hit this
   ordering; the model checker found it mechanically in seconds."

**Checkpoint 5:** You have a saved counterexample trace and can walk someone through it state
by state, explaining which flawed line each step exploits.

---

## Milestone 6 — Stretch goals (only if the core is solid)

Do **not** start these until Milestones 3–5 are green and the report's core is drafted.
- **Liveness:** "every legitimate request eventually executes or is rejected." Needs temporal
  operators (◇) and **fairness** assumptions. Conceptually a step up; skip under time pressure.
- **Python harness:** a small Python script wiring a real LLM agent's proposed actions through
  the *exact* guardrail logic you verified, so the demo shows model and running system side by
  side. This is engineering, not verification — valuable for the demo, worthless for the
  correctness claim. Treat it as a demo prop, and never let it blur into "so the agent is
  verified safe." It isn't; only the logic model is.

---

## Milestone 7 — Report and defense (`report/OUTLINE.md`)

The outline already has the right sections. Fill them with claims matched to evidence. The two
sections that earn or lose you the grade:
- **Section 5 (Properties & results):** state each property formally, report what TLC checked,
  the state-space size it reported, and paste the counterexample from the broken variant.
- **Section 6 (Limitations & honest scope):** the bounds you chose, and the explicit statement
  that you verified the guardrail logic model — *not* the LLM, *not* external APIs, *not* the
  deployed system. Examiners reward this honesty and punish its absence.

**Viva prep — questions you will be asked, and must answer without a script:**
- Why model checking and not testing? (Ordering bugs; exhaustive over a finite model.)
- What exactly did you verify, and what did you *not*? (The guardrail logic; not the model.)
- Why is the LLM an `\E a \in Actions`? (Adversarial nondeterminism.)
- What do your finite bounds cost you? (A guarantee only up to those bounds.)
- Walk me through the counterexample. (From your saved trace.)

**Checkpoint 7:** You can answer all five out loud, cold, without notes.

---

## Time budget (honest)

| Phase | Realistic time for a beginner |
|---|---|
| Milestone 0 — concepts | 2–3 hrs |
| Milestone 1 — tools + first run | 1–2 hrs |
| Milestone 2 — read our spec | 3–5 hrs |
| Milestone 3 — finish spec (model A) | 4–8 hrs |
| Milestone 4 — properties 1 & 3 | 3–6 hrs |
| Milestone 5 — broken variant demo | 1–2 hrs |
| Milestone 6 — stretch | 6–15 hrs (optional) |
| Milestone 7 — report + viva prep | 4–8 hrs |

Core project (0–5 + 7, no stretch): **roughly 18–34 hours** of real work. At your stated
10–20 hrs/week, that's about **1.5–2.5 weeks**. Anyone who tells you it's a one-day job is
either wrong or not counting the learning.

## What to do *literally today*

1. Settle which deadline you're facing (Section 0). If it's the proposal — submit and relax.
2. Fill Manish's email in `README.md`.
3. Start Milestone 0 and 1. Getting TLC to run one green example today is a real win and
   de-risks everything after it.
