---
name: requirement-analyze
description: Analyze the requirements of a feature before development starts, and make a spec for spec-driven development (SDD). Find the critical points and gaps in the business logic. Write a feature spec with numbered requirements and acceptance criteria that a test can check. Make a list of open questions in two groups. Blocking questions stop development until they get an answer. Important questions change details, but development can start. Use this skill when the user gives a feature idea, ticket, user story, spec, PRD or client request, and wants an analysis, a review for gaps, a feature document, a spec or a requirements.md file. Also use it when the user asks which questions to ask the client, the PM or the business before development.
---

# Requirement analysis

Find problems in the business logic early, before development starts. If you find a gap
during the analysis, it costs one question. If you find it after the release, it costs
a rewrite.

The result is one spec file with two parts:

- **Spec** — what the feature must do, and why. It contains numbered requirements and
  acceptance criteria that a test can check. The technical plan, the tasks and the tests
  use the spec as the source of truth.
- **Analysis** — critical points, open questions and assumptions. This part becomes
  smaller when answers come in. When the spec is ready, this part is empty.

## Scope of this skill

The spec tells what the feature does and why. It does not tell how. Do not write
database schemas, endpoints, class names or library choices in the spec. These items are
for the technical plan, the next SDD step.

Read the code. The code shows the current behavior and the conflicts. It also gives the
data for **Affected areas**. If you find a technical risk, write it as a critical point,
not as a design decision.

## Language

Write the spec in the language of the user. For a Ukrainian request, write a Ukrainian
spec. Do not translate code identifiers, field names, technical terms and the EARS
keywords (WHEN, IF, WHILE, WHERE, SHALL).

If the spec is in English, write it in ASD-STE100. Use the writing-style skill.

## Workflow

### 1. Collect the input

Get all the data that the user gives: the description, the ticket text, links,
screenshots and attached files.

If the project has `PRODUCT.md`, read it. Make sure that the feature agrees with the
goal, the scope and the principles of the product. A conflict is a blocking question.

If you work in a project repository, also read the code that the feature changes:
models, statuses, permissions, current flows and API. Hidden conflicts are frequently
in the current behavior.

If the input is only one sentence and it is not clear, do not stop to ask the user
questions. Analyze the data that you have. Each item that is not clear becomes a
blocking question.

### 2. Tell the feature in your words

Write 2–5 sentences: who uses the feature, which problem it solves, and what changes for
the user. If you cannot do this, the main goal is not clear. Make this the first
blocking question.

### 3. Find the critical points

Use the checklist below. Keep only the items that apply to this feature. For each item,
ask: *What occurs if this goes wrong? Does the requirement tell how it must work?*

- **Actors and access** — roles. Who can see, create, edit or delete. Ownership. What a
  user without permission sees.
- **States and transitions** — the statuses of the entity and the permitted transitions.
  Who starts each transition. Can the status go back? What occurs to the dependent data?
- **Business rules and calculations** — formulas, prices, limits, rounding, currency,
  taxes, discounts and quotas. The source of each number.
- **Data** — required and optional fields, validation, unique values, formats and
  maximum sizes. What occurs to the current data (migration, backfill).
- **Edge cases** — empty state, first use, zero, negative and very large values,
  duplicates, deleted or archived related entities, and actions that stop before they
  are complete.
- **Concurrency and time** — two users edit at the same time, a user submits two times,
  retries, time zones, deadlines, scheduled jobs and expiration.
- **Integrations** — external APIs, payments, emails, push messages and webhooks. What
  occurs when they are slow, not available, or send an error.
- **Errors and recovery** — what the user sees when an action fails. Can the user undo
  the action? Does the action leave data that is not complete?
- **Notifications** — who gets which message, through which channel, and when.
- **Conflicts with current logic** — does the feature change or contradict the current
  behavior, reports, permissions or other features?
- **Non-functional** — security, personal data and GDPR, audit log, performance and
  volumes, localization, accessibility and analytics events.
- **Rollout** — feature flag, which users get the feature first, and backward
  compatibility of the API and mobile clients. What occurs to users who are in a flow
  during the release?

Give each critical point an ID (`CP-1`, `CP-2`, …) and a risk level:

- 🔴 high — wrong behavior breaks money, data, security or the main flow.
- 🟡 medium
- 🟢 low

### 4. Write requirements and acceptance criteria

Write the feature as numbered functional requirements (`FR-1`, `FR-2`, …). Give each
requirement one or more acceptance criteria (`AC-1.1`, `AC-1.2`, …). A test must be
able to check each criterion with a clear pass or fail result. Use EARS:

- `WHEN <trigger> THE SYSTEM SHALL <response>` — for an event
- `IF <unwanted condition> THEN THE SYSTEM SHALL <response>` — for errors and edge cases
- `WHILE <state> THE SYSTEM SHALL <response>` — for a state
- `WHERE <feature or configuration is present> THE SYSTEM SHALL <response>` — for
  optional behavior
- `THE SYSTEM SHALL <response>` — for behavior that is always true

Write only one behavior in each criterion. Give specific values, statuses and messages.
Do not use words such as "quickly", "correctly" or "user-friendly". Cover the main flow
and the edge cases from step 3. If an edge case has no acceptance criterion, nobody
will write a test for it.

Write the business rules that apply to more than one requirement as `BR-n`. For example,
formulas, limits and rounding. Refer to them from the criteria.

Each non-functional requirement (`NFR-n`) must have a value that you can measure. For
example, write "p95 response time is less than 300 ms at 50 rps", not "fast".

Do not change IDs. Plans, tasks and tests refer to them. If you remove a requirement, do
not use its number again. Mark it as `~~FR-3~~ removed — see D2`.

### 5. Make questions from the gaps

If the requirement does not tell something, is not clear, or contradicts itself, write
a question.

- **🚫 Blocking** — without an answer, development cannot start, or the team will
  probably do the work again. Typical areas: the main flow, the data model, business
  rules, money, permissions and legal items.
- **❗ Important** — the answer changes details, but a developer can start and adjust
  later. Typical areas: texts, UI details, limits that are easy to change,
  notifications, and edge cases with a good default.

Rule: *If a wrong guess changes the database or the main flow, the question is
blocking.*

Write each question so that a business person can answer in one line. Give the context,
the reason and the options. For each important question, give a default: "If there is
no answer, we do X."

Do not answer a question yourself and show the answer as a requirement. Write your
guesses in **Assumptions**.

Put a marker in the spec at the location of the gap. Then the reader sees which
requirement depends on which question:

`AC-2.3 WHEN the refund fails THE SYSTEM SHALL [NEEDS CLARIFICATION → B2]`

Do not add questions only to make the list longer. Five clear questions are better than
thirty general questions.

### 6. Write the spec

Use the template below. Remove the sections that are empty for this feature.

Save the spec at the first location that applies:

1. If the project uses an SDD tool or keeps specs in a folder, use that location.
   - Spec Kit: `specs/<NNN>-<feature-slug>/spec.md`
   - Kiro: `.kiro/specs/<feature-slug>/requirements.md`
2. If you work in a project repository, use `docs/features/<feature-slug>/spec.md`. If
   the project has no `docs/` structure, propose the templates of the ai-workflow
   repository (`PRODUCT.md`, `docs/tech/`, `docs/features/`) to the user.
3. If you do not work in a repository, show the spec in the reply.

After the spec, tell the user these items in 2–3 lines:

- the number of requirements
- the number of blocking and important questions
- the critical point with the highest risk

## Template

```markdown
# <Feature name>

**Status:** Draft — waiting for answers · **Date:** <YYYY-MM-DD>

## Summary
<2–5 sentences: who, which problem, what changes>

## Goal and success criteria
- <a result that you can measure and that shows that the feature works>

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

## Requirements

### FR-1: <short name>
<one sentence: what and why>

- **AC-1.1** WHEN ... THE SYSTEM SHALL ...
- **AC-1.2** IF ... THEN THE SYSTEM SHALL ...

## Business rules
- **BR-1:** ...

## Non-functional requirements
- **NFR-1:** <a value that you can measure>

## Dependencies
- ...

## Affected areas
<current modules, screens, APIs and reports that change. Get them from the code if it is available.>

## Decisions
| # | Question | Decision | Who decided | Date |
|---|----------|----------|-------------|------|
| D1 | ... | ... | ... | ... |

---

# Analysis

## Critical points
| # | Risk | Area | What can go wrong | What the requirement does not tell | Covered by |
|---|------|------|-------------------|------------------------------------|------------|
| CP-1 | 🔴 | ... | ... | ... | AC-1.2 / B1 |

## Questions

### 🚫 Blocking
| # | Question | Why it blocks | Options | Who answers |
|---|----------|---------------|---------|-------------|
| B1 | ... | ... | A) ... B) ... | PM / Business / Tech lead |

### ❗ Important
| # | Question | Effect | Default if there is no answer | Who answers |
|---|----------|--------|-------------------------------|-------------|
| I1 | ... | ... | ... | ... |

## Assumptions
- **A1:** ... (confirm or correct)
```

## When the user answers

Update the same file:

1. Write each answer into the spec as a requirement, an acceptance criterion or a
   business rule.
2. Replace the `[NEEDS CLARIFICATION]` marker.
3. Record the answer in **Decisions**: the question, the answer, who answered, and the
   date.
4. Remove the question.
5. Examine if the answer causes new questions or changes the current criteria.

If the user tells you to continue with the defaults, change the important questions to
assumptions with their defaults. Mark them *accepted default*.

Do not use a default for a blocking question. A blocking question stays blocking until
a person answers it.

## Definition of ready

Change the status to **Ready for development** only when all these conditions are true:

- There are no blocking questions.
- There are no `[NEEDS CLARIFICATION]` markers.
- Each FR has one or more acceptance criteria.
- An acceptance criterion or a decision covers each 🔴 critical point.
- Each assumption is confirmed or marked *accepted default*.
- The spec tells what is out of scope.
- Each NFR has a value that you can measure.

When the spec is ready, the Analysis part contains only answered critical points and
accepted assumptions.

Tell the user that the spec is ready. Then tell the user the next steps:

- The test-checklist skill can make a test checklist from this spec.
- The next SDD step is the technical plan (architecture, data model, API). After the
  plan come the tasks. Each task refers to the FR and AC IDs.
