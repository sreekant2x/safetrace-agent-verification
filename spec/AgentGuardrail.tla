----------------------------- MODULE AgentGuardrail -----------------------------
(***************************************************************************)
(* SafeTrace: a skeleton model of an LLM agent's action-guardrail layer.   *)
(*                                                                         *)
(* STATUS: WORK IN PROGRESS / SCAFFOLD. This is a starting structure to be *)
(* completed during the modelling phase (course Step 6). It lays out the   *)
(* variables, constants and the shape of the transitions and properties;   *)
(* the bodies marked TODO still need to be written and the module needs to *)
(* be checked with TLC before any property can be claimed. Do NOT treat    *)
(* anything here as verified yet.                                          *)
(*                                                                         *)
(* Core idea: the language model is an ADVERSARIAL NONDETERMINISTIC actor  *)
(* that may propose ANY action. We verify the GUARDRAIL that gates those   *)
(* proposals, not the model itself.                                        *)
(***************************************************************************)
EXTENDS Naturals, FiniteSets, Sequences

CONSTANTS
    Actions,        \* the finite set of actions the agent may propose
    Irreversible,   \* Irreversible \subseteq Actions : actions needing approval
    Blocklist       \* Blocklist   \subseteq Actions : actions never allowed

VARIABLES
    pc,          \* "Idle" | "Proposed" | "AwaitingApproval" | "Done"
    proposed,    \* the currently proposed action, or a sentinel "none"
    approved,    \* set of actions with a granted, not-yet-consumed approval
    executed     \* sequence (log) of actions actually executed

vars == << pc, proposed, approved, executed >>

NoAction == CHOOSE x : x \notin Actions   \* a sentinel value outside Actions

TypeOK ==
    /\ pc \in { "Idle", "Proposed", "AwaitingApproval", "Done" }
    /\ proposed \in Actions \cup { NoAction }
    /\ approved \subseteq Actions
    /\ executed \in Seq(Actions)

Init ==
    /\ pc = "Idle"
    /\ proposed = NoAction
    /\ approved = {}
    /\ executed = << >>

(* The model proposes ANY action (adversarial nondeterminism). *)
Propose ==
    /\ pc = "Idle"
    /\ \E a \in Actions :
          /\ proposed' = a
          /\ pc' = "Proposed"
    /\ UNCHANGED << approved, executed >>

(* TODO: Classify/Route. Reject blocklisted actions; send irreversible   *)
(* actions to "AwaitingApproval"; let reversible ones proceed to Execute.*)
Route == FALSE  \* TODO

(* TODO: Approve. Grant an approval for a pending irreversible action,   *)
(* adding it to `approved`.                                             *)
Approve == FALSE  \* TODO

(* TODO: Execute. Append to `executed` ONLY when the guardrail's         *)
(* precondition holds. For an irreversible action, its approval must be  *)
(* present AND must be consumed (removed from `approved`) so it cannot be *)
(* reused.                                                              *)
Execute == FALSE  \* TODO

Next == Propose \/ Route \/ Approve \/ Execute

Spec == Init /\ [][Next]_vars

(***************************************************************************)
(* SAFETY PROPERTIES (to be checked with TLC once the actions are filled). *)
(***************************************************************************)

\* 2. No blocklisted action is ever executed.
NoBlocklisted ==
    \A i \in 1..Len(executed) : executed[i] \notin Blocklist

\* 1 & 3 require tracking approvals-per-execution; to be refined when      *)
\* Execute is written. Placeholders below state the intent.               *)

\* NoUnapprovedIrreversible == ...   TODO
\* NoApprovalReplay          == ...   TODO

=============================================================================
