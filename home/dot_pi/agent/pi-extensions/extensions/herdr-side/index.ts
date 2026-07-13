import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { BorderedLoader, getAgentDir, getMarkdownTheme } from "@earendil-works/pi-coding-agent";
import { Markdown } from "@earendil-works/pi-tui";
import { randomUUID } from "node:crypto";
import { watch, type FSWatcher } from "node:fs";
import { mkdir, mkdtemp, readFile, readdir, rename, rm, stat, writeFile } from "node:fs/promises";
import { createConnection } from "node:net";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
	activeBranch,
	buildReturnRange,
	hasLaterPendingReturn,
	isPendingReturn as isPendingArtifact,
	isSubstantiveSideActivity,
	loadedArtifactStates,
	orderedPendingReturns,
	rebaseSummaryEntries,
	type RawSessionEntry,
	type ReturnArtifactState,
	type ReturnRange,
} from "./return-range.ts";

const BLOCKED_READ_ONLY_TOOLS = new Set(["bash", "edit", "write"]);
const READ_ONLY_EXCLUDED_TOOLS = "bash,edit,write";
const SIDE_HELP = [
	"/side [--split] [--write] [--fresh] [prompt]",
	"Open a herdr Side Pane in a new tab. --split opens a split. --write creates a Worker Session with normal tools.",
	"--fresh starts without Parent conversation context. Without --write, write/edit/bash/user bash are blocked. Optional prompt is sent to the spawned Pi session.",
].join("\n");
const RETURN_HELP = "/return [note]\nFrom a Side Pane, write a compressed Parent-relative Return Delta for the Parent Session. Optional note overrides task anchor and guides summary.";
const INBOX_HELP = [
	"/side-inbox",
	"Open Return picker/preview. Nothing imports until you choose an action.",
	"/side-inbox --latest [--prompt text]",
	"Fast path: import newest pending Return immediately, then optionally send prompt.",
	"/side-inbox --undo",
	"Restore newest dismissed Return.",
	"Returns from same Side Pane import in order. Dismissing an earlier Return unblocks later Deltas.",
].join("\n");

interface SideOptions {
	mode: "tab" | "split";
	write: boolean;
	fresh: boolean;
	prompt: string;
}

interface ParentMetadata {
	sessionFile?: string;
	forkSessionFile?: string;
	sessionId?: string;
	cwd: string;
	returnInbox: string;
}

interface OpenSidePaneOptions {
	cwd: string;
	command: string;
	label: string;
	mode: "tab" | "split";
}

interface OpenSidePaneResult {
	paneId: string;
	tabId?: string;
}

interface ReturnArtifact extends ReturnArtifactState {
	version: 1;
	parentSessionFile?: string;
	parentSessionId?: string;
	cwd: string;
	note?: string;
	summary: string;
	imported?: {
		timestamp: string;
		parentSessionFile?: string;
		parentSessionId?: string;
	};
	dismissed?: {
		timestamp: string;
		parentSessionFile?: string;
		parentSessionId?: string;
	};
}

interface LoadedReturnArtifact {
	path: string;
	artifact: ReturnArtifact;
}

interface ReturnInbox {
	artifacts: LoadedReturnArtifact[];
	invalidPaths: string[];
}

interface InboxOptions {
	latest: boolean;
	undo: boolean;
	prompt?: string;
	invalid?: string;
}

interface SidePaneBackend {
	available(): boolean;
	openSidePane(options: OpenSidePaneOptions, ctx: ExtensionCommandContext, pi: ExtensionAPI): Promise<OpenSidePaneResult>;
}

class HerdrBackend implements SidePaneBackend {
	constructor(private readonly env: NodeJS.ProcessEnv = process.env) {}

	available(): boolean {
		return this.env.HERDR_ENV === "1" && Boolean(this.env.HERDR_SOCKET_PATH) && Boolean(this.env.HERDR_PANE_ID);
	}

	async openSidePane(
		options: OpenSidePaneOptions,
		ctx: ExtensionCommandContext,
		pi: ExtensionAPI,
	): Promise<OpenSidePaneResult> {
		const pane = options.mode === "split" ? await this.openSplit(ctx, pi) : await this.openTab(options.label, ctx, pi);
		await execJson(pi, ctx.cwd, ["pane", "run", pane.paneId, options.command]);
		return pane;
	}

	private async openTab(label: string, ctx: ExtensionCommandContext, pi: ExtensionAPI): Promise<OpenSidePaneResult> {
		const workspaceId = this.env.HERDR_WORKSPACE_ID;
		if (!workspaceId) throw new Error("HERDR_WORKSPACE_ID missing");

		const data = await execJson(pi, ctx.cwd, ["tab", "create", "--workspace", workspaceId, "--label", label, "--no-focus"]);
		const paneId = data.result?.root_pane?.pane_id;
		if (typeof paneId !== "string") throw new Error("herdr tab create did not return root pane id");
		const tabId = data.result?.tab?.tab_id;
		if (typeof tabId === "string") await this.moveTabBesideParent(tabId, workspaceId, ctx, pi);
		return { paneId, tabId: typeof tabId === "string" ? tabId : undefined };
	}

	private async moveTabBesideParent(
		tabId: string,
		workspaceId: string,
		ctx: ExtensionCommandContext,
		pi: ExtensionAPI,
	): Promise<void> {
		const parentTabId = this.env.HERDR_TAB_ID;
		const socketPath = this.env.HERDR_SOCKET_PATH;
		if (!parentTabId || !socketPath) return;

		const data = await execJson(pi, ctx.cwd, ["tab", "list", "--workspace", workspaceId]);
		const tabs = Array.isArray(data.result?.tabs) ? data.result.tabs : [];
		const parentIndex = tabs.findIndex((tab: { tab_id?: string }) => tab.tab_id === parentTabId);
		if (parentIndex < 0) return;

		await herdrRequest(socketPath, "tab.move", { tab_id: tabId, insert_index: parentIndex + 1 });
	}

	private async openSplit(ctx: ExtensionCommandContext, pi: ExtensionAPI): Promise<OpenSidePaneResult> {
		const parentPaneId = this.env.HERDR_PANE_ID;
		if (!parentPaneId) throw new Error("HERDR_PANE_ID missing");

		const data = await execJson(pi, ctx.cwd, ["pane", "split", parentPaneId, "--direction", "right", "--no-focus"]);
		const paneId = data.result?.pane?.pane_id;
		if (typeof paneId !== "string") throw new Error("herdr pane split did not return pane id");
		const tabId = data.result?.pane?.tab_id;
		return { paneId, tabId: typeof tabId === "string" ? tabId : undefined };
	}
}

async function execJson(pi: ExtensionAPI, cwd: string, args: string[]): Promise<any> {
	const result = await pi.exec("herdr", args, { cwd, timeout: 10_000 });
	if (result.code !== 0) throw new Error(result.stderr.trim() || result.stdout.trim() || `herdr ${args.join(" ")} failed`);
	try {
		return JSON.parse(result.stdout || "{}");
	} catch (error) {
		throw new Error(`herdr returned invalid JSON: ${String(error)}`);
	}
}

function herdrRequest(socketPath: string, method: string, params: Record<string, unknown>): Promise<any> {
	return new Promise((resolve, reject) => {
		const socket = createConnection(socketPath);
		const id = `herdr-side:${Date.now()}:${Math.random().toString(36).slice(2)}`;
		let buffer = "";
		let settled = false;
		const timeout = setTimeout(() => finish(new Error(`${method} timed out`)), 10_000);
		timeout.unref?.();

		function finish(error?: Error, value?: unknown) {
			if (settled) return;
			settled = true;
			clearTimeout(timeout);
			socket.destroy();
			if (error) reject(error);
			else resolve(value);
		}

		socket.on("error", (error) => finish(error));
		socket.on("connect", () => socket.write(`${JSON.stringify({ id, method, params })}\n`));
		socket.on("data", (chunk) => {
			buffer += chunk.toString();
			const newline = buffer.indexOf("\n");
			if (newline < 0) return;
			try {
				const response = JSON.parse(buffer.slice(0, newline));
				if (response.error) finish(new Error(response.error.message ?? JSON.stringify(response.error)));
				else finish(undefined, response.result);
			} catch (error) {
				finish(error instanceof Error ? error : new Error(String(error)));
			}
		});
	});
}

function isHelp(args: string): boolean {
	const value = args.trim();
	return value === "--help" || value === "-h" || value === "help";
}

function parseSideArgs(args: string): SideOptions {
	const parts = args.trim().split(/\s+/).filter(Boolean);
	let mode: "tab" | "split" = "tab";
	let write = false;
	let fresh = false;
	let i = 0;

	for (; i < parts.length; i += 1) {
		const part = parts[i];
		if (part === "--") {
			i += 1;
			break;
		}
		if (part === "--split") {
			mode = "split";
			continue;
		}
		if (part === "--write") {
			write = true;
			continue;
		}
		if (part === "--fresh") {
			fresh = true;
			continue;
		}
		break;
	}

	return { mode, write, fresh, prompt: parts.slice(i).join(" ") };
}

function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function sideLabel(options: SideOptions): string {
	return options.write ? "pi worker" : "pi side";
}

function sidePrompt(options: SideOptions): string {
	if (options.write) {
		return [
			"You are a herdr Worker Session spawned from a Parent Session.",
			"You may modify files and run normal tools. Keep work scoped to the Parent request.",
			"Use /return [note] when ready to send compressed context back to the Parent Session.",
		].join("\n");
	}

	return [
		"You are a herdr Side Pane spawned from a Parent Session.",
		"Default mode is read-only: do not modify files or run shell commands.",
		"Use read-only tools for investigation. Use /return [note] when ready to send compressed context back to the Parent Session.",
	].join("\n");
}

function getSessionId(ctx: ExtensionContext): string | undefined {
	return (ctx.sessionManager as { getSessionId?: () => string | undefined }).getSessionId?.();
}

async function parentMetadata(ctx: ExtensionCommandContext): Promise<ParentMetadata> {
	const sessionFile = ctx.sessionManager.getSessionFile() ?? undefined;
	const sessionId = getSessionId(ctx);
	let forkSessionFile: string | undefined;
	if (sessionFile) {
		try {
			const info = await stat(sessionFile);
			if (info.size > 0) forkSessionFile = sessionFile;
		} catch {
			forkSessionFile = undefined;
		}
	}

	return {
		sessionFile,
		forkSessionFile,
		sessionId,
		cwd: ctx.cwd,
		returnInbox: join(getAgentDir(), "herdr-side", "returns"),
	};
}

function childEnv(meta: ParentMetadata, options: SideOptions): Record<string, string> {
	return {
		HERDR_SIDE: "1",
		HERDR_SIDE_MODE: options.write ? "worker" : "readonly",
		HERDR_SIDE_PARENT_SESSION_FILE: meta.sessionFile ?? "",
		HERDR_SIDE_PARENT_SESSION_ID: meta.sessionId ?? "",
		HERDR_SIDE_PARENT_CWD: meta.cwd,
		HERDR_SIDE_RETURN_INBOX: meta.returnInbox,
	};
}

function buildPiCommand(meta: ParentMetadata, options: SideOptions, ctx: ExtensionCommandContext, pi: ExtensionAPI): string {
	const args = ["--name", sideLabel(options), "--append-system-prompt", sidePrompt(options)];
	if (!options.fresh && meta.forkSessionFile) args.push("--fork", meta.forkSessionFile);
	if (!options.write) args.push("--exclude-tools", READ_ONLY_EXCLUDED_TOOLS);
	if (ctx.model) args.push("--model", `${ctx.model.provider}/${ctx.model.id}:${pi.getThinkingLevel()}`);
	if (options.prompt) args.push(options.prompt);

	const env = Object.entries(childEnv(meta, options)).map(([key, value]) => `${key}=${shellQuote(value)}`);
	return [`cd ${shellQuote(ctx.cwd)}`, `env ${env.join(" ")} pi ${args.map(shellQuote).join(" ")}`].join(" && ");
}

function notify(ctx: ExtensionContext, message: string, level: "info" | "warning" | "error" = "info") {
	if (ctx.hasUI) ctx.ui.notify(message, level);
	else console.error(message);
}

function isSidePane(): boolean {
	return process.env.HERDR_SIDE === "1";
}

function isReadOnlySidePane(): boolean {
	return isSidePane() && process.env.HERDR_SIDE_MODE !== "worker";
}

function hasParentMetadata(): boolean {
	return Boolean(process.env.HERDR_SIDE_PARENT_SESSION_FILE || process.env.HERDR_SIDE_PARENT_SESSION_ID);
}

async function openSide(args: string, ctx: ExtensionCommandContext, pi: ExtensionAPI, backend: SidePaneBackend) {
	if (isHelp(args)) {
		notify(ctx, SIDE_HELP, "info");
		return;
	}

	if (!backend.available()) {
		notify(ctx, "/side requires herdr. Open pi inside a herdr pane first.", "error");
		return;
	}

	const options = parseSideArgs(args);
	const meta = await parentMetadata(ctx);
	await mkdir(meta.returnInbox, { recursive: true });
	const command = buildPiCommand(meta, options, ctx, pi);

	try {
		await backend.openSidePane({ cwd: ctx.cwd, command, label: sideLabel(options), mode: options.mode }, ctx, pi);
		notify(ctx, "Side Pane opened.", "info");
	} catch (error) {
		notify(ctx, `Failed to open Side Pane: ${error instanceof Error ? error.message : String(error)}`, "error");
	}
}

function envValue(name: string): string | undefined {
	const value = process.env[name];
	return value && value.length > 0 ? value : undefined;
}

function safeFilePart(value: string): string {
	return value.replace(/[^\w.-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 80) || "return";
}

function fallbackReturnSummary(note: string): string {
	return note ? `## Summary\n\n${note}` : "No Side Pane work yet.";
}

function returnSummaryPrompt(note: string, taskAnchor: string): string {
	return [
		"Create a compressed Parent-relative Return Summary from this Side Pane Return Range only.",
		"Do not summarize inherited Parent Session conversation or activity outside this Return Range.",
		`Task anchor: ${taskAnchor}`,
		"Use adaptive Markdown: for non-trivial work include Summary, Key findings, Recommended parent action, Files/areas referenced, and Caveats; for trivial work collapse to useful sections only.",
		"Be concise. Preserve concrete file paths, commands, errors, and decisions. Do not mention this instruction.",
		note ? `Focus note from user: ${note}` : "No focus note provided.",
	].join("\n\n");
}

async function nonEmptyFile(path: string | undefined): Promise<string | undefined> {
	if (!path) return undefined;
	try {
		const info = await stat(path);
		return info.size > 0 ? path : undefined;
	} catch {
		return undefined;
	}
}

interface RawSideSession {
	header: { type?: string; parentSession?: string; [key: string]: unknown };
	entries: RawSessionEntry[];
}

async function readRawSideSession(path: string): Promise<RawSideSession> {
	const lines = (await readFile(path, "utf8")).trimEnd().split("\n");
	const header = JSON.parse(lines[0] ?? "") as RawSideSession["header"];
	if (header.type !== "session") throw new Error("Side Pane session has invalid header");
	return { header, entries: lines.slice(1).filter(Boolean).map((line) => JSON.parse(line) as RawSessionEntry) };
}

async function prepareReturnSummarySource(
	childSessionFile: string,
	childSessionId: string | undefined,
	artifacts: ReturnArtifact[],
	note: string,
	leafId: string | null,
	sessionDir: string,
): Promise<{ sourceSessionFile: string; range: ReturnRange } | undefined> {
	const child = await readRawSideSession(childSessionFile);
	const parentIds = child.header.parentSession
		? new Set((await readRawSideSession(child.header.parentSession)).entries.flatMap((entry) => (entry.id ? [entry.id] : [])))
		: new Set<string>();
	const entries = rebaseSummaryEntries(activeBranch(child.entries, leafId), parentIds);
	const range = buildReturnRange(entries, artifacts, { id: childSessionId ?? childSessionFile, childSessionFile, childSessionId }, note);
	if (!range.entries.some(isSubstantiveSideActivity)) return undefined;

	const header = { ...child.header };
	delete header.parentSession;
	const sourceSessionFile = join(sessionDir, "side-only.jsonl");
	await writeFile(sourceSessionFile, `${[JSON.stringify(header), ...range.entries.map(JSON.stringify)].join("\n")}\n`, { encoding: "utf8", mode: 0o600 });
	return { sourceSessionFile, range };
}

async function generateReturnSummary(
	note: string,
	ctx: ExtensionCommandContext,
	pi: ExtensionAPI,
	artifacts: ReturnArtifact[],
	signal?: AbortSignal,
): Promise<{ summary: string; range: ReturnRange } | undefined> {
	const childSessionFile = await nonEmptyFile(ctx.sessionManager.getSessionFile() ?? undefined);
	if (!childSessionFile) return undefined;

	const sessionDir = await mkdtemp(join(tmpdir(), "herdr-side-return-"));
	try {
		const prepared = await prepareReturnSummarySource(
			childSessionFile,
			getSessionId(ctx),
			artifacts,
			note,
			ctx.sessionManager.getLeafId(),
			sessionDir,
		);
		if (!prepared) return undefined;

		const args = [
			"-u",
			"HERDR_SIDE",
			"-u",
			"HERDR_SIDE_MODE",
			"-u",
			"HERDR_SIDE_PARENT_SESSION_FILE",
			"-u",
			"HERDR_SIDE_PARENT_SESSION_ID",
			"-u",
			"HERDR_SIDE_PARENT_CWD",
			"-u",
			"HERDR_SIDE_RETURN_INBOX",
			"pi",
			"--print",
			"--fork",
			prepared.sourceSessionFile,
			"--session-dir",
			sessionDir,
			"--no-tools",
			"--append-system-prompt",
			"You summarize Side Pane Return Deltas for Return artifacts.",
		];
		if (ctx.model) args.push("--model", `${ctx.model.provider}/${ctx.model.id}:${pi.getThinkingLevel()}`);
		args.push(returnSummaryPrompt(note, prepared.range.taskAnchor));

		const result = await pi.exec("env", args, { cwd: ctx.cwd, timeout: 10 * 60 * 1000, signal });
		const output = (result.stdout || result.stderr).trim();
		if (result.code !== 0) throw new Error(output || `summary pi exited ${result.code}`);
		return { summary: output || fallbackReturnSummary(prepared.range.taskAnchor), range: prepared.range };
	} finally {
		await rm(sessionDir, { recursive: true, force: true });
	}
}

async function createReturnArtifact(
	note: string,
	ctx: ExtensionCommandContext,
	pi: ExtensionAPI,
	signal?: AbortSignal,
): Promise<string | undefined> {
	const inbox = envValue("HERDR_SIDE_RETURN_INBOX") ?? join(getAgentDir(), "herdr-side", "returns");
	await mkdir(inbox, { recursive: true });

	const { artifacts } = await readReturnInbox(inbox);
	const generated = await generateReturnSummary(note, ctx, pi, loadedArtifactStates(artifacts), signal);
	if (!generated) return undefined;

	const timestamp = new Date().toISOString();
	const artifact: ReturnArtifact = {
		version: 1,
		id: randomUUID(),
		parentSessionFile: envValue("HERDR_SIDE_PARENT_SESSION_FILE"),
		parentSessionId: envValue("HERDR_SIDE_PARENT_SESSION_ID"),
		cwd: envValue("HERDR_SIDE_PARENT_CWD") ?? ctx.cwd,
		childSessionFile: ctx.sessionManager.getSessionFile() ?? undefined,
		childSessionId: getSessionId(ctx),
		timestamp,
		note: note || undefined,
		summary: generated.summary,
		sequence: generated.range.sequence,
		startEntryId: generated.range.startEntryId,
		endEntryId: generated.range.endEntryId,
		taskAnchor: generated.range.taskAnchor,
	};
	const file = join(inbox, `${safeFilePart(timestamp)}_${safeFilePart(artifact.id)}.json`);
	const tmpFile = `${file}.tmp`;
	await writeFile(tmpFile, `${JSON.stringify(artifact, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
	await rename(tmpFile, file);
	return file;
}

async function writeReturnArtifact(args: string, ctx: ExtensionCommandContext, pi: ExtensionAPI) {
	if (isHelp(args)) {
		notify(ctx, RETURN_HELP, "info");
		return;
	}

	if (!isSidePane() || !hasParentMetadata()) {
		notify(ctx, "/return works only inside a Side Pane spawned by /side.", "error");
		return;
	}

	const note = args.trim();

	if (ctx.mode === "tui") {
		const result = await ctx.ui.custom<{ file?: string; error?: string; cancelled?: true; noActivity?: true }>((tui, theme, _kb, done) => {
			const loader = new BorderedLoader(tui, theme, "Creating Return Summary...");
			let settled = false;
			const finish = (value: { file?: string; error?: string; cancelled?: true; noActivity?: true }) => {
				if (settled) return;
				settled = true;
				done(value);
			};

			loader.onAbort = () => finish({ cancelled: true });
			void (async () => {
				try {
					await ctx.waitForIdle();
					const file = await createReturnArtifact(note, ctx, pi, loader.signal);
					finish(file ? { file } : { noActivity: true });
				} catch (error) {
					finish(loader.signal.aborted ? { cancelled: true } : { error: error instanceof Error ? error.message : String(error) });
				}
			})();

			return loader;
		});

		if (result?.cancelled) notify(ctx, "Return cancelled.", "info");
		else if (result?.error) notify(ctx, `Return failed: ${result.error}`, "error");
		else if (result?.noActivity) notify(ctx, "Nothing new to return.", "info");
		else if (result?.file) notify(ctx, "Return ready.", "info");
		return;
	}

	notify(ctx, "Creating Return Summary...", "info");
	try {
		await ctx.waitForIdle();
		const file = await createReturnArtifact(note, ctx, pi);
		notify(ctx, file ? "Return ready." : "Nothing new to return.", "info");
	} catch (error) {
		notify(ctx, `Return failed: ${error instanceof Error ? error.message : String(error)}`, "error");
	}
}

async function readReturnInbox(inbox: string): Promise<ReturnInbox> {
	let names: string[];
	try {
		names = await readdir(inbox);
	} catch {
		return { artifacts: [], invalidPaths: [] };
	}

	const artifacts: LoadedReturnArtifact[] = [];
	const invalidPaths: string[] = [];
	for (const name of names) {
		if (!name.endsWith(".json")) continue;
		const path = join(inbox, name);
		try {
			const artifact = JSON.parse(await readFile(path, "utf8")) as ReturnArtifact;
			if (
				artifact.version !== 1 ||
				typeof artifact.id !== "string" ||
				typeof artifact.timestamp !== "string" ||
				Number.isNaN(new Date(artifact.timestamp).getTime()) ||
				typeof artifact.cwd !== "string" ||
				typeof artifact.summary !== "string" ||
				(artifact.sequence !== undefined && (!Number.isInteger(artifact.sequence) || artifact.sequence < 1)) ||
				(artifact.startEntryId !== undefined && typeof artifact.startEntryId !== "string") ||
				(artifact.endEntryId !== undefined && typeof artifact.endEntryId !== "string") ||
				(artifact.taskAnchor !== undefined && typeof artifact.taskAnchor !== "string")
			) {
				invalidPaths.push(path);
				continue;
			}
			artifacts.push({ path, artifact });
		} catch {
			invalidPaths.push(path);
		}
	}
	return { artifacts: artifacts.sort((a, b) => b.artifact.timestamp.localeCompare(a.artifact.timestamp)), invalidPaths };
}

function isPendingReturn(loaded: LoadedReturnArtifact): boolean {
	return isPendingArtifact(loaded.artifact);
}

function orderedPendingLoadedReturns(artifacts: LoadedReturnArtifact[]): LoadedReturnArtifact[] {
	const byId = new Map(artifacts.map((loaded) => [loaded.artifact.id, loaded]));
	return orderedPendingReturns(artifacts.map((loaded) => loaded.artifact)).map((artifact) => byId.get(artifact.id)!);
}

function isDismissedReturn(loaded: LoadedReturnArtifact): boolean {
	return !loaded.artifact.imported && Boolean(loaded.artifact.dismissed);
}

function matchesParent(loaded: LoadedReturnArtifact, ctx: ExtensionContext): boolean {
	const sessionFile = ctx.sessionManager.getSessionFile() ?? undefined;
	const sessionId = getSessionId(ctx);
	const artifact = loaded.artifact;
	if (artifact.cwd !== ctx.cwd) return false;
	return Boolean(
		(artifact.parentSessionFile && sessionFile && artifact.parentSessionFile === sessionFile) ||
			(artifact.parentSessionId && sessionId && artifact.parentSessionId === sessionId),
	);
}

function shortText(value: string | undefined, max = 56): string | undefined {
	if (!value) return undefined;
	const singleLine = value.replace(/\s+/g, " ").trim();
	return singleLine.length > max ? `${singleLine.slice(0, max - 1)}…` : singleLine;
}

function returnTime(timestamp: string): string {
	const date = new Date(timestamp);
	if (Number.isNaN(date.getTime())) return timestamp;

	const now = new Date();
	const sameDay = date.getFullYear() === now.getFullYear() && date.getMonth() === now.getMonth() && date.getDate() === now.getDate();
	const yesterday = new Date(now);
	yesterday.setDate(now.getDate() - 1);
	const isYesterday = date.getFullYear() === yesterday.getFullYear() && date.getMonth() === yesterday.getMonth() && date.getDate() === yesterday.getDate();
	const time = date.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
	if (sameDay) return `Today ${time}`;
	if (isYesterday) return `Yesterday ${time}`;
	const dateText = date.toLocaleDateString(undefined, {
		month: "short",
		day: "numeric",
		...(date.getFullYear() === now.getFullYear() ? {} : { year: "numeric" }),
	});
	return `${dateText} ${time}`;
}

function summaryLabel(summary: string): string | undefined {
	for (const line of summary.split("\n")) {
		const value = line.replace(/^#{1,6}\s+/, "").trim();
		if (!value || /^(summary|key findings|recommended parent action|files\/areas referenced|caveats)$/i.test(value)) continue;
		return shortText(value);
	}
	return undefined;
}

function returnTitle(artifact: ReturnArtifact): string {
	const label = shortText(artifact.taskAnchor) ?? shortText(artifact.note) ?? summaryLabel(artifact.summary);
	return label ? `Side Return · ${returnTime(artifact.timestamp)} · ${label}` : `Side Return · ${returnTime(artifact.timestamp)}`;
}

function returnLabel(loaded: LoadedReturnArtifact): string {
	return returnTitle(loaded.artifact);
}

function stripMatchingQuotes(value: string): string {
	const trimmed = value.trim();
	const first = trimmed[0];
	const last = trimmed[trimmed.length - 1];
	return trimmed.length >= 2 && (first === '"' || first === "'") && first === last ? trimmed.slice(1, -1) : trimmed;
}

function parseInboxArgs(args: string): InboxOptions {
	const parts = args.trim().split(/\s+/).filter(Boolean);
	const options: InboxOptions = { latest: false, undo: false };

	for (let i = 0; i < parts.length; i += 1) {
		const part = parts[i];
		if (part === "--latest") {
			options.latest = true;
			continue;
		}
		if (part === "--undo") {
			options.undo = true;
			continue;
		}
		if (part === "--prompt") {
			options.prompt = stripMatchingQuotes(parts.slice(i + 1).join(" "));
			break;
		}
		if (part.startsWith("--prompt=")) {
			const first = part.slice("--prompt=".length);
			options.prompt = stripMatchingQuotes([first, ...parts.slice(i + 1)].join(" "));
			break;
		}
		options.invalid = part;
		break;
	}

	if (!options.invalid && options.undo && (options.latest || options.prompt)) options.invalid = "--undo cannot combine with --latest or --prompt";
	return options;
}

async function chooseReturn(returns: LoadedReturnArtifact[], ctx: ExtensionCommandContext): Promise<LoadedReturnArtifact | undefined> {
	if (returns.length === 0 || !ctx.hasUI) return undefined;
	if (returns.length === 1) return returns[0];

	const baseLabels = returns.map(returnLabel);
	const labels = baseLabels.map((label, index) => (baseLabels.filter((other) => other === label).length > 1 ? `${label} · ${index + 1}` : label));
	const choice = await ctx.ui.select("Choose Side Pane Return:", labels);
	if (!choice) return undefined;
	return returns[labels.indexOf(choice)];
}

async function chooseReturnAction(
	loaded: LoadedReturnArtifact,
	ctx: ExtensionCommandContext,
	providedPrompt?: string,
): Promise<{ action: "import" | "import-prompt" | "dismiss"; prompt?: string } | undefined> {
	if (!ctx.hasUI) return undefined;

	const promptLabel = providedPrompt ? `Import, then ask parent: ${shortText(providedPrompt)}` : "Import, then ask parent...";
	const summary = loaded.artifact.summary;
	const preview = [returnTitle(loaded.artifact), "", summary.slice(0, 3000), summary.length > 3000 ? "\n...[preview clipped]" : ""].join("\n");
	const choice = await ctx.ui.select(preview, ["Import", promptLabel, "Dismiss", "Cancel"]);

	if (choice === "Import") return { action: "import" };
	if (choice === promptLabel) {
		const prompt = providedPrompt ?? (await ctx.ui.input("Prompt after importing Return:", ""));
		if (!prompt?.trim()) return undefined;
		return { action: "import-prompt", prompt: prompt.trim() };
	}
	if (choice === "Dismiss") return { action: "dismiss" };
	return undefined;
}

async function saveReturnArtifact(loaded: LoadedReturnArtifact) {
	const tmpFile = `${loaded.path}.tmp`;
	await writeFile(tmpFile, `${JSON.stringify(loaded.artifact, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
	await rename(tmpFile, loaded.path);
}

async function markImported(loaded: LoadedReturnArtifact, ctx: ExtensionCommandContext) {
	loaded.artifact.imported = {
		timestamp: new Date().toISOString(),
		parentSessionFile: ctx.sessionManager.getSessionFile() ?? undefined,
		parentSessionId: getSessionId(ctx),
	};
	await saveReturnArtifact(loaded);
}

async function confirmDismissal(loaded: LoadedReturnArtifact, artifacts: LoadedReturnArtifact[], ctx: ExtensionCommandContext): Promise<boolean> {
	if (!hasLaterPendingReturn(loaded.artifact, artifacts.map((other) => other.artifact))) return true;
	return ctx.ui.confirm("Dismiss Return?", "Later Return Deltas from this Side Pane may depend on it. Dismiss anyway?");
}

async function dismissReturn(loaded: LoadedReturnArtifact, ctx: ExtensionCommandContext) {
	loaded.artifact.dismissed = {
		timestamp: new Date().toISOString(),
		parentSessionFile: ctx.sessionManager.getSessionFile() ?? undefined,
		parentSessionId: getSessionId(ctx),
	};
	await saveReturnArtifact(loaded);
}

async function undoLatestDismissedReturn(returns: LoadedReturnArtifact[], ctx: ExtensionCommandContext): Promise<boolean> {
	const latest = returns
		.filter((loaded) => matchesParent(loaded, ctx) && isDismissedReturn(loaded))
		.sort((a, b) => (b.artifact.dismissed?.timestamp ?? "").localeCompare(a.artifact.dismissed?.timestamp ?? ""))[0];
	if (!latest) return false;
	delete latest.artifact.dismissed;
	await saveReturnArtifact(latest);
	return true;
}

async function refreshReturnNotice(ctx: ExtensionContext): Promise<void> {
	if (isSidePane()) return;
	const inbox = join(getAgentDir(), "herdr-side", "returns");
	const { artifacts, invalidPaths } = await readReturnInbox(inbox);
	if (invalidPaths.length > 0) {
		ctx.ui.setStatus("herdr-side-returns", "return inbox: unreadable file");
		return;
	}
	const count = artifacts.filter((loaded) => matchesParent(loaded, ctx) && isPendingReturn(loaded)).length;
	ctx.ui.setStatus("herdr-side-returns", count > 0 ? `returns: ${count} · /side-inbox` : undefined);
}

async function importSelectedReturn(
	selected: LoadedReturnArtifact,
	ctx: ExtensionCommandContext,
	pi: ExtensionAPI,
	prompt?: string,
) {
	const artifact = selected.artifact;
	const content = [
		`# ${returnTitle(artifact)}`,
		"",
		artifact.summary,
	]
		.filter((line): line is string => line !== undefined)
		.join("\n");

	pi.sendMessage({ customType: "herdr-side-return", content, display: true, details: { path: selected.path, artifact } });
	await markImported(selected, ctx);
	if (prompt) {
		if (ctx.isIdle()) pi.sendUserMessage(prompt);
		else pi.sendUserMessage(prompt, { deliverAs: "followUp" });
	}
	notify(ctx, prompt ? "Return imported; prompt sent." : "Return imported.", "info");
}

async function importReturn(args: string, ctx: ExtensionCommandContext, pi: ExtensionAPI) {
	if (isHelp(args)) {
		notify(ctx, INBOX_HELP, "info");
		return;
	}

	const options = parseInboxArgs(args);
	if (options.invalid) {
		notify(ctx, `Unexpected argument: ${options.invalid}\n${INBOX_HELP}`, "warning");
		return;
	}

	const inbox = join(getAgentDir(), "herdr-side", "returns");
	const { artifacts, invalidPaths } = await readReturnInbox(inbox);
	if (invalidPaths.length > 0) notify(ctx, `Unreadable Return file:\n${invalidPaths.join("\n")}`, "warning");

	if (options.undo) {
		if (await undoLatestDismissedReturn(artifacts, ctx)) {
			await refreshReturnNotice(ctx);
			notify(ctx, "Return restored.", "info");
		} else {
			notify(ctx, "No dismissed Returns to undo.", "info");
		}
		return;
	}

	const parentReturns = artifacts.filter((loaded) => matchesParent(loaded, ctx));
	const returns = orderedPendingLoadedReturns(parentReturns);
	if (returns.length === 0) {
		notify(ctx, "No Returns yet. In Side Pane run /return [focus].", "info");
		return;
	}

	if (options.latest) {
		await importSelectedReturn(returns[0], ctx, pi, options.prompt?.trim() || undefined);
		await refreshReturnNotice(ctx);
		return;
	}

	if (!ctx.hasUI) {
		notify(ctx, "Interactive inbox requires TUI. Use /side-inbox --latest for non-interactive import.", "warning");
		return;
	}

	const selected = await chooseReturn(returns, ctx);
	if (!selected) {
		notify(ctx, "No Return selected.", "info");
		return;
	}

	const action = await chooseReturnAction(selected, ctx, options.prompt?.trim() || undefined);
	if (!action) {
		notify(ctx, "No inbox action taken.", "info");
		return;
	}
	if (action.action === "dismiss") {
		if (!(await confirmDismissal(selected, parentReturns, ctx))) {
			notify(ctx, "Return kept.", "info");
			return;
		}
		await dismissReturn(selected, ctx);
		await refreshReturnNotice(ctx);
		notify(ctx, "Return dismissed. Undo: /side-inbox --undo", "info");
		return;
	}
	await importSelectedReturn(selected, ctx, pi, action.action === "import-prompt" ? action.prompt : undefined);
	await refreshReturnNotice(ctx);
}

function installReturnRenderer(pi: ExtensionAPI) {
	pi.registerMessageRenderer("herdr-side-return", (message) => new Markdown(String(message.content ?? ""), 0, 0, getMarkdownTheme()));
}

function installSideStatus(pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (!isSidePane() || !ctx.hasUI) return;
		if (isReadOnlySidePane()) {
			ctx.ui.setStatus("herdr-side", "side: read-only");
			ctx.ui.setWidget("herdr-side", ["Side Pane: read-only. write/edit/bash/user bash blocked. /return sends context back."], {
				placement: "belowEditor",
			});
			return;
		}
		ctx.ui.setStatus("herdr-side", "side: worker");
		ctx.ui.setWidget("herdr-side", ["Worker Session: write access enabled. /return sends context back."], {
			placement: "belowEditor",
		});
	});
}

function installReturnNotice(pi: ExtensionAPI) {
	let watcher: FSWatcher | undefined;

	pi.on("session_start", async (_event, ctx) => {
		watcher?.close();
		watcher = undefined;
		if (isSidePane()) return;

		const inbox = join(getAgentDir(), "herdr-side", "returns");
		await mkdir(inbox, { recursive: true });
		await refreshReturnNotice(ctx);
		watcher = watch(inbox, { persistent: false }, () => {
			void refreshReturnNotice(ctx);
		});
		watcher.on("error", () => {
			watcher?.close();
			watcher = undefined;
			ctx.ui.setStatus("herdr-side-returns", undefined);
		});
	});

	pi.on("session_shutdown", () => {
		watcher?.close();
		watcher = undefined;
	});
}

function installReadOnlyGate(pi: ExtensionAPI) {
	pi.on("tool_call", (event) => {
		if (!isReadOnlySidePane() || !BLOCKED_READ_ONLY_TOOLS.has(event.toolName)) return undefined;
		return { block: true, reason: `Read-only Side Pane blocks ${event.toolName}. Reopen with /side --write for Worker Session.` };
	});

	pi.on("user_bash", (event) => {
		if (!isReadOnlySidePane()) return undefined;
		return {
			result: {
				output: `Read-only Side Pane blocks user bash: ${event.command}\nReopen with /side --write for Worker Session.`,
				exitCode: 1,
				cancelled: false,
				truncated: false,
			},
		};
	});
}

export default function (pi: ExtensionAPI) {
	const backend = new HerdrBackend();

	installSideStatus(pi);
	installReturnNotice(pi);
	installReadOnlyGate(pi);
	installReturnRenderer(pi);

	pi.registerCommand("side", {
		description: "Open a herdr Side Pane. Flags: --split, --write, --fresh.",
		handler: (args, ctx) => openSide(args, ctx, pi, backend),
	});

	pi.registerCommand("return", {
		description: "Send compressed Side Pane context back to the Parent Session.",
		handler: (args, ctx) => writeReturnArtifact(args, ctx, pi),
	});

	pi.registerCommand("side-inbox", {
		description: "Open Return picker/preview. Use --latest for fast import or --undo to restore a dismissal.",
		handler: (args, ctx) => importReturn(args, ctx, pi),
	});
}
