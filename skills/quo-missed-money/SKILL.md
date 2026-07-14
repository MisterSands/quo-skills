---
name: quo-missed-money
description: Missed-call recovery for Quo (OpenPhone). Finds missed calls that never got a callback or text-back and drafts a personalized recovery text for each. Invoke as /quo-missed-money [window] (default: last 24 hours). Use when the user asks about missed calls, lost leads, call-backs, or recovering missed business.
---

# Quo Missed Money

Every unreturned missed call is revenue walking away. This skill finds them and
tees up the save.

## Prerequisites

This skill requires the **Quo MCP connector**. Tool names may carry a server
prefix — match by suffix: `fetch-missed-calls`, `fetch-messages`,
`fetch-call-transcripts`, `list-contacts`, `get-contact`, `list-inboxes`,
`list-users`, `send-message`. If none of these tools are available, stop and
tell the user to connect Quo (claude.ai → Settings → Connectors, or
`claude mcp` in Claude Code), then stop.

## The rule

**Draft, never auto-send.** Never call `send-message` until the user has seen
the exact draft text and approved it. "Send all" is acceptable only after every
draft has been shown.

## Procedure

### 1. Scope

- Window: parse the argument (`3d`, `yesterday`, `this week`). Default: **last
  24 hours**.
- Call `list-inboxes` and `list-users` once to map phone-number IDs to line
  names and people, so the report reads "Main line" not an ID.
- Timestamps from the API are typically UTC — convert to the user's local
  timezone. If you don't know it, ask once and remember it for the session.

### 2. Collect missed calls

Call `fetch-missed-calls` for the window (all inboxes unless the user scoped to
one). If the tool paginates, keep fetching until the window is covered.

### 3. Determine which were recovered

A missed call is **recovered** if, after the missed-call timestamp, either:

- an **outbound text** went to that number — check `fetch-messages` for the
  contact/number, or
- an **outbound or completed call** connected with that number — check
  `fetch-call-transcripts` / call history for the number, or
- the caller themselves reached the business again and got an answer.

Everything else is **unrecovered** — that's the money list.

### 4. Filter noise

Flag and set aside likely spam/robocalls rather than drafting texts to them:
no voicemail + unknown number + no prior relationship, toll-free/short-code
callers, or repeated sub-10-second hangups. List them separately so the user
can rescue a false positive.

### 5. Identify each caller

For each unrecovered call, try `list-contacts` / `get-contact` by phone number.
If they have message or call history, skim it for context (existing customer?
past inquiry?). Never guess or infer a name from a transcript alone — if Quo
has no name, address them neutrally.

### 6. Report

Present a compact table, most recent first:

| When | Line | Caller | Context | Voicemail? |

Then one line of totals: "X missed calls in the window, Y recovered by the
team, **Z unrecovered**."

### 7. Draft the recovery texts

For each unrecovered caller, draft a short text-back (under 300 characters):

- Identify the business and apologize lightly for missing them.
- If a voicemail transcript exists, respond to what they actually asked.
- If they're a known contact, use their first name and reference the
  relationship naturally.
- End with one clear next step (a question or an offer to call at a specific
  time). No links unless the user's business normally uses one.
- Match the tone of the business's own outbound messages (skim a few recent
  ones with `fetch-messages` to calibrate).

Show all drafts, numbered. Ask which to send. On approval, send each via
`send-message` **from the same line the call came in on**, and confirm what was
sent.

### 8. Wrap up

Offer two follow-ons: create Quo tasks (`create-task`) for callers who need a
phone call rather than a text, and re-run tomorrow morning. Do not create tasks
or schedule anything without a yes.
