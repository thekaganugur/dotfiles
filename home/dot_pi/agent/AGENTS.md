# Global Agent Instructions

## Subagent approval

- Ask user before **every** subagent launch: single agent, parallel batch, chain, async run, resume, or scheduled run.
- One approval may cover one exact named batch. New agent, added child, changed goal, write permission, model, context, or concurrency requires new approval.
- Approval prompt must state: agent/role, goal, resolved model and thinking level, read-only vs write access, context (`fresh` or `fork`), and concurrency. User may approve or override model/thinking inline.
- Never treat prior task approval or generic permission to use subagents as approval for later launches.

## Subagent concurrency

### glm-5.2 and glm-5.2-short

- `concurrency` goes at top level, sibling to `tasks`; never in task objects.
- Cap: 3 slots. Five concurrent launches cause two 429 failures.
- Use `concurrency: 2` while main thread calls model; use `3` only while main idle.
- Always pass `concurrency` explicitly.
