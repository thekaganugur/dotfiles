# Manual verification

Date: 2026-07-09

- Old overlay disabled: `side.ts` moved to `side.overlay.disabled`; auto-discovery now loads `herdr-side/index.ts`.
- Herdr required message: `env -u HERDR_ENV ... pi -e ./index.ts -p "/side"` prints herdr requirement.
- Help: `/side --help`, `/return --help`, `/side-inbox --help` print command usage.
- Tab spawn: `/side` opens new herdr tab adjacent to parent, parent remains focused via `--no-focus`.
- Split spawn: `/side --split` opens side split.
- Initial prompt: `/side --split /return` sends `/return` into spawned pane.
- Read-only status: spawned Side Pane shows read-only widget/status.
- Read-only blocking: `!echo hi` in Side Pane returns `Read-only Side Pane blocks user bash`.
- Worker mode: `/side --split --write` shows `side: worker` and omits read-only tool exclusion.
- Extension loading: spawned Side Pane startup lists `herdr-side` and other Pi extensions.
- Return creation: fake Side Pane env + `/return smoke note` writes JSON Return artifact with parent id/cwd/note/summary; only final `.json` is visible; success says `Return ready.`.
- Bare inbox args: `/side-inbox do stuff` is rejected; prompts require `--prompt`.
- Fast import: temp agent dir + matching fake Return + `/side-inbox --latest` imports and marks artifact `imported`.
- Fast import with prompt: `/side-inbox --latest --prompt /return` imports first, then queues/sends prompt.
- Safe inbox default: TUI `/side-inbox` opens picker/preview before Import, Import + prompt, Dismiss, or Cancel.

## CLI verification — 2026-07-10

- `/side-inbox --undo` restores dismissed Returns newest-first; repeated use restores older dismissed Returns.
- `/side-inbox --latest` imports a pending Return and leaves no dismissed marker.
- Invalid JSON Return files remain untouched; `/side-inbox` warns with exact file path.
- `/side-inbox --undo --latest` is rejected; `/side --help` and `/side-inbox --help` load extension successfully.
- Fake herdr spawn confirms default `/side --split` passes Pi `--fork`, while `/side --split --fresh` skips it and retains Parent Return metadata env.
- Return summary source strips forked child session `parentSession`; nested summary Pi sees Side Pane Return Range only.

## Return Delta verification — 2026-07-12

- `node --test test/returns.test.ts` uses deterministic fixtures for copied Parent entries, compacted Side Pane history, Fresh Side Pane history, repeated Returns, ordered imports, and dismiss-unblock behavior.
- Forked summary source removes copied Parent entries, drops compaction/branch summaries, and rebases retained Side Pane links before nested summary Pi forks it.
- `/return` stores `sequence`, `startEntryId`, `endEntryId`, and resolved task anchor; a second `/return` with no new Side activity reports `Nothing new to return.` and writes no artifact.
- Temp `PI_CODING_AGENT_DIR` inbox with sequence 1 and sequence 2 confirms `/side-inbox --latest` imports sequence 1, not newer blocked sequence 2.
- `/side-inbox` exposes only earliest pending Delta per Side Pane. Import or warned dismissal unblocks next Delta. No unordered import path exists.
- Real herdr smoke: Fresh Side Pane wrote and Parent imported sequence 1; new Side work then wrote and Parent imported sequence 2.
