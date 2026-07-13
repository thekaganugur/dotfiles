---
name: clickup-cli
description: ClickUp task actions. Use when user explicitly asks to create, update, or read a ClickUp task, or provides an app.clickup.com/t/ task link.
---

# ClickUp CLI

## Defaults

New tasks use:

- List: `901613106990`
- Assignee: Kagan (`284639117`)

## Resolve and read

Use supplied task ID. For `https://app.clickup.com/t/WORKSPACE/CUSTOM_TASK_ID`, fetch with URL parts, then use returned canonical task ID for updates. Otherwise omit `ID`; CLI auto-detects it from current git branch.

```bash
clickup-cli task get TASK_ID --markdown
# From a ClickUp task URL:
clickup-cli task get CUSTOM_TASK_ID --workspace WORKSPACE --custom-task-id --markdown
# Or, from task branch:
clickup-cli task get --markdown
```

If CLI cannot resolve target, ask for task ID. Completion: target canonical task ID and current task values known.

## Create

Create in defaults unless user explicitly supplies a different list or assignee. Ask for task name if absent.

```bash
clickup-cli task create \
  --list 901613106990 \
  --assignee 284639117 \
  --name 'Title' \
  [--description @description.md] [--status STATUS] [--priority 1-4]
```

Completion: CLI exits `0` and returns new task ID.

## QA handoff

Product work means a feature, bug fix, or behavior change; it excludes chores, administration, and pure research. For every create or update of product work, add or replace one `## QA` section in task description:

```md
## QA

1. [action]
2. [action]

**Expected:** [visible result]
**Also check:** [regression]
```

Preserve rest of description. Use product language only. Omit QA only when user says not to.

## Update

Fetch target task before every update. Use only requested `task update` flags, except `--description` needed to add or refresh QA for product work; unspecified fields remain unchanged.

```bash
clickup-cli task update TASK_ID --name 'New title'
clickup-cli task update TASK_ID --status 'in progress'
clickup-cli task update TASK_ID --priority 2
clickup-cli task update TASK_ID --description @description.md
clickup-cli task update TASK_ID --add-assignee USER_ID
clickup-cli task update TASK_ID --rem-assignee USER_ID
```

Priorities: `1` urgent, `2` high, `3` normal, `4` low. Write multiline description to file, then use `@path`; `@@text` keeps literal leading `@`.

Ask one focused question when required update value is missing. Completion: CLI exits `0`; report task ID and changed fields. Fetch task again after update if CLI response does not show changed fields.

```bash
clickup-cli task get TASK_ID --markdown
```

For unlisted task operations, inspect CLI help first:

```bash
clickup-cli task --help
```
