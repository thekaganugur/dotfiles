export interface RawSessionEntry {
	type: string;
	id?: string;
	parentId?: string | null;
	timestamp?: string;
	message?: { role?: string; content?: unknown };
	[key: string]: unknown;
}

export interface ReturnArtifactState {
	id: string;
	childSessionFile?: string;
	childSessionId?: string;
	timestamp: string;
	sequence?: number;
	startEntryId?: string;
	endEntryId?: string;
	taskAnchor?: string;
	imported?: unknown;
	dismissed?: unknown;
}

export interface ReturnRange {
	entries: RawSessionEntry[];
	sequence: number;
	startEntryId?: string;
	endEntryId?: string;
	taskAnchor: string;
}

export function activeBranch(entries: RawSessionEntry[], leafId: string | null | undefined): RawSessionEntry[] {
	if (!leafId) return [];
	const byId = new Map(entries.filter((entry) => entry.id).map((entry) => [entry.id!, entry]));
	const branch: RawSessionEntry[] = [];
	const seen = new Set<string>();
	let id: string | null | undefined = leafId;

	while (id) {
		if (seen.has(id)) throw new Error("Side Pane session has a cyclic branch");
		seen.add(id);
		const entry = byId.get(id);
		if (!entry) throw new Error("Side Pane session active branch is incomplete");
		branch.push(entry);
		id = entry.parentId;
	}
	return branch.reverse();
}

export function rebaseSummaryEntries(branch: RawSessionEntry[], parentEntryIds: ReadonlySet<string>): RawSessionEntry[] {
	const entries = branch.filter((entry) => entry.id && !parentEntryIds.has(entry.id) && entry.type !== "compaction" && entry.type !== "branch_summary");
	return entries.map((entry, index) => ({ ...entry, parentId: index === 0 ? null : entries[index - 1].id! }));
}

function childKey(artifact: Pick<ReturnArtifactState, "id" | "childSessionFile" | "childSessionId">): string {
	if (artifact.childSessionId) return `id:${artifact.childSessionId}`;
	if (artifact.childSessionFile) return `file:${artifact.childSessionFile}`;
	return `artifact:${artifact.id}`;
}

function compareReturnOrder(a: ReturnArtifactState, b: ReturnArtifactState): number {
	if (a.sequence !== undefined && b.sequence !== undefined && a.sequence !== b.sequence) return a.sequence - b.sequence;
	const timestamp = a.timestamp.localeCompare(b.timestamp);
	return timestamp || a.id.localeCompare(b.id);
}

function contentText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.filter((part): part is { type?: unknown; text?: unknown } => Boolean(part) && typeof part === "object")
		.filter((part) => part.type === "text" && typeof part.text === "string")
		.map((part) => part.text)
		.join("\n");
}

function substantiveUserPrompt(entry: RawSessionEntry): string | undefined {
	if (entry.type !== "message" || entry.message?.role !== "user") return undefined;
	const prompt = contentText(entry.message.content).trim();
	return prompt && !prompt.startsWith("/") ? prompt : undefined;
}

export function isSubstantiveSideActivity(entry: RawSessionEntry): boolean {
	return entry.type === "message" && ["user", "assistant", "toolResult"].includes(entry.message?.role ?? "");
}

export function buildReturnRange(
	entries: RawSessionEntry[],
	artifacts: ReturnArtifactState[],
	child: Pick<ReturnArtifactState, "id" | "childSessionFile" | "childSessionId">,
	note: string,
): ReturnRange {
	const related = artifacts.filter((artifact) => childKey(artifact) === childKey(child));
	const previous = related
		.filter((artifact): artifact is ReturnArtifactState & { endEntryId: string } => typeof artifact.endEntryId === "string")
		.sort(compareReturnOrder)
		.at(-1);
	let start = 0;
	if (previous) {
		const previousEnd = entries.findIndex((entry) => entry.id === previous.endEntryId);
		if (previousEnd < 0) throw new Error("Previous Return range is not on active Side Pane branch");
		start = previousEnd + 1;
	}

	const range = entries.slice(start);
	const taskAnchor = note.trim() || range.map(substantiveUserPrompt).find((prompt): prompt is string => Boolean(prompt)) || "Side Pane work";
	return {
		entries: range,
		sequence: Math.max(related.length, ...related.map((artifact) => artifact.sequence ?? 0)) + 1,
		startEntryId: range[0]?.id,
		endEntryId: range.at(-1)?.id,
		taskAnchor,
	};
}

export function loadedArtifactStates<T extends { artifact: ReturnArtifactState }>(artifacts: readonly T[]): ReturnArtifactState[] {
	return artifacts.map((loaded) => loaded.artifact);
}

export function isPendingReturn(artifact: ReturnArtifactState): boolean {
	return !artifact.imported && !artifact.dismissed;
}

export function orderedPendingReturns<T extends ReturnArtifactState>(artifacts: T[]): T[] {
	return artifacts
		.filter(isPendingReturn)
		.filter((candidate) => !artifacts.some((other) => isPendingReturn(other) && childKey(other) === childKey(candidate) && compareReturnOrder(other, candidate) < 0))
		.sort((a, b) => b.timestamp.localeCompare(a.timestamp) || a.id.localeCompare(b.id));
}

export function hasLaterPendingReturn(candidate: ReturnArtifactState, artifacts: ReturnArtifactState[]): boolean {
	return artifacts.some((other) => isPendingReturn(other) && childKey(other) === childKey(candidate) && compareReturnOrder(other, candidate) > 0);
}
