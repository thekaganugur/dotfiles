---
name: pr-clean
description: Clean PR loop. Use when the user wants the current pull request cleaned — unresolved review feedback fixed and review threads resolved.
---

# PR Clean Loop

Clean means: every actionable PR feedback item has a remote fix, a reply, and—when the host supports it—a resolved thread; a fresh refresh finds none left. Fixes are judged against a known base state, with unrelated sync noise kept out unless base staleness matters.

Default host is GitHub through `gh`. For GitHub commands, use [github.md](github.md). If the repo is not a GitHub PR or the host CLI is unavailable, ask for the provider workflow before changing PR state.

This skill runs in **auto-public** mode: after a local fix passes its relevant check, publish the change to the PR branch, reply, and resolve without asking again. If the user explicitly requests local-only work, stop before push/comment/resolve and report the queued public actions.

**Observed style** governs any git write (sync or publish): match the repo's existing merge/rebase and commit history. When no style is clear, make one small commit per item and push. When a write would require a force push and the convention is unclear, ask first.

## Process

### 1. Pin current PR

Find the PR for the current branch unless the user supplied a PR number or URL. Capture PR number, URL, head branch, base branch, head SHA, base SHA, review decision, merge state, check rollup, and current working tree state.

If no current PR resolves, ask for the PR number or URL. If the working tree has unrelated pre-existing changes, preserve them and ask before touching overlapping files.

Completion criterion: one open PR is pinned, local checkout is on or tracking the PR head, current base SHA is known before edits, and the run has a safe plan for any pre-existing dirty files.

### 2. Refresh feedback queue

Fetch feedback from the host, then build a fresh queue:

1. Unresolved review threads.
2. Actionable review summaries or PR comments that ask for changes and are not superseded by a later reply or code change.

A review thread is one feedback item, even when it has many comments. Read the whole thread before editing.

Sort deterministically: unresolved threads oldest first, then actionable loose feedback oldest first.

Completion criterion: queue is built from fresh host data and each queued item has source URL/comment ID, author, timestamp, file/line when available, and requested outcome.

### 3. Gate freshness for current item

Take the first queued item only. Before editing it, fetch current base/head metadata and run a read-only conflict check. Compare current base SHA to the last-seen base SHA and list base-delta files.

Mutate-sync before editing only when base staleness matters:

- Read-only merge check reports conflicts, or host merge state says the PR is blocked by stale base.
- Base delta touches the current item's file/area or changes behavior needed to satisfy the item.
- Branch protection or stale CI makes current-base sync necessary before the relevant check is meaningful.

Otherwise record `base advanced, no current-item overlap` and keep the item fix isolated.

When sync happens, follow **observed style**. After sync, refresh the feedback queue; if the current item disappeared, became outdated, or was already satisfied by the sync, restart from the queue.

Completion criterion: current item is selected, base/head SHAs are known, conflicts/stale-CI baseline is known, and branch was synced only when needed or the no-sync reason is recorded.

### 4. Work one item

Ignore later items except where they directly conflict with the current one.

Restate the requested outcome in your own notes. If the item is a question, asks for product/design judgement, conflicts with another item, or admits multiple valid fixes, ask one focused question before editing.

Completion criterion: current item has one concrete outcome, ambiguity is resolved, and required files/checks are identified.

### 5. Make smallest fix

Patch only what the current item needs. Prefer existing patterns and standard library/platform features. Keep refactors, cleanup, and opportunistic improvements out unless they are required for this item.

Completion criterion: diff is limited to the current item and satisfies the requested outcome.

### 6. Run relevant check

Run the narrowest check that can catch a regression for the touched behavior: targeted test, focused lint/typecheck, build step, or project-specific validation. If the narrow check fails because of your patch, repair and rerun until it passes.

If no runnable check exists after inspecting project scripts/CI hints, record why and use the strongest available static evidence; the reply must say verification was by inspection.

Completion criterion: passing command output is recorded, or absence of any runnable relevant check is documented with evidence.

### 7. Publish, reply, resolve

Publish the current item patch to the PR branch following **observed style**.

Reply to the feedback item with what changed and the exact check run. Resolve the thread when the host allows it and the item is satisfied. For loose PR comments that cannot be resolved, post a reply/comment that names the original feedback.

Completion criterion: remote PR contains the fix, reply is posted, thread is resolved when possible, and any host limitation is recorded.

### 8. Loop from fresh state

After each publish/reply/resolve, refresh host feedback and base state from scratch. Continue until the fresh queue is empty.

Completion criterion: a fresh refresh returns zero unresolved review threads and zero actionable loose feedback, and the last-seen base state is recorded.

### 9. Final sweep

Step 8 already guarantees the feedback queue is empty; this sweep catches what the queue can't see.

Check PR status after the clean loop: review decision, unresolved threads, base/head SHA, merge state, CI/check rollup if available, and local git status.

If host review state still says changes requested despite zero unresolved threads and zero loose feedback, report the mismatch (a pending review the host won't clear without a re-review) rather than treating it as a queue item.

If the PR is behind base or CI is stale, treat that as a remaining non-feedback blocker. Sync for merge-readiness only when branch protection requires it and **observed style** is clear; otherwise report the blocker.

Completion criterion: final report includes PR URL, items fixed/resolved, checks run, final base/head state, remaining non-feedback blockers, and clean evidence from the final refresh.
