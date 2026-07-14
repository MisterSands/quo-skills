---
name: quo-promises
description: Promise catcher for Quo (OpenPhone). Scans recent call transcripts for commitments the business made ("I'll send that over", "we'll call you Friday") and checks whether each was kept — with a make-good draft for the broken ones. Invoke as /quo-promises [window] [person] (default: last 7 days, whole team). Use when the user asks what they promised customers, what fell through the cracks, or wants a follow-up audit.
---

# Quo Promises

People forget what they promised on calls. Customers don't. This skill reads
your transcripts, builds a promise ledger, and drafts the make-goods.

## Prerequisites

Requires the **Quo MCP connector**. Tool names may carry a server prefix —
match by suffix: `fetch-call-transcripts`, `fetch-messages`, `list-contacts`,
`get-contact`, `list-users`, `list-inboxes`, `create-task`, `send-message`.
If unavailable, tell the user to connect Quo and stop.

## The rule

**Draft, never auto-send.** No `send-message` and no `create-task` without the
user approving that specific draft or task.

## Procedure

### 1. Scope

- Window: default **last 7 days**. Accept `14d`, `this month`, etc.
- Person/line filter: if the user names someone, resolve them via `list-users`
  / `list-inboxes` and only pull their calls.
- Convert timestamps to the user's local timezone.

### 2. Pull transcripts

`fetch-call-transcripts` for the window. Skip calls with no transcript or
under ~20 seconds. Paginate until the window is covered.

### 3. Extract promises

Read each transcript and extract commitments made **by the business side**
(the Quo user), not by the caller. A promise has three parts:

- **What**: send a quote, email a document, call back, check on an order,
  schedule something, apply a credit…
- **To whom**: the caller (resolve name via `list-contacts` — never invent a
  name from the transcript audio; transcription mangles names).
- **By when**: explicit ("by Friday") or implied ("later today", "this week").
  If no deadline was stated, treat 2 business days as the courtesy window.

Quote the actual transcript line for each promise so the user can verify. Skip
vague pleasantries ("we'll be in touch") unless the caller clearly expected
action.

### 4. Check fulfillment

For each promise, look for evidence it was kept, **after** the promise
timestamp:

- `fetch-messages` with that contact — was the thing sent or mentioned?
- later entries in the call history/transcripts — did the callback happen?

Classify: **KEPT** (evidence found), **BROKEN** (deadline passed, no
evidence), **PENDING** (not yet due), **UNCLEAR** (may have been fulfilled
outside Quo — email, in person). Be honest about UNCLEAR; don't accuse the
team of dropping something Quo can't see.

### 5. Report

Ledger, worst first:

| Status | Promised | To | By | Who promised | Evidence |

Lead with the headline: "X promises found, Y kept, **Z broken**, W pending."
Include the quoted transcript line under each broken promise.

### 6. Make-goods

For each **BROKEN** promise, draft a short recovery text: own the delay
without groveling, deliver or re-commit concretely ("I owe you that quote —
you'll have it by 3pm today"), match the business's texting tone. Show all
drafts; send only on per-message approval via `send-message`, from the line
the relationship lives on.

For each **PENDING** promise, offer to create a Quo task (`create-task`)
assigned to the promiser with the deadline, so it doesn't become next week's
broken promise. Only on approval.

### 7. Habit hook

Close by suggesting a cadence: run this every Friday afternoon — end the week
with zero broken promises. If the user wants it recurring and the surface
supports scheduled tasks, set it up on request.
