# Language

Shared vocabulary for every suggestion this skill makes, taken from Juval Löwy, *Righting Software*. Use these terms exactly — don't substitute "feature module," "service layer," "repository," or "helper." Consistent language is the whole point.

## Decomposition terms

**Volatility**
An area of potential open-ended change that would rip the design apart if not encapsulated. The unit of decomposition — components encapsulate volatility, never functionality.
_Avoid_: "thing that might change" without applying the axes test below.

**Axes of volatility**
The two questions that find volatility: what changes for the *same customer over time*, and what differs *across customers at the same time*. Change on neither axis = not volatile = not a component.

**Volatile vs. variable**
Variability is handled cleanly inside code — conditionals, config, polymorphism. Volatility is open-ended change that requires its own component. Don't build components for mere variability.

**Functional decomposition**
Structuring the system around required functionality (InvoicingService, BillingModule). Bakes today's requirements into the structure; every new requirement ripples. The smell this skill hunts.

**Solution masquerading as a requirement**
A requirement that prescribes a mechanism ("email an alert") instead of the need (notify — transport is the volatility). Treat the mechanism as one case of the volatile area.

## Taxonomy (component roles)

**Client** — encapsulates presentation/user volatility. No business logic, no orchestration.
**Manager** — encapsulates workflow volatility: the sequence, the "what" of a family of related use cases. Should be **almost expendable** — cheap to rewrite when workflows change.
**Engine** — encapsulates activity volatility: the "how" of a business rule or computation. Few relative to Managers.
**ResourceAccess** — encapsulates how a resource is accessed. Exposes **atomic business verbs** (Credit, Debit), never CRUD.
**Resource** — the actual database, queue, endpoint, file, browser API; "where" the state is.
**Utility** — cross-cutting capability reusable in an unrelated system: logging, security, pub/sub, feature flags. Vertical bar — anyone may call it.

_Avoid_: service/controller/repository/DAO/helper as role names. Map them to the taxonomy instead.

**The four questions** — classification aid: *who* interacts (Client), *what* is required (Manager), *how* is it done (Engine, ResourceAccess), *where* is the state (Resource).

## Structure terms

**Closed architecture**
Components call only the layer directly below: Client → Manager → Engine → ResourceAccess → Resource. Allowed relaxations: anyone calls Utilities; Managers call Engines and ResourceAccess; Engines call ResourceAccess; Managers queue work to other Managers. Everything else is an **open call** — name violations exactly that.
_Avoid_: "circular dependency," "layering issue" — say which call breaks closed architecture and why.

**Layer** — a horizontal band of same-role components. _Avoid_: tier (deployment concern, not design).

**Contract** — the public face of a component, designed before internals. **Facet**: one of possibly several independent contracts a component exposes. Metrics (the judging bar): 3–5 members per contract; 1–2 facets per component, each logically consistent and independent; behavioral atomic business verbs, never property-like or CRUD; stable under the volatility — the encapsulated change alters the implementation, never the contract. 12+ members → factor down (a specialized derived contract) or sideways (split unrelated siblings); a single-member contract suggests over-factoring unless it's a deliberate facet.

## Composition terms

**Core use case** — a use case representing the essence of the business. Systems have two or three, rarely written down.
**Composable design** — design for the core use cases; compose all other use cases, present and future, from the same components via different interactions.
**"There is no feature"** — features emerge from interactions between components; they are aspects of integration, not implementation.
**Containing change** — a contained change happens inside one component; workflow changes are absorbed by rewiring or rewriting Managers, which are expendable by design.
**Architecture validation** — demonstrating via call chains or sequence diagrams that the design supports every core use case *without changing the components*.
**Smallest set** — the architect's mission: the minimal set of components that satisfies all use cases, current and future.

## Key principles

- **Prime directive**: never design against the requirements; never reflect required functionality in the structure.
- **The axes test**: no change on either axis of volatility → not a component.
- **The expendable-Manager test**: if rewriting a Manager from scratch would be painful, it's hoarding logic that belongs in Engines or ResourceAccess. If it's a pure pass-through, it contains no workflow and shouldn't exist.
- **Validation is composition**: a candidate is justified only if the core use cases still compose from the resulting components without modification.
