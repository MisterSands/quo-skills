---
name: quo-daily-pulse
description: Morning brief for Quo (OpenPhone). One screen covering yesterday and overnight — missed calls needing rescue, threads awaiting reply, notable call moments, commitments made, open tasks — ending with the single thing to do first. Invoke as /quo-daily-pulse. Read-only; sends nothing. Use when the user asks for a morning brief, daily summary, "what happened yesterday", or "what needs my attention".
---

# Quo Daily Pulse

Coffee-length brief of your phone lines. Read-only: this skill never sends
messages or modifies anything — it hands action off to the user or to the
action skills.

## Prerequisites

Requires the **Quo MCP connector**. Tool names may carry a server prefix —
match by suffix: `fetch-missed-calls`, `fetch-messages`,
`fetch-call-transcripts`, `list-tasks`, `list-inboxes`, `list-users`,
`list-contacts`. If unavailable, tell the user to connect Quo and stop.

## Procedure

### 1. Scope

Window: **since the start of yesterday, local time** (covers yesterday +
overnight). On a Monday, extend back through Friday. `list-inboxes` +
`list-users` once for line/person names. Convert all timestamps to local time.

### 2. Gather (run these lookups in parallel where possible)

- `fetch-missed-calls` — the window's missed calls.
- `fetch-messages` — recent threads; identify ones where the contact wrote
  last with something needing an answer.
- `fetch-call-transcripts` — the window's calls with transcripts.
- `list-tasks` — open Quo tasks, especially overdue ones.

### 3. Compose the brief

Keep the whole thing under one screen. Sections, in this order, skipping any
that are empty:

**Headline** — one sentence: the overall shape of the day and the single most
urgent item.

**🔴 Missed & unrecovered** — missed calls with no callback or text-back yet
(check message/call history per number, same logic as `/quo-missed-money`).
One line each: time, line, who (from `list-contacts` — never guess names),
voicemail gist if any. Exclude obvious spam.

**💬 Waiting on you** — threads where the contact wrote last and expects an
answer. One line each: how long they've waited, who, what they asked.

**📞 Yesterday's calls** — count + total talk time, then up to 3 notable
moments worth knowing about (a hot lead, an unhappy customer, a big ask), each
one line with the caller and the gist.

**🤝 Commitments made** — promises the team made on yesterday's calls ("I'll
send the quote today"), quoted briefly, so nothing is dropped. (Deep audit:
`/quo-promises`.)

**✅ Tasks** — overdue Quo tasks first, then due today. Counts + the notable
ones.

**First move** — end with one specific recommendation: the single action with
the highest payoff right now, and which skill or step handles it (e.g. "3
unrecovered missed calls from yesterday afternoon — run `/quo-missed-money`
and I'll draft the text-backs").

### 4. Style

- Facts over commentary; no filler, no praise, no "great job team".
- Names only from Quo contact records; unknown numbers stay numbers.
- If a data source returns nothing or errors, say so in one line rather than
  silently omitting the section.
- If the user reacts to an item ("handle the missed calls"), route to the
  matching skill or perform it — but any sending then follows that skill's
  draft-and-approve rule.
