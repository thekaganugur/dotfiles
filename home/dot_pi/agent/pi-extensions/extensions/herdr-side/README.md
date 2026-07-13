# herdr-side

Herdr-scoped Pi Side Panes.

## Commands

- `/side [--split] [--write] [--fresh] [prompt]`
  - default: open adjacent herdr tab with forked Pi Side Pane
  - `--split`: open split beside Parent Session
  - `--write`: Worker Session; normal tools allowed
  - `--fresh`: start isolated Side Pane without Parent conversation context
  - `prompt`: sent to spawned Pi session
- `/return [note]`
  - Side Pane only
  - writes compressed Parent-relative Return Delta for Parent Session
  - captures only new Side Pane activity since prior successful Return
  - `note` overrides task anchor and guides summary
  - writes nothing when no new Side Pane activity exists
- `/side-inbox`
  - Parent Session only
  - pending Returns show as `returns: N · /side-inbox` in Parent status
  - opens picker/preview; no import happens until user chooses
  - actions: Import, Import + prompt, Dismiss, Cancel
  - Returns from one Side Pane resolve in order; later Deltas appear after earlier import or dismissal
  - dismissing an earlier Delta warns when later Deltas may depend on it
- `/side-inbox --latest [--prompt text]`
  - explicit fast path
  - imports newest available Return immediately; never bypasses an earlier Delta from same Side Pane
  - optional `--prompt` is sent after import
- `/side-inbox --undo`
  - restores newest dismissed Return; repeat to restore older ones

## Modes

Default Side Panes are read-only. `write`, `edit`, `bash`, and user `!` bash are blocked. Pi extensions still load.

Worker Sessions (`/side --write`) skip read-only gates.

## Return storage

Returns live under:

```text
~/.pi/agent/herdr-side/returns/
```

Each new artifact records parent session file/id, cwd, child session file/id, timestamp, `sequence`, `startEntryId`, `endEntryId`, resolved task anchor, optional note, summary, and import/dismiss markers. Older artifacts without Delta metadata remain readable. Return writes are atomic: temp file first, then rename to `.json`.

## Backend seam

`SidePaneBackend` owns pane creation. Current implementation is `HerdrBackend`; tmux/native terminal support can add another backend without touching command flow.
