---
name: quo-inbox-zero
description: Text-thread triage for Quo (OpenPhone). Sorts every recent conversation into awaiting-your-reply, waiting-on-them, stale-worth-a-nudge, or closeable — and drafts the replies and nudges. Invoke as /quo-inbox-zero [window] (default: last 14 days). Use when the user asks what texts need answering, wants to catch up on messages, or mentions inbox overwhelm.
---

# Quo Inbox Zero

Every open thread is either your move, their move, or dead. This skill sorts
them and drafts your moves.

## Prerequisites

Requires the **Quo MCP connector**. Tool names may carry a server prefix —
match by suffix: `fetch-messages`, `list-inboxes`, `list-users`,
`list-contacts`, `get-contact`, `send-message`. If unavailable, tell the user
to connect Quo and stop.

## The rule

**Draft, never auto-send.** No `send-message` without the user approving that
specific draft.

## Procedure

### 1. Scope

- Window: default **last 14 days** of message activity. Accept overrides.
- `list-inboxes` + `list-users` once, so threads are labeled by line name.
- Convert timestamps to the user's local timezone.

### 2. Pull threads

`fetch-messages` across all inboxes in scope; group messages into
conversations per contact/number per line. Paginate until covered.

### 3. Classify each thread

Read the last few exchanges of each thread and bucket it:

- **YOUR MOVE** — the contact wrote last and it contains a question, request,
  or anything a reasonable customer expects an answer to. Sort by how long
  they've been waiting.
- **THEIR MOVE** — the business wrote last, recently (≤3 days), and the ball
  is genuinely in the contact's court.
- **STALE — NUDGE?** — the business wrote last, 3+ days ago, on a thread with
  live business value (an open quote, an unanswered offer, a lead that went
  quiet). These are silent revenue leaks.
- **CLOSEABLE** — resolved, pure logistics that completed, or clearly dead.
  No action; listed only as a count unless the user asks.
- **NOISE** — spam, verification codes, robotexts. Count only.

Judgment call, not keyword matching: a thread ending in "thanks!" is
closeable; a thread ending in "so what would that cost?" from 5 days ago is a
YOUR MOVE emergency.

### 4. Report

Lead with the headline: "X threads: **Y need your reply**, Z worth a nudge,
rest are waiting on them or closed."

Then two lists:

**Your move** (longest-waiting first):
| Waiting | Line | Contact | They asked |

**Stale — nudge?** (highest apparent value first):
| Quiet for | Line | Contact | Thread was about |

### 5. Draft

- For each **YOUR MOVE**: draft the actual answer where the thread contains
  enough information; where it doesn't (needs a price, a decision, a fact only
  the user knows), draft the reply with a `[___]` gap and say what's needed.
- For each **STALE**: draft a short, non-pushy nudge that adds something (an
  answer to their last hesitation, an easy next step) rather than "just
  checking in."
- Match the tone of the business's own outbound messages.

Show drafts numbered. Send only on approval, each from the thread's own line.

### 6. Wrap up

Report the after-state ("inbox zero" or what remains and why). Suggest a
cadence — this skill works best run daily or every other day — and mention
`/quo-missed-money` covers the calls side of the same problem.
