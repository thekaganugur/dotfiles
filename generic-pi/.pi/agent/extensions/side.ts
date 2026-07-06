import {
  getMarkdownTheme,
  type ExtensionAPI,
  type ExtensionCommandContext,
  type Theme,
} from "@earendil-works/pi-coding-agent"
import {
  Input,
  Markdown,
  type Component,
  type Focusable,
  getKeybindings,
  type MarkdownTheme,
  type TUI,
  truncateToWidth,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui"
import { mkdtemp, readdir, rm, stat } from "node:fs/promises"
import { tmpdir } from "node:os"
import { join } from "node:path"

const TIMEOUT_MS = 10 * 60 * 1000
const READ_ONLY_TOOLS = "read,grep,find,ls"
// Panel padding: H_PAD columns inside the side borders, V_PAD blank rows at the
// top and bottom of the body for breathing room.
const H_PAD = 1
const V_PAD = 1

interface SideTurn {
  question: string
  ok: boolean
  text: string
  pending?: boolean
}

interface SideReply {
  ok: boolean
  text: string
}

interface SideState {
  sessionDir?: string
  sessionFile?: string
  turns: SideTurn[]
  activePanel?: SidePanel
  activeHandle?: { focus: () => void }
}

function clip(text: string, max = 40_000): string {
  if (text.length <= max) return text
  return `${text.slice(0, max)}\n\n…[side answer clipped at ${max} chars]`
}

async function newestJsonl(dir: string): Promise<string | undefined> {
  let best: { path: string; mtime: number } | undefined

  async function walk(current: string) {
    for (const entry of await readdir(current, { withFileTypes: true })) {
      const path = join(current, entry.name)
      if (entry.isDirectory()) {
        await walk(path)
      } else if (entry.isFile() && entry.name.endsWith(".jsonl")) {
        const info = await stat(path)
        if (!best || info.mtimeMs > best.mtime) best = { path, mtime: info.mtimeMs }
      }
    }
  }

  await walk(dir)
  return best?.path
}

async function resetSide(state: SideState) {
  const dir = state.sessionDir
  state.sessionDir = undefined
  state.sessionFile = undefined
  state.turns = []
  if (dir) await rm(dir, { recursive: true, force: true })
}

async function askSide(
  question: string,
  ctx: ExtensionCommandContext,
  pi: ExtensionAPI,
  state: SideState,
  signal?: AbortSignal,
): Promise<SideReply> {
  const childArgs = [
    "--tools",
    READ_ONLY_TOOLS,
    "--append-system-prompt",
    "This is an ephemeral side conversation. Answer side questions without modifying files.",
  ]

  if (state.sessionFile) {
    childArgs.push("--session", state.sessionFile)
  } else {
    state.sessionDir = await mkdtemp(join(tmpdir(), "pi-side-"))
    childArgs.push("--session-dir", state.sessionDir)

    const mainSessionFile = ctx.sessionManager.getSessionFile()
    if (mainSessionFile) childArgs.push("--fork", mainSessionFile)
  }

  if (ctx.model) childArgs.push("--model", `${ctx.model.provider}/${ctx.model.id}:${pi.getThinkingLevel()}`)

  childArgs.push("-p", `Answer this side question. Keep it separate from the main thread.\n\n${question}`)

  const result = await pi.exec("pi", childArgs, { cwd: ctx.cwd, timeout: TIMEOUT_MS, signal })
  if (!state.sessionFile && state.sessionDir) state.sessionFile = await newestJsonl(state.sessionDir)

  const output = clip(result.stdout.trim() || result.stderr.trim() || "(no output)")
  if (result.code === 0) return { ok: true, text: output }
  return { ok: false, text: `Side failed (${result.code}).\n\n\`\`\`\n${output}\n\`\`\`` }
}

/**
 * Bounded overlay panel: a multi-turn side conversation that lives entirely
 * separate from the main transcript. Reuses the child `pi -p` side session,
 * shows the running conversation, and returns to the parent on Esc.
 */
class SidePanel implements Component, Focusable {
  private turns: SideTurn[]
  private theme: Theme
  private mdTheme: MarkdownTheme
  private tui: TUI
  private budget: number
  private onAsk: (question: string, signal: AbortSignal) => Promise<SideReply>
  private onClose: () => void
  private onReset?: () => void
  private input: Input
  private thinking = false
  private closed = false
  private controller?: AbortController
  private _focused = false
  private history: string[] = []
  private historyIdx = -1
  private cacheWidth?: number
  private cacheLines?: string[]

  constructor(opts: {
    turns: SideTurn[]
    theme: Theme
    mdTheme: MarkdownTheme
    termRows: number
    tui: TUI
    onAsk: (question: string, signal: AbortSignal) => Promise<SideReply>
    onClose: () => void
    onReset?: () => void
  }) {
    this.turns = opts.turns
    this.theme = opts.theme
    this.mdTheme = opts.mdTheme
    this.tui = opts.tui
    this.onAsk = opts.onAsk
    this.onClose = opts.onClose
    this.onReset = opts.onReset
    this.budget = Math.max(14, Math.min(42, Math.floor(opts.termRows * 0.85)))
    this.input = new Input()
    this.input.onSubmit = (value) => {
      void this.ask(value)
    }
    this.input.onEscape = () => {
      // Staged Esc: abort current question → clear input → close
      if (this.thinking) {
        this.controller?.abort()
        return
      }
      if (this.input.getValue().length > 0) {
        this.input.setValue("")
        this.invalidate()
        this.tui.requestRender()
        return
      }
      this.close()
    }
  }

  get focused(): boolean {
    return this._focused
  }

  set focused(value: boolean) {
    this._focused = value
    this.input.focused = value
  }

  /** Public entry point so `/side <q>` can fire the first question on open. */
  ask(question: string): Promise<void> {
    return this.submit(question)
  }

  private async submit(question: string) {
    const q = question.trim()
    if (!q || this.thinking) return
    this.input.setValue("")
    this.history.push(q)
    this.historyIdx = -1
    this.thinking = true
    this.controller = new AbortController()
    // Show the question instantly as a pending turn; fill the answer in when it lands.
    const turn: SideTurn = { question: q, ok: true, text: "", pending: true }
    this.turns.push(turn)
    this.invalidate()
    this.tui.requestRender()

    let reply: SideReply
    try {
      reply = await this.onAsk(q, this.controller.signal)
    } catch (error) {
      this.thinking = false
      this.controller = undefined
      const aborted = this.closed || (error as { name?: string })?.name === "AbortError"
      const idx = this.turns.indexOf(turn)
      if (aborted) {
        // User aborted via staged Esc (or panel closed): drop the pending question.
        if (idx !== -1) this.turns.splice(idx, 1)
        if (!this.closed) {
          this.invalidate()
          this.tui.requestRender()
        }
        return
      }
      // Real crash: keep the turn, surface the error as the answer.
      if (idx !== -1) {
        turn.ok = false
        turn.text = `Side crashed.\n\n\`\`\`\n${String(error)}\n\`\`\``
        turn.pending = false
      }
      this.invalidate()
      this.tui.requestRender()
      return
    }

    this.thinking = false
    this.controller = undefined
    if (this.closed) return
    turn.ok = reply.ok
    turn.text = reply.text
    turn.pending = false
    this.invalidate()
    this.tui.requestRender()
  }

  /** Re-open detection: panel is alive until close() runs. */
  get isOpen(): boolean {
    return !this.closed
  }

  close() {
    if (this.closed) return
    this.closed = true
    this.controller?.abort()
    this.onClose()
  }

  handleInput(data: string): void {
    // Ctrl-C: hard exit — clear the side chat, close panel, return to parent.
    // Use the app keybinding so it matches every terminal encoding (raw \x03,
    // Kitty CSI-u, etc.), not just the raw byte form.
    const kb = getKeybindings()
    if (kb.matches(data, "app.clear")) {
      this.onReset?.()
      this.close()
      return
    }
    if (kb.matches(data, "tui.editor.cursorUp")) {
      this.recallHistory(-1)
      this.invalidate()
      this.tui.requestRender()
      return
    }
    if (kb.matches(data, "tui.editor.cursorDown")) {
      this.recallHistory(1)
      this.invalidate()
      this.tui.requestRender()
      return
    }
    this.input.handleInput(data)
    this.invalidate()
    this.tui.requestRender()
  }

  /** ↑ recalls older questions, ↓ walks forward (or clears when past the end). */
  private recallHistory(dir: -1 | 1) {
    if (this.history.length === 0) return
    if (dir === -1) {
      this.historyIdx = this.historyIdx <= 0 ? this.history.length - 1 : this.historyIdx - 1
      this.input.setValue(this.history[this.historyIdx] ?? "")
      return
    }
    if (this.historyIdx < 0) return
    this.historyIdx++
    if (this.historyIdx >= this.history.length) {
      this.historyIdx = -1
      this.input.setValue("")
    } else {
      this.input.setValue(this.history[this.historyIdx] ?? "")
    }
  }

  invalidate(): void {
    this.cacheWidth = undefined
    this.cacheLines = undefined
  }

  private renderBody(innerW: number): string[] {
    const t = this.theme
    const lines: string[] = []
    this.turns.forEach((turn, i) => {
      if (i > 0) lines.push("")
      const questionText = `${t.fg("accent", "❯ ")}${turn.question}`
      for (const line of wrapTextWithAnsi(questionText, innerW)) lines.push(line)
      if (turn.pending) {
        lines.push(t.fg("dim", "…"))
      } else {
        const md = new Markdown(turn.text, 0, 0, this.mdTheme)
        for (const line of md.render(innerW)) lines.push(line)
      }
    })
    return lines
  }

  render(width: number): string[] {
    const w = width < 2 ? 2 : width
    if (this.cacheWidth === w && this.cacheLines) return this.cacheLines
    const t = this.theme
    const innerW = w - 2
    const contentW = Math.max(1, innerW - 2 * H_PAD)

    const accent = (s: string) => t.fg("borderAccent", s)
    const border = (left: string, right: string, fill: string, color: (s: string) => string) =>
      color(left + fill.repeat(Math.max(0, innerW)) + right)

    const top = border("╭", "╮", "─", accent)
    const sep = border("├", "┤", "─", (s: string) => t.fg("borderMuted", s))
    const bottom = border("╰", "╯", "─", accent)

    const count = this.turns.length
    const left = `${t.bold(t.fg("accent", "side"))}${t.fg("dim", `  conversation${count ? `  · ${count} turn${count > 1 ? "s" : ""}` : ""}`)}`
    const right = t.fg("dim", "ctrl-c clear · esc close · enter ask ")
    const title = contentRow(padBetween(left, right, contentW), w, accent, H_PAD)

    // 6 chrome lines: top, title, sep, status, input, bottom. Body sits between
    // sep and status, framed by V_PAD blank rows and grown to minBody so the
    // panel is substantial on open even with no content.
    const maxBody = Math.max(0, this.budget - 6 - 2 * V_PAD)
    const minBody = Math.max(6, Math.floor(this.budget * 0.5) - 6)
    const bodyAll = this.renderBody(contentW)
    let body: string[]
    if (bodyAll.length > maxBody) {
      const hidden = bodyAll.length - maxBody + 1
      body = [t.fg("dim", `… ${hidden} earlier line${hidden > 1 ? "s" : ""} hidden`), ...bodyAll.slice(-(maxBody - 1))]
    } else {
      body = bodyAll
    }
    const framed: string[] = []
    for (let i = 0; i < V_PAD; i++) framed.push("")
    framed.push(...body)
    for (let i = 0; i < V_PAD; i++) framed.push("")
    while (framed.length < minBody) framed.push("")

    const status = this.thinking
      ? t.fg("warning", "▸ side thinking…  ·  esc to abort")
      : t.fg("dim", "▸ ask a follow-up  ·  ↑ history")
    const statusRow = contentRow(status, w, accent, H_PAD)

    const inputLine = this.input.render(contentW)[0] ?? ""
    const inputRow = contentRow(inputLine, w, accent, H_PAD)

    const bodyRows = framed.map((line) => contentRow(line, w, accent, H_PAD))
    const lines = [top, title, sep, ...bodyRows, statusRow, inputRow, bottom]
    this.cacheWidth = w
    this.cacheLines = lines
    return lines
  }
}

function contentRow(content: string, width: number, border: (s: string) => string, hPad = 0): string {
  const innerW = width - 2
  const contentW = Math.max(1, innerW - 2 * hPad)
  const c = visibleWidth(content) > contentW ? truncateToWidth(content, contentW, "") : content
  const pad = Math.max(0, contentW - visibleWidth(c))
  const h = hPad ? " ".repeat(hPad) : ""
  return `${border("│")}${h}${c}${" ".repeat(pad)}${h}${border("│")}`
}

function padBetween(left: string, right: string, width: number): string {
  const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right))
  return `${left}${" ".repeat(gap)}${right}`
}

async function openSide(args: string, ctx: ExtensionCommandContext, pi: ExtensionAPI, state: SideState) {
  if (ctx.mode !== "tui") {
    ctx.ui.notify("side requires interactive mode", "error")
    return
  }
  // Re-open focuses the existing panel instead of stacking a second overlay.
  if (state.activePanel && state.activePanel.isOpen) {
    state.activeHandle?.focus()
    return
  }
  // Don't wait for the main agent — /side is async and can open mid-stream.
  // The overlay captures focus and renders on top of the streaming view.

  const initial = args.trim()
  const mdTheme = getMarkdownTheme()

  await ctx.ui.custom<undefined>(
    (tui, theme, _kb, done) => {
      const panel = new SidePanel({
        turns: state.turns,
        theme,
        mdTheme,
        termRows: tui.terminal.rows,
        tui,
        onAsk: (question, signal) => askSide(question, ctx, pi, state, signal),
        onClose: () => {
          state.activePanel = undefined
          state.activeHandle = undefined
          done(undefined)
        },
        onReset: () => { void resetSide(state) },
      })
      state.activePanel = panel
      if (initial) void panel.ask(initial)
      return panel
    },
    {
      overlay: true,
      overlayOptions: { width: "86%", minWidth: 60, maxHeight: "90%", anchor: "center" },
      onHandle: (handle) => {
        state.activeHandle = handle
      },
    },
  )
}

export default function (pi: ExtensionAPI) {
  const state: SideState = { turns: [] }
  const handler = (args: string, ctx: ExtensionCommandContext) => openSide(args, ctx, pi, state)

  pi.registerCommand("side", {
    description: "Open an ephemeral side conversation (overlay)",
    handler,
  })

  pi.registerCommand("btw", {
    description: "Alias for /side",
    handler,
  })

  pi.registerCommand("side-new", {
    description: "Reset the side conversation",
    handler: async (_args, ctx) => {
      await resetSide(state)
      ctx.ui.notify("Side context reset", "info")
    },
  })

  pi.on("session_shutdown", async () => {
    await resetSide(state)
  })
}
