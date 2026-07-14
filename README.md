# quo-skills

Slash-commands for Claude that turn your **Quo MCP connector** into a front-desk
employee. No Zapier, no code, no other systems — if Claude can see your Quo
connector, these work.

Built and battle-tested patterns from a real business running Quo, packaged for
the Quo NYC community.

## The skills

| Command | What it does |
|---|---|
| `/quo-missed-money` | Finds missed calls that never got a callback or text-back, drafts the recovery text for each. |
| `/quo-promises` | Scans your call transcripts for commitments you made ("I'll send that over") and flags the ones you haven't kept — with a make-good draft. |
| `/quo-inbox-zero` | Triages every open text thread: who's waiting on you, who went quiet, what can close. Drafts the replies and nudges. |
| `/quo-daily-pulse` | Morning brief: yesterday's calls, missed calls needing rescue, threads awaiting reply, open tasks — and the one thing to do first. |

## The one rule every skill follows

**Draft, never auto-send.** Every skill ends at drafts for your review. Nothing
is ever sent through your Quo lines without you approving that specific message.

## Install

**Claude (claude.ai / desktop app):** Settings → Capabilities → Skills → upload
the skill's `.zip` (in `dist/`). Teams/Enterprise: an Owner uploads under
Organization Settings → Skills.

**Claude Code (CLI):** copy each skill folder into `~/.claude/skills/`, e.g.
`~/.claude/skills/quo-missed-money/SKILL.md`.

**Prerequisite:** the Quo MCP connector must be connected in the same Claude
surface (claude.ai connector settings, or `claude mcp add` for the CLI). Each
skill checks for it and tells you if it's missing.

## Privacy note

These skills read your call transcripts and messages **inside your own Claude
session** via your own Quo connector. Nothing is stored or sent anywhere else.

---

Questions, ideas, or a skill you wish existed? Bring it to the next Quo NYC
meetup.
