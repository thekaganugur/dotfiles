import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext, ThemeColor } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { readdirSync } from "node:fs";
import { join } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

function formatCount(value: number): string {
	if (value < 1000) return String(value);
	if (value < 1_000_000) return `${(value / 1000).toFixed(1)}k`;
	return `${(value / 1_000_000).toFixed(1)}m`;
}

const THINKING_COLORS: Record<string, ThemeColor> = {
	off: "thinkingOff",
	minimal: "thinkingMinimal",
	low: "thinkingLow",
	medium: "thinkingMedium",
	high: "thinkingHigh",
	xhigh: "thinkingXhigh",
};

function formatContext(percent: number | null, tokens: number | null): string {
	if (percent != null) return `${Math.round(percent)}% ctx`;
	if (tokens != null) return `${formatCount(tokens)} ctx`;
	return "ctx ?";
}

interface PrInfo {
	text: string;
	url?: string;
	repoCwd: string;
}

interface GitInfo {
	branch: string | null;
	dirty: boolean;
	branchUrl?: string;
}

function link(text: string, url?: string): string {
	if (!url) return text;
	return `\u001b]8;;${url}\u001b\\${text}\u001b]8;;\u001b\\`;
}

async function getPrInfo(cwd: string): Promise<PrInfo | undefined> {
	try {
		const { stdout } = await execFileAsync("gh", ["pr", "view", "--json", "number,url"], {
			cwd,
			timeout: 10_000,
			maxBuffer: 32 * 1024,
		});
		const pr = JSON.parse(stdout.trim()) as { number?: number; url?: string };
		if (!pr.number) return undefined;

		return { text: `#${pr.number}`, url: pr.url, repoCwd: cwd };
	} catch {
		return undefined;
	}
}

async function getGitInfo(cwd: string): Promise<GitInfo | undefined> {
	try {
		const [{ stdout: branchOut }, { stdout: statusOut }] = await Promise.all([
			execFileAsync("git", ["branch", "--show-current"], { cwd, timeout: 2500, maxBuffer: 16 * 1024 }),
			execFileAsync("git", ["status", "--porcelain"], { cwd, timeout: 2500, maxBuffer: 64 * 1024 }),
		]);

		const branch = branchOut.trim() || null;
		let branchUrl: string | undefined;

		if (branch) {
			try {
				const { stdout } = await execFileAsync("gh", ["repo", "view", "--json", "url"], {
					cwd,
					timeout: 2500,
					maxBuffer: 16 * 1024,
				});
				const repo = JSON.parse(stdout.trim()) as { url?: string };
				branchUrl = repo.url ? `${repo.url}/tree/${encodeURIComponent(branch)}` : undefined;
			} catch {
				branchUrl = undefined;
			}
		}

		return { branch, dirty: statusOut.trim().length > 0, branchUrl };
	} catch {
		return undefined;
	}
}

function prCandidateDirs(cwd: string, branch: string | null): string[] {
	if (branch) return [cwd];

	try {
		const childDirs = readdirSync(cwd, { withFileTypes: true })
			.filter((entry) => entry.isDirectory() && !entry.name.startsWith("."))
			.map((entry) => join(cwd, entry.name));

		return [cwd, ...childDirs];
	} catch {
		return [cwd];
	}
}

async function findPrInfo(cwd: string, branch: string | null): Promise<PrInfo | undefined> {
	for (const candidate of prCandidateDirs(cwd, branch)) {
		const prInfo = await getPrInfo(candidate);
		if (prInfo) return prInfo;
	}

	return undefined;
}

export default function (pi: ExtensionAPI) {
	let enabled = true;
	let prCacheKey: string | undefined;
	let prInfo: PrInfo | undefined;
	let prRequestId = 0;
	let gitCacheKey: string | undefined;
	let gitInfo: GitInfo | undefined;
	let gitRequestId = 0;
	let gitLastRefresh = 0;

	function refreshPrInfo(ctx: ExtensionContext, branch: string | null, requestRender: () => void) {
		prCacheKey = `${ctx.cwd}:${branch ?? "no-git"}`;
		const requestId = ++prRequestId;
		prInfo = undefined;

		void findPrInfo(ctx.cwd, branch === "detached" ? null : branch).then((nextPrInfo) => {
			if (requestId !== prRequestId) return;

			prInfo = nextPrInfo;
			requestRender();
		});
	}

	function refreshGitInfo(cwd: string, requestRender: () => void) {
		gitCacheKey = cwd;
		gitLastRefresh = Date.now();
		const requestId = ++gitRequestId;

		void getGitInfo(cwd).then((nextGitInfo) => {
			if (requestId !== gitRequestId) return;

			gitInfo = nextGitInfo;
			requestRender();
		});
	}

	function installFooter(ctx: ExtensionContext) {
		if (!ctx.hasUI || !enabled) return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cost = 0;

					for (const entry of ctx.sessionManager.getBranch()) {
						if (entry.type !== "message" || entry.message.role !== "assistant") continue;

						const message = entry.message as AssistantMessage;
						input += message.usage?.input ?? 0;
						output += message.usage?.output ?? 0;
						cost += message.usage?.cost?.total ?? 0;
					}

					const branch = footerData.getGitBranch();
					const nextPrCacheKey = `${ctx.cwd}:${branch ?? "no-git"}`;
					if (nextPrCacheKey !== prCacheKey) refreshPrInfo(ctx, branch, () => tui.requestRender());

					const gitCwd = branch ? ctx.cwd : prInfo?.repoCwd;
					if (gitCwd && (gitCwd !== gitCacheKey || Date.now() - gitLastRefresh > 5000)) {
						refreshGitInfo(gitCwd, () => tui.requestRender());
					}

					const currentGitInfo = gitCwd === gitCacheKey ? gitInfo : undefined;
					const displayBranch = currentGitInfo?.branch ?? branch;
					const branchText = displayBranch ? ` ${displayBranch}${currentGitInfo?.dirty ? "*" : ""}` : "no git";
					const model = ctx.model?.id ?? "no-model";
					const thinking = pi.getThinkingLevel();
					const context = ctx.getContextUsage();
					const statuses = [...footerData.getExtensionStatuses().values()].join("  ");

					const leftParts = [
						link(branchText, currentGitInfo?.branchUrl),
						prInfo ? link(prInfo.text, prInfo.url) : undefined,
					].filter(Boolean) as string[];

					const thinkingColor = THINKING_COLORS[thinking] ?? "dim";
					const modelThinking = `${model}:${theme.fg(thinkingColor, thinking)}${theme.getFgAnsi("dim")}`;
					const rightParts = [
						modelThinking,
						formatContext(context?.percent ?? null, context?.tokens ?? null),
						`↑${formatCount(input)} ↓${formatCount(output)}`,
						`$${cost.toFixed(3)}`,
						statuses || undefined,
					].filter(Boolean) as string[];

					const left = theme.fg("accent", leftParts.join("  "));
					const right = theme.fg("dim", rightParts.join("  "));
					const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));

					return [truncateToWidth(left + pad + right, width, "")];
				},
			};
		});
	}

	pi.on("session_start", (_event, ctx) => {
		installFooter(ctx);
	});

	pi.registerCommand("footer", {
		description: "Toggle the custom footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;

			if (enabled) {
				installFooter(ctx);
				ctx.ui.notify("Footer enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Footer disabled", "info");
			}
		},
	});
}
