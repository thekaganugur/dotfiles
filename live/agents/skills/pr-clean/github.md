# GitHub PR clean commands

Use these when the pinned PR is on GitHub and `gh` is authenticated.

## Pin current PR

```bash
gh pr view --json id,number,url,headRefName,headRefOid,baseRefName,baseRefOid,reviewDecision,mergeStateStatus,mergeable,statusCheckRollup,state,isDraft,isCrossRepository,headRepository,headRepositoryOwner
```

Without an argument, `gh pr view` uses the PR for the current branch. If that fails, ask for PR number or URL.

Record local state too:

```bash
git status --short
git rev-parse HEAD
```

## Freshness gate

Fetch the current base and compare it to the last-seen base before editing each queued item.

```bash
PR_NUMBER=<number>
PR_JSON=$(gh pr view "$PR_NUMBER" --json headRefName,headRefOid,baseRefName,baseRefOid,mergeStateStatus,mergeable,statusCheckRollup)
BASE_BRANCH=$(jq -r .baseRefName <<<"$PR_JSON")
HOST_BASE_SHA=$(jq -r .baseRefOid <<<"$PR_JSON")
HOST_HEAD_SHA=$(jq -r .headRefOid <<<"$PR_JSON")
LOCAL_HEAD_SHA=$(git rev-parse HEAD)

git fetch origin "+$BASE_BRANCH:refs/remotes/origin/$BASE_BRANCH"
LOCAL_BASE_SHA=$(git rev-parse "origin/$BASE_BRANCH")

echo "host base:  $HOST_BASE_SHA"
echo "local base: $LOCAL_BASE_SHA"
echo "host head:  $HOST_HEAD_SHA"
echo "local head: $LOCAL_HEAD_SHA"
```

If `LOCAL_HEAD_SHA` differs from `HOST_HEAD_SHA`, inspect why before editing; the local checkout may be behind the PR branch or contain unpublished commits.

List base changes since the last gate (skip on the first item — no prior base to diff):

```bash
LAST_BASE_SHA=<previous-base-sha>
git diff --name-only "$LAST_BASE_SHA" "$LOCAL_BASE_SHA"
```

Read-only conflict check:

```bash
if git merge-tree --write-tree --quiet HEAD "origin/$BASE_BRANCH" >/tmp/pr-clean-merge-tree 2>&1; then
  echo "no merge conflicts with current base"
else
  echo "merge conflicts with current base"
  cat /tmp/pr-clean-merge-tree
fi
```

Capture stale/pre-existing CI baseline when relevant:

```bash
gh pr checks "$PR_NUMBER" || true
```

Mutate-sync only when the gate says base staleness matters. Follow **observed style**. Examples:

```bash
# Merge-style sync
git merge --no-ff "origin/$BASE_BRANCH"
git push

# Rebase-style sync; use only when repo convention allows rewritten PR history
git rebase "origin/$BASE_BRANCH"
git push --force-with-lease
```

After any sync, refresh review threads before editing; sync can make old feedback outdated or already satisfied.

## Fetch unresolved review threads

```bash
PR_NUMBER=<number>
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)

gh api graphql --paginate --slurp \
  -F owner="$OWNER" \
  -F name="$REPO" \
  -F number="$PR_NUMBER" \
  -f query='
query($owner: String!, $name: String!, $number: Int!, $endCursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      id
      number
      url
      headRefName
      baseRefName
      headRefOid
      baseRefOid
      reviewDecision
      mergeStateStatus
      reviewThreads(first: 100, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          viewerCanReply
          viewerCanResolve
          path
          line
          startLine
          originalLine
          originalStartLine
          subjectType
          comments(first: 100) {
            totalCount
            nodes {
              id
              url
              bodyText
              createdAt
              path
              line
              originalLine
              outdated
              state
              author { login }
            }
          }
        }
      }
    }
  }
}' | jq '[.[].data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]'
```

`--paginate` walks the single outer `reviewThreads` cursor. Inner comments are capped at 100 per thread; if any thread's `comments.totalCount` exceeds 100, fetch the rest of that thread manually before editing.

## Fetch loose PR comments and review summaries

Unresolved status exists for review threads, not top-level PR comments. Scan loose feedback only for actionable requests not already answered or superseded.

```bash
gh pr view "$PR_NUMBER" --comments

gh pr view "$PR_NUMBER" \
  --json comments,reviews,latestReviews,reviewDecision,statusCheckRollup \
  -q '{reviewDecision, comments, reviews, latestReviews, statusCheckRollup}'
```

Queue loose feedback after unresolved threads. For loose feedback, reply with a top-level PR comment that quotes or names the original commenter/comment URL.

## Reply to a review thread

```bash
THREAD_ID=<thread-node-id>
BODY_FILE=$(mktemp)
cat > "$BODY_FILE" <<'EOF'
Fixed in <commit-or-branch>. Verified with:

`<command>`
EOF
# If no runnable check existed, replace the verification line with:
#   Verified by inspection: <what was checked>.

gh api graphql \
  -F thread="$THREAD_ID" \
  -F body=@"$BODY_FILE" \
  -f query='
mutation($thread: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {
    pullRequestReviewThreadId: $thread,
    body: $body
  }) {
    comment { id url }
  }
}'
```

## Resolve a review thread

```bash
THREAD_ID=<thread-node-id>

gh api graphql \
  -F thread="$THREAD_ID" \
  -f query='
mutation($thread: ID!) {
  resolveReviewThread(input: { threadId: $thread }) {
    thread { id isResolved }
  }
}'
```

Resolve only after the fix is pushed and the reply is posted. If `viewerCanResolve` is false, leave the thread unresolved and report that host permissions blocked resolution.

## Reply to loose PR feedback

```bash
BODY_FILE=$(mktemp)
cat > "$BODY_FILE" <<'EOF'
Addressed <comment-url-or-author feedback>. Verified with:

`<command>`
EOF
# If no runnable check existed, replace the verification line with:
#   Verified by inspection: <what was checked>.

gh pr comment "$PR_NUMBER" --body-file "$BODY_FILE"
```

## Publish one item patch

Follow **observed style**. If no style is clear:

```bash
git status --short
git add <files-for-this-item>
git commit -m "fix: address PR feedback"
git push
```

Keep one-item commits small enough to revert or inspect independently.

## Final status

```bash
gh pr view "$PR_NUMBER" --json reviewDecision,mergeStateStatus,mergeable,statusCheckRollup,baseRefOid,headRefOid,url
# Optional, when CI status matters for final report:
gh pr checks "$PR_NUMBER"
git status --short
```
