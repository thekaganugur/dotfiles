# Global Agent Instructions

## Subagent concurrency

- `concurrency` goes at top level (sibling to `tasks`, not in task objects).
- glm-5.2-short cap = 3 slots; 5 at once → 2 die w/ 429.
- `concurrency: 2` if main thread calls model mid-flight; 3 only if main idle.
- Always pass `concurrency` explicitly.
