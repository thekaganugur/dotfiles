# ADR: file-mediated Returns and herdr backend seam

## Status

Accepted.

## Context

Side Panes need to send compressed context back to a Parent Session. Direct pane injection or live sync would couple two interactive Pi sessions and make failure recovery unclear.

## Decision

Use file-mediated Returns under `~/.pi/agent/herdr-side/returns/`. Parent imports explicitly via `/side-inbox`.

Also keep pane creation behind `SidePaneBackend`; current backend is herdr-only.

## Consequences

- Parent stays in control; no live context mutation from child.
- Returns are inspectable and recoverable if UI flow fails.
- Imported Returns can be marked to prevent duplicate imports.
- Future tmux/native terminal support only needs another backend.
- Slight extra step for user: run `/side-inbox` instead of automatic push.
