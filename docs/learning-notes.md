# Learning notes & roadmap

A running log of what we learn, decisions we make, and references. Start here.

## Why TLA+ / model checking (and not testing)

Testing runs the system on *some* inputs and interleavings; it can only ever show the
presence of bugs on the cases it happens to try, never their absence. A concurrency/ordering
bug in a guardrail may depend on an interleaving a test never hits. **Model checking**
(TLC) instead explores *every* reachable state of a finite model and checks that a property
holds in all of them — a genuine "for all reachable states" guarantee, bounded by the model
size we choose. That bound is something we must state honestly.

## Prerequisites to learn (in order)

1. **Thinking in states and transitions** — a system as a set of states and a next-state
   relation. (Learn TLA+, early chapters.)
2. **Basic TLA+ syntax** — modules, `EXTENDS`, constants, variables, `Init`, `Next`, `Spec`.
3. **Invariants** — a safety property as "this predicate holds in every reachable state."
4. **Temporal operators** — `□` (always) for safety; `◇` (eventually) and fairness for the
   stretch liveness property.
5. **Running TLC** — writing a `.cfg`, choosing finite constants, reading a counterexample
   trace.

## Resources

- **Learn TLA+** — Hillel Wayne — https://learntla.com/  *(primary tutorial, beginner-friendly)*
- **TLA+ Toolbox** (IDE + TLC) — https://lamport.azurewebsites.net/tla/toolbox.html
- **The TLA+ Home Page** — Leslie Lamport — https://lamport.azurewebsites.net/tla/tla.html
- **Specifying Systems** (Lamport, free PDF) — the reference book, for depth later.

## Milestone plan (draft)

- [ ] Install the TLA+ Toolbox; run the tutorial's first example end-to-end.
- [ ] Write `AgentGuardrail.tla`: finish `Route`, `Approve`, `Execute`.
- [ ] Get TLC to check `TypeOK` + `NoBlocklisted` clean on a tiny instance.
- [ ] Add and check properties 1 (no unapproved irreversible) and 3 (no approval replay).
- [ ] Build the broken variant; capture the TLC counterexample trace for the demo.
- [ ] (Stretch) liveness property with fairness.
- [ ] (Stretch) Python harness linking a real agent to the verified guardrail logic.
- [ ] Write the report; state precisely what is proven and what is out of scope.

## Open questions / decisions

- How many concurrent requests to model? (Start with 1; try 2 only if the state space allows.)
- Exact shape of the "approval" record for the non-replay property.
