# Global Coding Preferences

## Always Apply

- Keep related logic close to where used.

## JavaScript / TypeScript / React

- Prefer straightforward function components.
- Reuse existing components before creating new ones.
- No wrappers, hooks, or abstractions unless they clearly improve code.
- `useMemo`/`useCallback` only for concrete performance or dependency-stability reasons — briefly explain why.
- `useEffect` only for external sync or display-driven side effects; prefer render logic and event handlers.

## Refactoring

- Treat refactors as behavior-preserving unless told otherwise.
- Simplify before abstracting.
- Remove unnecessary memoization and overly complex patterns when reasonable.
