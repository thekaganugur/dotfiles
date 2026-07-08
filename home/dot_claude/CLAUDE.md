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

# Commit conventions

- Commit messages: subject line only. No body, no bullets, no description paragraphs.
- Use `git commit -m "subject"`. Skip HEREDOC body.
- Keep subject ≤72 chars. Follow project's Conventional Commits style if used.

# PR descriptions

- Keep short. Humans skim; long bodies go unread.
- Aim ≤5 bullets total. Skip "Test plan" unless explicitly asked.
- Lead with _why_ in one sentence, then minimal _what_. No section headers unless content warrants.
- Drop boilerplate (checklists, generated footers, repeated context already in commits).

# ClickUp tasks

- Always include "QA — what to watch for" section.
- Write for non-technical QA: plain-language scenarios (what to click, what to verify, what could look broken). No file names, code, or jargon.
