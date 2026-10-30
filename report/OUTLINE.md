# Report outline (draft)

A structure to fill in as the work progresses. Keep claims matched to evidence.

1. **Introduction & motivation**
   - LLM agents take real actions; why their safety cannot rest on the model behaving well.
   - Why testing is insufficient for ordering/interleaving bugs.

2. **Problem statement**
   - What exactly we verify: the guardrail/orchestration layer.
   - The explicit in-scope / out-of-scope boundary (we do **not** verify the model).

3. **Background**
   - Verification vs. testing vs. validation.
   - Model checking and TLA+/TLC, at the level a reader needs.

4. **The model**
   - State variables, transitions, how the LLM is modelled as adversarial nondeterminism.
   - The finite bounds chosen and why.

5. **Properties & results**
   - The safety properties, stated formally.
   - TLC results: what was checked, state-space size, outcomes.
   - The deliberately-broken variant and its counterexample trace (the key demonstration).

6. **Limitations & honest scope**
   - What the guarantee does and does not cover (bounds; the real model; external APIs).

7. **Conclusion & future work**
   - (If done) the Python harness linking a real agent to the verified logic.

8. **References**
