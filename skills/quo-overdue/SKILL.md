---
name: quo-overdue
description: Past-due task checker for Quo (OpenPhone). Sweeps open Quo tasks and reports which are overdue, due today, or undated-but-going-stale — filtered to you (by assignee, or by your lines when tasks are unassigned). Invoke as /quo-overdue [me|all|person]. Use when the user asks about overdue tasks, past-due tasks, open tasks, or what they owe people.
---

# Quo Overdue

Quo's AI creates tasks from your calls faster than anyone closes them. This
skill finds the ones going bad — including the majority that have **no due
date**, which a naive past-due check would miss entirely.

## Prerequisites

Requires the **Quo MCP connector**. Tool names may carry a server prefix —
match by suffix: `list-tasks`, `update-task`, `list-users`, `list-inboxes`,
`list-contacts`, `fetch-messages`, `send-message`. If unavailable, tell the
user to connect Quo and stop.

## The rule

**Draft, never auto-send; ask before modifying.** No `send-message` without
per-message approval. No `update-task` (completing, assigning, or setting a
due date) without the user approving that specific change.

## Procedure

### 1. Resolve "me"

- Call `list-users`. If the workspace has one user, that's "me." Otherwise ask
  once which user is the requester (or match a name given in the argument) and
  remember for the session.
- Call `list-inboxes` to learn which phone lines belong to "me" — this matters
  because most Quo tasks are unassigned.
- Scope argument: `me` (default), `all` (whole workspace), or a teammate's
  name.

### 2. Sweep tasks

`list-tasks`, following `pageToken` until exhausted or until tasks predate the
lookback (default: 30 days by `createdAt`). Keep only `status: open`.

### 3. Attribute each task

- If `assignedTo` is set: it belongs to that user.
- If unassigned (the common case): attribute it to the owner of its
  `phoneNumberId` line. A task on a shared line belongs to everyone on that
  line — include it for "me" with a "(shared line)" tag.
- Apply the scope filter. When scoping to "me" would drop unassigned tasks on
  lines the user isn't on, note the count ("12 more open tasks on other
  lines — run `/quo-overdue all` to see them") rather than hiding them
  silently.

### 4. Bucket

Using the user's local timezone (API dates are UTC):

- **🔴 OVERDUE** — `dueDate` is in the past. Sort by most overdue first.
- **🟡 DUE TODAY** — `dueDate` is later today.
- **⚠️ STALE, NO DUE DATE** — no `dueDate` and `createdAt` older than 2
  business days. These are the silent majority; sort oldest first.
- Recent undated tasks (< 2 business days) are healthy — count them but don't
  list unless asked.

Read each task's title for urgency cues ("call back at 4:30", "today",
"tomorrow") — a time-bound title with no dueDate field still belongs in
OVERDUE if that time has passed. Quo's AI writes clock times into titles
without dates; when a bare time appears ambiguous, assume it referred to the
day the task was created.

### 5. Report

Headline first: "X open tasks yours: **Y overdue**, Z due today, W going
stale." Then each bucket:

| Age / Due | Task | Line | From conversation with |

Resolve "conversation with" via the task's linked conversation/contact
(`list-contacts` by number where possible) — a task means more as "Send
Google review link → Maria R." than as a bare title. Names only from Quo
contact records; never guess.

### 6. Offer the fixes

For each listed task, offer (and act only on approval):

- **Done** — `update-task` to completed, when the user says it's handled.
- **Do it now** — if the task is itself a message to send ("send review
  link", "text the caller back"), pull recent thread context via
  `fetch-messages`, draft the message, and send on approval — then offer to
  mark the task done.
- **Snooze** — `update-task` with a real due date so it shows up in OVERDUE
  instead of rotting in STALE.

Batch shortcuts are fine ("mark 3, 5, 8 done") after the list is on screen.

### 7. Habit hook

This pairs with `/quo-daily-pulse` (which shows the counts); this skill is the
deep-clean. Suggest running it weekly, or whenever the stale bucket crosses ~10.
