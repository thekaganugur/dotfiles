# Method Checklist

The smell catalog and applied rules for the volatility review. Vocabulary and role definitions live in [LANGUAGE.md](LANGUAGE.md); this file is how the method gets *applied* — what to look for, and how to write up quick text findings.

## Volatility questions

Find volatility by interrogation, not intuition:

- What has changed over the last system lifespan, and which files did that change touch?
- What changes for the same customer over time?
- What differs between customers at the same time?
- Which changes would ripple across files if not contained?
- Which changes are mere variability — handled locally by a conditional or config?
- Which changes alter the nature of the business, and so should *not* be encapsulated?
- Which "requirements" are actually proposed solutions masquerading as needs?

## Evidence tiers

Every volatility is tagged **Observed**, **Projected**, or **Speculative** by its strongest evidence. The tier is the evidence strength — there is no separate recommendation-strength badge.

- **Observed** — already changing in the code: a past change forced edits across these files (git log / blame), the same change-prone logic is duplicated across files, or a real cross-customer / cross-mode variation already exists.
- **Projected** — not yet observed, but a plausible axis meets current architectural friction and the change is likely within the system lifespan.
- **Speculative** — possible via an axis, no observed signal. Never the top recommendation.

Rank by tier first — Speculative never leads. Between Observed and Projected, weigh containment payoff: a high-payoff Projected can outrank an Observed nuisance.

## Smells by role

Role definitions are in [LANGUAGE.md](LANGUAGE.md). Here is how each role goes wrong.

**Client** — owns business sequencing; calls multiple Managers in one use case; calls Engines or ResourceAccess directly for business behavior; publishes domain events because it knows internal state changed.

**Manager** — *too expensive*: business rules, data access, and UI tangled into the orchestration; *too expendable*: pure pass-through with no sequencing value; directly calls another Manager where a queue or event belongs; handles unrelated families of use cases.

**Engine** — a one-off helper extracted only for testability; called directly by a Client; chained into other Engines; publishes or subscribes to domain events; hidden inside a Client or Manager despite being reusable and volatile.

**ResourceAccess** — interface reads as `get/post/put/delete`, `select/insert`, `open/read/write`, or generated endpoint names; callers cast generated API payloads or know transport quirks; request shaping, cache invalidation, retry, permission, or error handling duplicated across call sites; ResourceAccess modules call each other.

**Resource** — business logic living here (from the codebase's perspective); emits domain events directly; callers treat its details as stable architecture.

**Utility** — domain-specific behavior parked here to bypass layer rules; imports a Client or Manager concern.

## Closed-architecture red flags

The closed dependency order and its allowed relaxations are in [LANGUAGE.md](LANGUAGE.md). Open calls to flag:

- Lower roles import UI/Client concerns (upward call).
- Same-role modules call each other with no orchestrating Manager, queue, or event (sideways call).
- A Client stitches one use case by coordinating multiple Managers.
- Generated API calls spread across Clients and Managers instead of sitting behind ResourceAccess.
- Asymmetry: similar use cases follow inconsistent call patterns with no load-bearing reason.

## Text findings format

When the review is delivered as inline findings rather than the HTML report, lead with the volatility list, then one block per candidate:

```md
1. Candidate name
   **Files**: `path`, `path`
   **Current shape**: role confusion or decomposition smell.
   **Volatility**: the change leaking across files, stated via the axes.
   **Evidence**: strongest evidence or rationale — "changed together in N commits", "same rule in N files", "tenant variation already here", "roadmap/lifespan signal plus current friction", or "none found".
   **Correction**: role split, move, rename, consolidation, or contract cleanup.
   **Benefit**: locality, composability, test surface, LLM navigation.
   **Tier**: Observed | Projected | Speculative.
```

Close with a top recommendation, then ask: *Which candidate should we explore?*

## Frontend translation

Roles are architectural, not deployment units — never propose distributed services for an in-process codebase. In frontend code the roles usually map as:

- Page / route / form / component → **Client**.
- Use-case hook or controller → **Manager**.
- Validation, transformation, permission policy, content-type rules → **Engine**.
- TanStack Query hook, Redux saga, generated API wrapper, local-storage wrapper → **ResourceAccess**.
- Generated API client, backend endpoint, browser storage, URL params, file input, ActionCable connection → **Resource**.
- Snackbar, logging, permissions, feature flags, region paths, telemetry → **Utility**.

Don't split by role mechanically. Split only when it contains real volatility or fixes real navigation/testing friction.
