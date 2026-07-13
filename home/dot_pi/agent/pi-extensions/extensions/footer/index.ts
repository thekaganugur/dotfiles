import type {
  ExtensionAPI,
  ExtensionContext,
  ThemeColor,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { readdirSync } from "node:fs";
import { join } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

function formatCount(value: number): string {
  if (value < 1000) return String(value);
  const [scaled, suffix] =
    value < 1_000_000 ? [value / 1000, "k"] : [value / 1_000_000, "m"];
  return `${Number(scaled.toFixed(1))}${suffix}`;
}

const THINKING_COLORS: Record<string, ThemeColor> = {
  off: "thinkingOff",
  minimal: "thinkingMinimal",
  low: "thinkingLow",
  medium: "thinkingMedium",
  high: "thinkingHigh",
  xhigh: "thinkingXhigh",
  max: "thinkingMax",
};

const PR_REFRESH_INTERVAL_MS = 30_000;
const REPO_REFRESH_INTERVAL_MS = 300_000;

function formatContext(
  percent: number | null,
  tokens: number | null,
  contextWindow: number | null,
): string {
  if (percent != null)
    return contextWindow != null
      ? `${Math.round(percent)}%:${formatCount(contextWindow)} ctx`
      : `${Math.round(percent)}% ctx`;
  const capacity =
    contextWindow != null ? `/${formatCount(contextWindow)}` : "";
  if (tokens != null) return `${formatCount(tokens)}${capacity} ctx`;
  return "ctx ?";
}

function contextColor(percent: number | null): ThemeColor {
  if (percent == null) return "dim";
  if (percent > 90) return "error";
  if (percent > 70) return "warning";
  return "success";
}

interface PrInfo {
  text: string;
  url?: string;
  repoCwd: string;
}

interface GitInfo {
  branch: string | null;
  dirty: boolean;
}

function link(text: string, url?: string): string {
  if (!url) return text;
  return `\u001b]8;;${url}\u001b\\${text}\u001b]8;;\u001b\\`;
}

function sanitizeFooterText(text: string): string {
  return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

async function getPrInfo(cwd: string): Promise<PrInfo | undefined> {
  try {
    const { stdout } = await execFileAsync(
      "gh",
      ["pr", "view", "--json", "number,url"],
      {
        cwd,
        timeout: 10_000,
        maxBuffer: 32 * 1024,
      },
    );
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
      execFileAsync("git", ["branch", "--show-current"], {
        cwd,
        timeout: 2500,
        maxBuffer: 16 * 1024,
      }),
      execFileAsync("git", ["status", "--porcelain"], {
        cwd,
        timeout: 2500,
        maxBuffer: 64 * 1024,
      }),
    ]);

    return {
      branch: branchOut.trim() || null,
      dirty: statusOut.trim().length > 0,
    };
  } catch {
    return undefined;
  }
}

async function getRepoUrl(cwd: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileAsync(
      "gh",
      ["repo", "view", "--json", "url"],
      { cwd, timeout: 2500, maxBuffer: 16 * 1024 },
    );
    return (JSON.parse(stdout.trim()) as { url?: string }).url;
  } catch {
    return undefined;
  }
}

async function isGitRepository(cwd: string): Promise<boolean> {
  try {
    const { stdout } = await execFileAsync(
      "git",
      ["rev-parse", "--is-inside-work-tree"],
      { cwd, timeout: 2500, maxBuffer: 16 * 1024 },
    );
    return stdout.trim() === "true";
  } catch {
    return false;
  }
}

function prCandidateDirs(cwd: string, branch: string | null): string[] {
  if (branch) return [cwd];

  try {
    const childDirs = readdirSync(cwd, { withFileTypes: true })
      .filter((entry) => entry.isDirectory() && !entry.name.startsWith("."))
      .map((entry) => join(cwd, entry.name));

    // ponytail: cap workspace PR scan at 10; add async pool if needed.
    return [cwd, ...childDirs.slice(0, 10)];
  } catch {
    return [cwd];
  }
}

async function findPrInfo(
  cwd: string,
  branch: string | null,
): Promise<PrInfo | undefined> {
  for (const candidate of prCandidateDirs(cwd, branch)) {
    if (!branch && !(await isGitRepository(candidate))) continue;

    const prInfo = await getPrInfo(candidate);
    if (prInfo) return prInfo;
  }

  return undefined;
}

export default function (pi: ExtensionAPI) {
  let enabled = true;
  let prCacheKey: string | undefined;
  let prInfo: PrInfo | undefined;
  let prLoading = false;
  let prRequestId = 0;
  let prLastRefresh = 0;
  let gitCacheKey: string | undefined;
  let gitInfo: GitInfo | undefined;
  let gitRequestId = 0;
  let gitLastRefresh = 0;
  let repoCacheKey: string | undefined;
  let repoUrl: string | undefined;
  let repoRequestId = 0;
  let repoLastRefresh = 0;

  function refreshPrInfo(
    ctx: ExtensionContext,
    branch: string | null,
    requestRender: () => void,
    clear: boolean,
  ) {
    prCacheKey = `${ctx.cwd}:${branch ?? "no-git"}`;
    prLastRefresh = Date.now();
    const requestId = ++prRequestId;
    if (clear) prInfo = undefined;
    prLoading = !prInfo;

    void findPrInfo(ctx.cwd, branch === "detached" ? null : branch).then(
      (nextPrInfo) => {
        if (requestId !== prRequestId) return;

        prInfo = nextPrInfo;
        prLoading = false;
        requestRender();
      },
    );
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

  function refreshRepoUrl(cwd: string, requestRender: () => void) {
    repoCacheKey = cwd;
    repoLastRefresh = Date.now();
    const requestId = ++repoRequestId;

    void getRepoUrl(cwd).then((nextRepoUrl) => {
      if (requestId !== repoRequestId) return;

      repoUrl = nextRepoUrl;
      requestRender();
    });
  }

  function installFooter(ctx: ExtensionContext) {
    if (!ctx.hasUI || !enabled) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => {
        gitCacheKey = undefined;
        tui.requestRender();
      });

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          const branch = footerData.getGitBranch();
          const now = Date.now();
          const nextPrCacheKey = `${ctx.cwd}:${branch ?? "no-git"}`;
          const prCacheChanged = nextPrCacheKey !== prCacheKey;
          if (
            prCacheChanged ||
            now - prLastRefresh > PR_REFRESH_INTERVAL_MS
          ) {
            refreshPrInfo(
              ctx,
              branch,
              () => tui.requestRender(),
              prCacheChanged,
            );
          }

          const gitCwd = branch ? ctx.cwd : prInfo?.repoCwd;
          if (
            gitCwd &&
            (gitCwd !== gitCacheKey || now - gitLastRefresh > 5000)
          ) {
            refreshGitInfo(gitCwd, () => tui.requestRender());
          }
          if (
            gitCwd &&
            (gitCwd !== repoCacheKey ||
              now - repoLastRefresh > REPO_REFRESH_INTERVAL_MS)
          ) {
            refreshRepoUrl(gitCwd, () => tui.requestRender());
          }

          const currentGitInfo = gitCwd === gitCacheKey ? gitInfo : undefined;
          const displayBranch = currentGitInfo?.branch ?? branch;
          const branchText = displayBranch
            ? ` ${displayBranch}${currentGitInfo?.dirty ? "*" : ""}`
            : "no git";
          const branchUrl =
            displayBranch &&
            displayBranch !== "detached" &&
            gitCwd === repoCacheKey
              ? repoUrl && `${repoUrl}/tree/${encodeURIComponent(displayBranch)}`
              : undefined;
          const model = ctx.model?.id ?? "no-model";
          const thinking = pi.getThinkingLevel();
          const context = ctx.getContextUsage();
          const contextText = formatContext(
            context?.percent ?? null,
            context?.tokens ?? null,
            context?.contextWindow ?? null,
          );
          const contextDisplay = `${theme.fg(
            contextColor(context?.percent ?? null),
            contextText,
          )}${theme.getFgAnsi("dim")}`;
          const statuses = [...footerData.getExtensionStatuses().entries()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, status]) => sanitizeFooterText(status))
            .filter(Boolean)
            .join("  ");

          const leftParts = [
            link(branchText, branchUrl),
            prInfo
              ? link(prInfo.text, prInfo.url)
              : prLoading
                ? "PR…"
                : undefined,
          ].filter(Boolean) as string[];

          const thinkingColor = THINKING_COLORS[thinking] ?? "dim";
          const modelThinking = `${model}:${theme.fg(thinkingColor, thinking)}${theme.getFgAnsi("dim")}`;
          const rightParts = [
            modelThinking,
            contextDisplay,
            statuses || undefined,
          ].filter(Boolean) as string[];

          let left = theme.fg("accent", leftParts.join("  "));
          let right = theme.fg("dim", rightParts.join("  "));

          const compact = visibleWidth(left) + 1 + visibleWidth(right) > width;
          if (compact) {
            const compactRight = theme.fg(
              "dim",
              rightParts.slice(0, 2).join("  "),
            );
            right =
              visibleWidth(compactRight) <= width
                ? compactRight
                : theme.fg("dim", rightParts[0] ?? "");
            left = truncateToWidth(
              left,
              Math.max(0, width - visibleWidth(right) - 1),
              "…",
            );
          }

          const remainingWidth = width - visibleWidth(left) - visibleWidth(right);
          const pad = " ".repeat(
            visibleWidth(left) > 0
              ? Math.max(1, remainingWidth)
              : Math.max(0, remainingWidth),
          );
          const line = `${truncateToWidth(left + pad + right, width, "…")}\u001b]8;;\u001b\\`;
          return compact && statuses
            ? [
                line,
                `${truncateToWidth(theme.fg("dim", statuses), width, "…")}`,
              ]
            : [line];
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
