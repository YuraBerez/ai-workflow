---
name: requirement-analyze
description: Analyze a feature's requirements before development starts. Find the critical points and gaps in the business logic, write a feature document, and list open questions split into blocking (development cannot start without an answer) and important (they refine details but do not block development). Use when the user shares a feature idea, ticket, user story, spec, PRD or client request and wants it analyzed, clarified, reviewed for gaps, or turned into a feature document, or asks what questions to ask the client/PM/business before building something. Triggers also on Ukrainian requests like "проаналізуй вимоги", "які питання до фічі", "розбери фічу".
---

# Requirement analysis

The goal is to catch problems in the business logic **early**, before anyone writes code.
A missed rule found during analysis costs a question; found after release it costs a rewrite.

The result is one document: what the feature is, what is critical in it, and which
questions must be answered — split into **blocking** and **important**.

## Language

Write the document in the language the user writes in (Ukrainian request → Ukrainian
document). Keep code identifiers, field names and technical terms as they are.

## Workflow

### 1. Collect the input

Take everything the user gave: the description, ticket text, links, screenshots,
attached files. If the work happens inside a project repository, also look at the
code that the feature touches (models, statuses, permissions, existing flows, API).
Existing behaviour is the most common source of hidden conflicts.

If the input is one vague sentence, do not stop to interrogate the user. Analyze what
is there; the vagueness itself becomes blocking questions.

### 2. Restate the feature

In 2–5 sentences: who uses it, what problem it solves, what changes for the user.
If you cannot restate it, the main goal is unclear — that is the first blocking question.

### 3. Find the critical points

Go through the checklist and keep only what applies to this feature. For each point
ask: *what happens if this goes wrong, and does the requirement say how it must work?*

- **Actors and access** — roles, who can see / create / edit / delete, ownership,
  what an unauthorized user sees.
- **States and transitions** — statuses of the entity, allowed transitions, who
  triggers them, can it go back, what happens to dependent data.
- **Business rules and calculations** — formulas, prices, limits, rounding, currency,
  taxes, discounts, quotas; where the numbers come from.
- **Data** — required vs optional fields, validation, uniqueness, formats, max sizes,
  what happens to existing data (migration, backfill).
- **Edge cases** — empty state, first use, zero / negative / huge values, duplicates,
  deleted or archived related entities, partial completion.
- **Concurrency and time** — two users editing at once, double submit, retries,
  timezones, deadlines, scheduled jobs, expiration.
- **Integrations** — external APIs, payments, emails, push, webhooks: what happens
  when they are slow, down, or return an error.
- **Errors and recovery** — what the user sees on failure, can the action be undone,
  is anything left half-done.
- **Notifications** — who is told about what, through which channel, when.
- **Conflicts with existing logic** — does the feature contradict or change current
  behaviour, reports, permissions or other features.
- **Non-functional** — security, personal data / GDPR, audit log, performance and
  volumes, localization, accessibility, analytics events.
- **Rollout** — feature flag, who gets it first, backward compatibility of API and
  mobile clients, what happens to users mid-flow during release.

Mark each found point by risk: 🔴 high (wrong behaviour breaks money, data, security
or the main flow), 🟡 medium, 🟢 low.

### 4. Turn gaps into questions

Every point where the requirement is silent, ambiguous or contradictory becomes a question.

- **🚫 Blocking** — without an answer development cannot start or would likely be
  rebuilt: the main flow, data model, business rules, money, permissions, legal.
- **❗ Important** — the answer changes details but a developer can start and adjust
  later: texts, UI details, limits that are easy to change, notifications, edge cases
  that can use a sensible default.

Rule of thumb: *if the wrong guess means changing the database or the main flow — it
is blocking.*

Each question must be answerable. Write it so the business person can reply in one line:
give the context, why it matters, and the options. For important questions propose a
default ("If no answer — we do X"). Never answer a question yourself and present it as
a requirement; put your guesses in **Assumptions**.

Do not pad the list. Five sharp questions are better than thirty generic ones.

### 5. Write the document

Use the template below. Drop sections that are empty for this feature.

If you are in a project repository, save it as `docs/requirements/<feature-slug>.md`
(create the folder if needed) unless the project already keeps such documents
elsewhere — then follow the project. Otherwise show the document in the reply.

After the document, tell the user in 2–3 lines: how many blocking and important
questions there are, and the single riskiest point.

## Template

```markdown
# <Feature name>

**Status:** Draft — waiting for answers · **Date:** <YYYY-MM-DD>

## Summary
<2–5 sentences: who, what problem, what changes>

## Goal and success criteria
- <what result shows the feature works>

## Scope
**In scope:**
- ...

**Out of scope:**
- ...

## Actors and permissions
| Role | Can do |
|------|--------|
| ... | ... |

## Main flow
1. ...

## Alternative flows and edge cases
- ...

## Business rules
- BR-1: ...

## Critical points
| # | Risk | Area | What can go wrong | What is missing in the requirement |
|---|------|------|-------------------|------------------------------------|
| 1 | 🔴 | ... | ... | ... |

## Questions

### 🚫 Blocking
| # | Question | Why it blocks | Options | Who answers |
|---|----------|---------------|---------|-------------|
| B1 | ... | ... | A) ... B) ... | PM / Business / Tech lead |

### ❗ Important
| # | Question | Impact | Default if no answer | Who answers |
|---|----------|--------|----------------------|-------------|
| I1 | ... | ... | ... | ... |

## Assumptions
- A1: ... (confirm or correct)

## Dependencies
- ...

## Affected areas
<existing modules, screens, APIs, reports that change — fill from the code if available>
```

## When the user answers

When answers come back, update the same document: move answered questions into
business rules or flows, delete the question, re-check whether an answer creates new
questions, and change the status to **Ready for development** only when no blocking
questions are left.
