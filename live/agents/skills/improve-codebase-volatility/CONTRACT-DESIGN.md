# Contract Design

When the user wants to explore alternative contracts for a chosen containment candidate, use this parallel sub-agent pattern. Based on Appendix B of *Righting Software*: the contract is the public face of the component, designed before any internal details — and the first factoring is unlikely to sit at the area of minimum cost.

Uses the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **contract**, **facet**, **atomic business verbs**, **factoring**, **containment**.

## Contract metrics (the judging bar)

Score every design against the **contract metrics** in [LANGUAGE.md](LANGUAGE.md) before discussing trade-offs.

## Process

### 1. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the problem space for the chosen candidate:

- The component's **role** (Manager / Engine / ResourceAccess) and the volatility it must encapsulate
- Who calls it under closed architecture (the layer above) and what it may call (the layer below)
- The core use cases its contract must serve — composition is the constraint
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make the constraints concrete

Show this to the user, then immediately proceed to Step 2. The user reads and thinks while the sub-agents work in parallel.

### 2. Spawn sub-agents

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **radically different** contract for the component.

Prompt each sub-agent with a separate technical brief (file paths, the volatility being encapsulated, the role, callers and callees under closed architecture, relevant CONTEXT.md verbs). Give each agent a different factoring constraint:

- Agent 1: "Factor for the minimal contract — 3–5 atomic business verbs, nothing property-like. One facet."
- Agent 2: "Factor sideways — split into independent facets if the operations serve different caller families. Justify each facet."
- Agent 3: "Factor up — extract the abstraction the verbs share, so future variants of the volatility are new implementations, not new members."
- Agent 4 (ResourceAccess candidates): "Design the contract purely in atomic business verbs from CONTEXT.md — no CRUD, no transport, no generated API names visible."

Include both [LANGUAGE.md](LANGUAGE.md) vocabulary and CONTEXT.md vocabulary in the brief so each sub-agent names things consistently with the architecture language and the project's domain language.

Each sub-agent outputs:

1. The contract (members with params and types — plus invariants, ordering, error modes)
2. A usage example showing the layer above composing a core use case through it
3. What the implementation hides — which volatility changes leave the contract untouched
4. Contract metrics self-score (members per facet, facets, any property-like members and why)
5. Trade-offs — where the factoring costs implementation effort, where it costs integration effort

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **containment** (which changes stay inside the implementation), **composition** (how cleanly the core use cases flow through), and **metrics** (member count, facet count, verb quality).

After comparing, give your own recommendation: which design sits closest to the area of minimum cost and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.
