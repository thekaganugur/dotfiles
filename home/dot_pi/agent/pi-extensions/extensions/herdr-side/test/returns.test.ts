import assert from "node:assert/strict";
import test from "node:test";
import {
	activeBranch,
	buildReturnRange,
	isSubstantiveSideActivity,
	loadedArtifactStates,
	orderedPendingReturns,
	rebaseSummaryEntries,
	type ReturnArtifactState,
	type RawSessionEntry,
} from "../return-range.ts";

function message(id: string, parentId: string | null, role: string, text: string): RawSessionEntry {
	return { type: "message", id, parentId, timestamp: `${id}-time`, message: { role, content: [{ type: "text", text }] } };
}

const copiedParentEntries = [message("parent-user", null, "user", "PARENT SECRET"), message("parent-answer", "parent-user", "assistant", "Parent answer")];
const compactedSidePaneEntries = [
	...copiedParentEntries,
	message("side-user", "parent-answer", "user", "Inspect return flow"),
	{
		type: "compaction",
		id: "side-compaction",
		parentId: "side-user",
		timestamp: "side-compaction-time",
		summary: "PARENT SECRET and side notes",
		firstKeptEntryId: "side-user",
		tokensBefore: 99,
	},
	message("side-answer", "side-compaction", "assistant", "Return flow inspected"),
];

const freshSidePaneEntries = [message("fresh-user", null, "user", "Check fresh pane"), message("fresh-answer", "fresh-user", "assistant", "Fresh pane works")];

function pending(id: string, childSessionId: string, sequence: number): ReturnArtifactState {
	return {
		id,
		childSessionId,
		sequence,
		timestamp: `2026-07-12T00:00:0${sequence}.000Z`,
	};
}

test("copied Parent entries and compacted history never reach Side summary source", () => {
	const branch = activeBranch(compactedSidePaneEntries, "side-answer");
	const summaryEntries = rebaseSummaryEntries(branch, new Set(copiedParentEntries.map((entry) => String(entry.id))));

	assert.deepEqual(summaryEntries.map((entry) => entry.id), ["side-user", "side-answer"]);
	assert.equal(summaryEntries[0].parentId, null);
	assert.equal(summaryEntries[1].parentId, "side-user");
	assert.doesNotMatch(JSON.stringify(summaryEntries), /PARENT SECRET|side-compaction/);
});

test("fresh Side Pane history remains intact", () => {
	const summaryEntries = rebaseSummaryEntries(activeBranch(freshSidePaneEntries, "fresh-answer"), new Set());

	assert.deepEqual(summaryEntries.map((entry) => entry.id), ["fresh-user", "fresh-answer"]);
	assert.equal(summaryEntries[0].parentId, null);
});

test("repeated Returns advance non-overlapping range and task anchor", () => {
	const firstEntries = rebaseSummaryEntries(activeBranch(compactedSidePaneEntries, "side-answer"), new Set(copiedParentEntries.map((entry) => String(entry.id))));
	const first = buildReturnRange(firstEntries, [], { childSessionId: "child" }, "");
	assert.deepEqual(first.entries.map((entry) => entry.id), ["side-user", "side-answer"]);
	assert.equal(first.sequence, 1);
	assert.equal(first.startEntryId, "side-user");
	assert.equal(first.endEntryId, "side-answer");
	assert.equal(first.taskAnchor, "Inspect return flow");

	const secondEntries = [...firstEntries, message("second-user", "side-answer", "user", "Run regression tests"), message("second-answer", "second-user", "assistant", "Tests pass")];
	const prior: ReturnArtifactState = { id: "first", childSessionId: "child", sequence: first.sequence, endEntryId: first.endEntryId, timestamp: "2026-07-12T00:00:01.000Z" };
	const second = buildReturnRange(secondEntries, [prior], { childSessionId: "child" }, "focus this instead");

	assert.deepEqual(second.entries.map((entry) => entry.id), ["second-user", "second-answer"]);
	assert.equal(second.sequence, 2);
	assert.equal(second.startEntryId, "second-user");
	assert.equal(second.endEntryId, "second-answer");
	assert.equal(second.taskAnchor, "focus this instead");
	assert.equal(buildReturnRange(secondEntries, [{ ...prior }, { ...second, id: "second", childSessionId: "child", timestamp: "2026-07-12T00:00:02.000Z" }], { childSessionId: "child" }, "").entries.length, 0);
	assert.equal(second.entries.some(isSubstantiveSideActivity), true);
});

test("loaded artifacts retain prior Return range for incremental extraction", () => {
	const entries = [message("u1", null, "user", "First task"), message("a1", "u1", "assistant", "First result"), message("u2", "a1", "user", "Second task")];
	const loaded = [{ path: "first.json", artifact: { id: "first", childSessionId: "child", sequence: 1, endEntryId: "a1", timestamp: "2026-07-12T00:00:01.000Z" } }];
	const range = buildReturnRange(entries, loadedArtifactStates(loaded), { childSessionId: "child" }, "");

	assert.equal(range.sequence, 2);
	assert.deepEqual(range.entries.map((entry) => entry.id), ["u2"]);
});

test("later Return stays unavailable until earlier Return imports or dismisses", () => {
	const first = pending("first", "child", 1);
	const second = pending("second", "child", 2);
	const other = pending("other", "other-child", 1);

	assert.deepEqual(orderedPendingReturns([first, second, other]).map((artifact) => artifact.id), ["first", "other"]);
	first.imported = { timestamp: "2026-07-12T00:01:00.000Z" };
	assert.deepEqual(orderedPendingReturns([first, second, other]).map((artifact) => artifact.id), ["second", "other"]);
	delete first.imported;
	first.dismissed = { timestamp: "2026-07-12T00:01:00.000Z" };
	assert.deepEqual(orderedPendingReturns([first, second, other]).map((artifact) => artifact.id), ["second", "other"]);
});
