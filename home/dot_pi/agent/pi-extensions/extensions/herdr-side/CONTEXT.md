# Dotfiles Agent Workflow

Shared language for local Pi/herdr agent workflows managed from this dotfiles repository.

## Language

**Parent Session**:
The Pi conversation that starts a side workflow and remains the source of inherited context.
_Avoid_: Main chat, original chat

**Side Pane**:
A real herdr tab or split running an isolated Pi conversation launched from a Parent Session. By default, it inherits Parent conversation context and is advisory/read-only with no write/edit/bash/user-bash access unless explicitly created as a Worker Session. Pi extensions remain loaded and trusted inside Side Panes.
_Avoid_: Side chat, child chat, fork

**Fresh Side Pane**:
A Side Pane started without Parent conversation context. It retains Parent cwd, project instructions, mode, and Return mailbox.
_Avoid_: Empty Side Pane, stateless Side Pane

**Worker Session**:
A Side Pane explicitly allowed to modify files and run normal tools.
_Avoid_: Writable side, full side

**Return**:
A compressed result produced by a Side Pane for later import into its Parent Session. Returns move through an explicit file-mediated inbox under the user agent data directory, not direct pane injection or live sync. Each Return is bound to a Parent Session by parent session file, parent session id, and cwd.
_Avoid_: Sync, merge, live context

**Return Summary**:
A Parent-relative Delta inside a Return. It names its Side Pane task anchor and captures Side activity since prior successfully written Return, never inherited Parent conversation; for non-trivial side work, include Summary, Key findings, Recommended parent action, Files/areas referenced, and Caveats.
_Avoid_: Raw transcript, Parent recap, standalone report

**Task Anchor**:
Scope label for a Return Range. It is first substantive Side Pane user prompt in range, unless `/return [note]` supplies override.
_Avoid_: Generated title, Parent task recap

**Return Import**:
The act of bringing a Return into the Parent Session as displayed context. A Return Import may optionally include a follow-up prompt that tells the Parent Session to act on the newly imported context.
_Avoid_: Auto-merge, pushback

**Pending Return**:
A valid Return not yet imported or dismissed by its Parent Session. Pending Returns form an ordered Return Sequence.
_Avoid_: Unread Return, unimported Return

**Return Sequence**:
An ordered stream of Parent-relative Deltas from one Side Pane. Parent resolves earlier Returns before later ones; unordered Return imports remain a future option.
_Avoid_: Latest Return, independent snapshots

**Return Range**:
A bounded interval of Side Pane activity captured by one Return. Its persisted source boundaries make Return Sequences restart-safe and non-overlapping.
_Avoid_: Cursor file, implicit checkpoint

**Dismissed Return**:
A Return intentionally removed from the Parent's pending inbox without being imported. It remains recoverable and advances its Return Sequence after dependency warning.
_Avoid_: Read Return, imported Return

**Return Undo**:
Restoring the newest Dismissed Return to pending state. Repeating it restores older Dismissed Returns.
_Avoid_: Re-import, restore history

**Return Notice**:
A passive, live Parent Session indicator of Pending Returns. It does not import content or change focus.
_Avoid_: Notification, push, alert

**Invalid Return**:
A Return artifact that cannot be read as valid data. It remains untouched for recovery and is surfaced as an inbox warning.
_Avoid_: Discarded Return, quarantined Return
