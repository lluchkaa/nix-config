---
name: slack-triage
description: Fetches recent Slack activity and surfaces only what needs the user's attention — unanswered DMs, unresolved @mentions, pending questions. Reads the last 12 hours, checks thread context, deduplicates, prioritizes, and returns a tight bullet list. Use this skill whenever the user asks to check Slack, review notifications, see what needs a response, check what's waiting on them, or wants a Slack digest — even if they don't say "triage" explicitly.
---

# Slack Triage

Surface only the Slack messages that genuinely need the user's attention. No noise, no already-handled items, no bots.

## Your identity

Your Slack user ID is **U096AJBR2G0**. Use this to detect mentions and check whether the user has replied.

## Step 1: Compute the time window

Calculate the Unix timestamp for 12 hours ago (current time minus 43200 seconds). You'll pass this as the `after` parameter to searches.

## Step 2: Fetch DMs and mentions in parallel

Run both searches simultaneously:

**Direct messages and group DMs** — messages sent directly to you:
```
query: "to:me"
channel_types: "im,mpim"
after: <12h_ago_unix_timestamp>
sort: "timestamp"
include_bots: false
limit: 20
```

**Channel mentions** — messages where you were @-mentioned in a channel:
```
query: "<@U096AJBR2G0>"
channel_types: "public_channel,private_channel"
after: <12h_ago_unix_timestamp>
sort: "timestamp"
include_bots: false
limit: 20
```

Discard any result where the sender appears to be a bot or integration (bot_id present, username ends in "bot", or sender is an app like GitHub, Jira, Datadog, etc.).

## Step 3: Fetch thread context for each result

For each message that is part of a thread (has a `thread_ts`), use `slack_read_thread` to fetch the full thread. This tells you:
- Whether you (U096AJBR2G0) have replied after the mention/message
- Whether there are new messages after your last reply directed at you

You can fetch multiple threads in parallel.

## Step 4: Decide if action is needed

Keep a message if **either** of these is true:
- You have **not replied at all** after being mentioned or messaged
- You replied, but **new messages came in after your reply** that contain a question or request directed at you

Skip a message if:
- Your last reply is the most recent meaningful message
- No unresolved question or request remains directed at you

## Step 5: Group into action items

Collapse related messages into a single bullet:
- Multiple messages in the same thread → one bullet
- Multiple DMs from the same person clearly about the same topic → one bullet
- Use judgment: if several messages clearly relate to one request or decision, merge them

## Step 6: Prioritize

Order bullets by this hierarchy:

1. **Urgency signal** — message contains: "urgent", "ASAP", "asap", "blocking", "critical", "deadline", "today", "EOD", "eod", "need this", "time sensitive"
2. **Direct DM** (`im` channel type)
3. **Group DM** (`mpim` channel type)
4. **Channel mention** (`public_channel` or `private_channel`)

Within each tier, order by recency — newest first.

## Step 7: Format the output

Each bullet follows one of these formats:

- **DM or group DM**: `• Sender: action item`
- **Channel mention**: `• Sender (#channel-name): action item`

The action item is one short sentence, verb-first, describing what they need from you:

```
• Alice: needs your approval on the deployment plan before EOD
• Bob (#backend): asking whether the DB migration is safe to run
• Carol: wants to know if you're free for the 3pm sync
• Dave (#eng-general) + 2 others: waiting on your decision about the API versioning approach
```

If multiple people are involved in a thread, you can write `Sender + N others`.

If nothing needs attention: respond with just **"All clear."**

## Notes

- Be concise in the action item — one verb phrase, not a full paragraph
- Don't summarize the whole conversation, just what's needed from the user
- If the message is ambiguous (might be a question, might not), lean toward including it
- Don't include timestamps in the output
