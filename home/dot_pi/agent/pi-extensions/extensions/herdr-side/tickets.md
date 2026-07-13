# Tickets: herdr Side Panes for Pi

Build a herdr-scoped `/side` workflow that opens forked Pi Side Panes, keeps them read-only by default, and lets Side Panes return compressed context to the Parent Session.

Work the **frontier**: any ticket whose blockers are all done.

## Disable old `/side` and scaffold herdr-side extension

**What to build:** `/side` command ownership moves to the herdr-side workflow. The old overlay implementation no longer conflicts, and invoking `/side` outside herdr fails with a clear message.

**Blocked by:** None — can start immediately.

- [x] Old `/side` command no longer auto-loads.
- [x] New herdr-side extension registers `/side`, `/return`, and `/side-inbox` commands.
- [x] `/side` reports that herdr is required when herdr is unavailable.
- [x] Extension shape leaves a backend seam for future tmux/native terminal support.

## Open forked Side Pane in herdr

**What to build:** `/side` opens a real herdr Side Pane forked from the Parent Session. It opens a new tab by default, supports split mode, supports Worker Session mode, and can auto-send an initial prompt.

**Blocked by:** Disable old `/side` and scaffold herdr-side extension.

- [x] `/side` opens a new herdr tab running a forked Pi session.
- [x] `/side --split` opens a split instead of a tab.
- [x] `/side --write` marks the Side Pane as a Worker Session.
- [x] `/side <prompt>` submits the prompt in the spawned Side Pane.
- [x] Parent Session remains focused after spawning.
- [x] Child process receives parent session file, parent session id, cwd, and Return inbox location.

## Add tools-only read-only mode

**What to build:** Side Panes are advisory and read-only by default. They cannot use normal mutation surfaces, while Pi extensions remain loaded and trusted. Explicit Worker Sessions keep normal capabilities.

**Blocked by:** Open forked Side Pane in herdr.

- [x] Default Side Panes cannot use write, edit, bash, or user bash.
- [x] Pi extensions remain loaded in Side Panes.
- [x] Worker Sessions created with `--write` are not restricted by read-only mode.
- [x] Read-only status is visible enough for the user to understand current mode.

## Write Return artifacts from child

**What to build:** A Side Pane can produce a compressed Return for its Parent Session. `/return [note]` summarizes the Side Pane with optional focus instructions and writes an artifact bound to the Parent Session.

**Blocked by:** Open forked Side Pane in herdr.

- [x] `/return [note]` works only from a Side Pane with parent metadata.
- [x] Return Summary is generated from a temporary fork of the Side Pane session, without adding summary turns to the Side Pane transcript.
- [x] Return Summary uses adaptive Markdown: full structure for non-trivial work, collapsed structure for simple work.
- [x] Return artifact records parent session file, parent session id, cwd, child session, timestamp, and summary content.
- [x] User gets clear success output showing where the Return went.

## Make Returns parent-relative Deltas

**What to build:** A Return captures one ordered, non-overlapping range of Side Pane activity for its Parent. It names task scope, never leaks inherited Parent transcript, and Parent resolves each Side Pane's Return Sequence in order.

**Blocked by:** Write Return artifacts from child; Import Returns in parent.

- [x] Rebuild temporary summary source from raw active Side Pane branch entries; remove copied Parent entries, rebase broken links, and omit compaction/branch summaries that can blend Parent context.
- [x] Derive task anchor from first substantive Side user prompt in Return Range; `/return [note]` overrides it.
- [x] Persist `sequence`, `startEntryId`, `endEntryId`, and resolved task anchor in Return artifact; keep existing artifacts readable.
- [x] Advance range after artifact write; `/return` writes no artifact when no new Side activity exists.
- [x] Enforce order per child Side Pane in Parent inbox; later deltas remain unavailable until earlier Return imports or dismisses.
- [x] Dismiss warns that later deltas may depend on it, then unblocks sequence.
- [x] Add deterministic regression fixtures for copied Parent entries, compacted Side Pane history, fresh Side Pane history, repeated Returns, ordering, and dismiss-unblock behavior.
- [x] Update help, README, glossary, and manual verification.

## Allow unordered Return imports

**What to build:** Let Parent deliberately import Return Deltas out of sequence when trade-offs justify incomplete context.

**Blocked by:** Make Returns parent-relative Deltas.

- [ ] Define explicit out-of-order import action and prerequisite warning.
- [ ] Preserve sequence metadata and auditability when import order differs from Return order.

## Import Returns in parent

**What to build:** The Parent Session can pull in Returns from its inbox. The user chooses a Return, imports it as displayed context, and may optionally provide a prompt that acts after the Return is included.

**Blocked by:** Write Return artifacts from child.

- [x] `/side-inbox` lists Returns bound to the current Parent Session.
- [x] Selected Return imports as displayed context that participates in future LLM context.
- [x] Empty optional prompt imports only and does not trigger a turn.
- [x] Non-empty optional prompt imports first, then sends the prompt so the Parent Session acts on the imported context.
- [x] Imported Returns are marked or hidden from default inbox view to avoid duplicate imports.

## Add Fresh Side Panes

**What to build:** `/side --fresh` starts an isolated Side Pane without inheriting Parent conversation context, while preserving its cwd, instructions, mode, and Return mailbox.

**Blocked by:** Open forked Side Pane in herdr.

- [x] `/side --fresh` skips Pi `--fork` while retaining Parent metadata env for `/return`.
- [x] Help and README distinguish default forked Side Panes from Fresh Side Panes.
- [x] Fresh Side Panes work with split and Worker flags.

## Polish docs and verification

**What to build:** The feature is understandable, recoverable, and manually verified across the core workflows.

**Blocked by:** Add tools-only read-only mode; Import Returns in parent.

- [x] Command help explains `/side`, `/return`, `/side-inbox`, `--split`, and `--write`.
- [x] Glossary reflects final terminology.
- [x] An ADR records surprising trade-offs if implementation confirms they are worth preserving.
- [x] Manual verification covers tab spawn, split spawn, initial prompt submission, read-only blocking, Worker Session mode, Return creation, Return import, and import-with-prompt.
