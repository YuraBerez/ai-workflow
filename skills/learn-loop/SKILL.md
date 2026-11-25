---
name: learn-loop
description: At the end of a task, find the lessons, corrections and decisions that will help in a future session, and save them in the correct store - memory, glossary, ADR, runbook or skill. Obey a strict rule against too much content. The default action is to discard. Use this skill after a large task, after the user corrected you, after a lint, test or CI failure that you had to correct, or when the user asks you to remember something or to do a retrospective. Do not use it for small edits, questions and answers, or read-only research.
---

# Learn loop

At the end of a task, make the experience of the task into knowledge that a future
session can use. Do not add content that a future session does not need. Each line that
is always loaded costs context in each session.

**The default action is to discard.** Most tasks give nothing that you must keep.

## When to use this skill

Use it after these tasks:

- a feature, or a fix that is not small
- a decision
- a debug session
- a task where the user corrected you
- a task where you had to correct a lint, type check, test or CI failure

Do not use it after small edits, questions and answers, or read-only research. These
tasks give nothing to keep.

## Procedure

### 1. Decide if there is something to learn

If the task was small, tell the user "Nothing to keep", and stop.

### 2. Find the signals in the session

- **Corrections from the user** — always save them as a `feedback` memory.
- **Confirmed approaches** — the user agreed with an approach that was not obvious.
- **Failures that you corrected** — a lint, type check, test or CI failure.
- **New terms** — a domain term, role, status or category that the glossary does not
  have.
- **Decisions** — a decision that is hard to reverse, is a surprise, and has a real
  trade-off. This is an ADR candidate.
- **Procedures** — a procedure with many steps that you will do again. This is a skill
  candidate.
- **Problems across repositories** — a difference between two repositories that caused
  a problem.

### 3. Do the test for each candidate

Keep a candidate only if both conditions are true:

1. It will help a future session.
2. A future session cannot get it from the code, the git history or the current docs.

If one condition is false, discard the candidate.

### 4. Find duplicates first

Before you write, look for a memory, glossary entry, ADR, runbook or skill that already
has this fact. If you find one, update it. Do not make a duplicate. Add `[[name]]` links
to related memories.

### 5. Send each candidate to the correct store

| Candidate | Store | Approval |
|-----------|-------|----------|
| A personal preference of the user, a fact about the user, a correction of your work style | Personal memory: `~/.claude/projects/<project>/memory/`, type `feedback` or `user` | Write it now |
| A project fact for the team, a problem across repositories, a reference to an external system | Project memory: `.claude/memory/`, if the project has it. If not, personal memory with type `project` or `reference` | Write it now |
| A new domain term, role, status or category | The glossary of the project, for example `CONTEXT.md` | Propose and wait |
| A decision and its reason | An ADR in `docs/tech/adr/`, with the template and the index of the project | Propose and wait |
| A failure class that occurs for the second time | A runbook in `docs/tech/runbooks/<topic>.md`, with a line in the runbook index | Write it now |
| A procedure that you will do again | A new skill: `.claude/skills/<name>/SKILL.md` in the project, or a skill in the personal skills repository | Propose and wait |
| A rule for an agent | The memory, and the file of the agent: `.claude/agents/<name>.md` | Propose and wait |
| Nothing that you must keep (the usual result) | Discard | — |

**Write it now:** write the file after you look for duplicates. Then add a one-line
pointer to the `MEMORY.md` index of that store.

**Propose and wait:** show the user the file or the diff that you will write. Write it
only after the user approves.

If the project does not have a store from this table, do not make it without approval.
Use the memory instead.

### 6. Tell the user the result

Write one line for each item:

- each file that you wrote or updated, with its path
- each candidate that you discarded, with the reason

## Memory format

Write one fact in each memory file:

```markdown
---
name: <short-kebab-case-name>
description: <one line that tells when the memory applies>
metadata:
  type: user | feedback | project | reference
  verified: <YYYY-MM-DD>
---

<the fact>

**Why:** <the reason, or the event that caused it>
**How to apply:** <when and how a future session uses it>
```

Use the **Why** and **How to apply** lines for `feedback` and `project` memories. Use
`verified` for the date when you last examined the fact.

## Rules against too much content

Obey these rules. They keep the loop safe.

1. **Do not write lessons into procedure docs.** `CLAUDE.md` and `AGENTS.md` contain
   procedures and rules, not stories, lessons or reasons. Put lessons in a memory, an
   ADR or the glossary.
2. **Discard by default.** Keep only what passes the test in step 3.
3. **Write one fact in each file.** Only the one-line `MEMORY.md` index is always
   loaded. The body of a memory loads only when its description applies.
4. **Update, do not duplicate.** If an entry already has the fact, update it.
5. **Get approval for stores that many people read.** ADRs, the glossary, skills and
   agent files need approval.
6. **Remove old entries.** If a memory is wrong or old, correct it or delete it.
7. **Make the connection as strong as the risk.** A team rule is a rule that causes a
   bug if a person breaks it. A memory body alone is not sufficient for a team rule. A
   future session must find it:
   - Name the rule clearly in the `MEMORY.md` index line.
   - If possible, add a gate that enforces it: a lint, a CI step, a test or a hook.

   A personal memory alone is never sufficient for a team rule.

## Examine before you write

- Does a memory, ADR, glossary entry or skill already have this fact? Update it. Do not
  duplicate it.
- Can a future session get it from the code, the git history or the docs? Discard it.
- Do you write a lesson into `CLAUDE.md` or `AGENTS.md`? Stop. Put it in a memory, an
  ADR or a doc.
- Is it a team rule that is only in the body of a memory? Stop. Connect it with rule 7.
