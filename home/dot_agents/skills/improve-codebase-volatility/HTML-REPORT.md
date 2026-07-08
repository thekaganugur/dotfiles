# HTML Report Format

The volatility review is rendered as a single self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. Mermaid handles graph-shaped diagrams reliably; hand-built divs and inline SVG handle the more editorial visuals (taxonomy layers, volatility heat). Mix the two — don't lean on Mermaid for everything, it'll start to look generic.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Volatility review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly */
      .open-call { stroke: #dc2626; }          /* closed-architecture violation */
      .volatile  { background: repeating-linear-gradient(45deg, #fef3c7, #fef3c7 6px, #fde68a 6px, #fde68a 12px); }
      .contained { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="overview">...</section>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Repo name, date, and a compact legend: horizontal band = layer, box = component coloured by role, red arrow = open call, striped fill = uncontained volatility, dark box = contained component. No introduction paragraph.

## Overview section

One **static architecture diagram** of the codebase as it is today, before any candidate cards. Hand-built taxonomy bands stacked vertically — Clients / Managers / Engines / ResourceAccess / Resources — with Utilities as a vertical bar on the right spanning all bands. Place the real modules (by name, monospaced) in the band matching their *actual current role*, even when that role is wrong for them; red arrows mark open calls. This diagram is the "before" the whole report argues against. Use a consistent role colour key and reuse it in every candidate diagram: Client sky, Manager indigo, Engine violet, ResourceAccess teal, Resource stone, Utility slate.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the glossary terms ([LANGUAGE.md](LANGUAGE.md)) without ceremony.

Render the candidate fields (SKILL.md §2) as one `<article>`. Rendering specifics:

- **Title** — short, names the containment (e.g. "Contain pricing volatility in a Pricing Engine").
- **Badge row** — tier (`Observed` = emerald, `Projected` = amber, `Speculative` = slate) plus a smell-category tag (`functional decomposition`, `client orchestration`, `leaky ResourceAccess`, `open call`, `missing Engine`, `Manager too expensive`, `pass-through Manager`). Beside the tier badge, an **evidence chip** in plain words: "changed together in N commits", "same rule in N files", "tenant variation already here", or "no history — speculative".
- **Files** — `font-mono text-sm`.
- **Before / After diagram** — the centrepiece. Two columns, side by side. See patterns below.
- **Volatility / Correction** — one sentence each.
- **Wins** — bullets, ≤6 words each ("Policy change touches one Engine", "Clients stop orchestrating", "Contract drops to 4 members").
- **ADR callout** (if applicable) — one line in an amber-tinted box.

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them — variety is part of the point.

### Taxonomy snippet (the workhorse for role confusion)

A miniature of the overview diagram, scoped to the candidate's files. Before: a module straddling two bands, or an arrow skipping a band (red). After: each module in one band, arrows stepping down one band at a time. Hand-built divs — Mermaid can't render bands with the right weight.

### Mermaid sequence diagram (the workhorse for orchestration and validation)

Use for client orchestration ("the page calls four things in order — that sequence is workflow and belongs in a Manager") and for the top recommendation's composition check (core use case walked through the corrected components). Colour open calls red via link styles.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    sequenceDiagram
      participant C as CheckoutPage (Client)
      participant M as OrderManager
      participant E as PricingEngine
      participant RA as OrderAccess
      C->>M: PlaceOrder
      M->>E: Price(items)
      M->>RA: Debit(account)
  </pre>
</div>
```

### Ripple map (good for functional decomposition)

Before: one volatile change (striped badge, e.g. "new payment method") with red lines fanning out to every file it touches. After: the same badge with one line into the single containing component, the dark `contained` box. The fan-in collapse *is* the argument.

### Contract shrink (good for leaky ResourceAccess)

Two columns of contract members rendered as rows. Before: `get/post/put/delete`, generated endpoint names, 12+ rows, CRUD rows tinted red. After: 3–5 atomic business verbs (`Credit`, `Debit`, `Hold`). Pull verb names from CONTEXT.md.

### Layer cross-section (good for open calls)

Stack horizontal bands; draw the offending call as a red arrow skipping or climbing bands. After: the same call routed through the layer below, arrows all stepping downward.

## Style guidance

- Lean editorial, not corporate-dashboard. Generous whitespace. Serif optional for headings (`font-serif` works well with stone/slate).
- Colour: the fixed role key above, plus red for open calls/leaks and amber stripes for uncontained volatility. Nothing else.
- Keep diagrams ~320px tall so before/after sits comfortably side by side without scrolling.
- Use `text-xs uppercase tracking-wider` for band and module labels — schematic, not UI.
- The only scripts are the Tailwind CDN and the Mermaid ESM import. The report is otherwise static.

## Top recommendation section

One larger card. Candidate name, tier badge, evidence chip, one sentence on why, the composition check (a compact sequence diagram or call chain showing a core use case flowing through the corrected components unchanged), anchor link to its card. That's it.

## Tone

Plain English, concise — but the architectural nouns and verbs come straight from [LANGUAGE.md](LANGUAGE.md), including its `_Avoid_` substitutions. Concision is not an excuse to drift.

**Phrasings that fit the style:**

- "CheckoutPage orchestrates — that sequence is workflow; it belongs in a Manager."
- "OrderRepo leaks CRUD; callers know the storage shape."
- "Discount policy is volatile across customers; today it lives in five files."
- "Open call: Engine imports a Client concern."
- "Contained: tax-rule changes touch one Engine."

**Wins bullets** name the gain in glossary terms: *"containment: payment change touches one component"*, *"composition: new use case is a Manager rewire"*, *"contract drops from 14 members to 4"*. Don't write *"easier to maintain"* or *"cleaner code"* — those terms aren't in the glossary and don't earn their place.

No hedging, no throat-clearing, no "it's worth noting that…". If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it. If a term isn't in [LANGUAGE.md](LANGUAGE.md), reach for one that is before inventing a new one.
