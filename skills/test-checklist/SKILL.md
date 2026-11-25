---
name: test-checklist
description: Make a test checklist from a feature spec with test design techniques - equivalence partitioning, boundary value analysis, decision tables, state transition, pairwise, scenario and error guessing. Each check refers to the requirement and acceptance criterion IDs of the spec. A coverage matrix shows that the checklist covers each item of the spec. The skill works best with a spec from the requirement-analyze skill (FR, AC, BR, NFR and CP IDs). It also accepts other specs, tickets, user stories or PRDs. Use this skill when the user asks for a test checklist, QA checklist, test cases, test scenarios or a test plan for a feature. Also use it when the user asks what to test, how to cover a feature with tests, or how to examine the test coverage of a spec.
---

# Test checklist

Make a checklist that covers the full spec, without extra checks. Each requirement has
checks. Each check has a reason. The reason is a test design technique, not a guess.

The result is one file with three parts:

- a checklist in groups, one group for each requirement
- a coverage matrix
- a list of spec gaps that the test design found

## Language

Write the checklist in the language of the user. For a Ukrainian request, write a
Ukrainian checklist. Do not translate IDs, code identifiers, field names, technical
terms and technique names.

If the checklist is in English, write it in ASD-STE100. Use the writing-style skill.

## Workflow

### 1. Collect the input

Find the spec. In a repository, look in the locations where the requirement-analyze
skill saves specs:

- `docs/features/<feature-slug>/spec.md`
- `specs/<NNN>-<feature-slug>/spec.md`
- `.kiro/specs/<feature-slug>/requirements.md`
- the folder where the project keeps specs

If you do not work in a repository, use the data that the user gives.

Then examine the status of the spec:

- **The spec is Ready for development.** Continue.
- **The spec is a Draft with open questions.** Continue. Mark each check that depends
  on an open question as ⛔ blocked, with the question ID (for example, `⛔ B2`). Tell
  the user that the checklist is not complete until the questions get answers.
- **There is no structured spec** (for example, a ticket or a paragraph). Continue.
  First, find the requirements yourself and give them numbers: `R-1`, `R-2`, … Then
  each check can refer to a requirement. Recommend the requirement-analyze skill to the
  user, but do not stop and wait for it.

If the code is available, read the parts that the feature changes. Real field limits,
statuses, roles and validation rules frequently show partitions and boundaries that the
spec does not tell. If the code and the spec are different, write a spec gap. Do not
test against the code.

### 2. Make the test model

Before you write checks, get these items from the spec. The techniques use them.

- **Inputs and parameters** — each field, filter, setting and value that the user or
  the system gives. Record the type, the permitted values and the limits.
- **Conditions and rules** — each item that changes the result: role, status, plan,
  flag, amount or date. Get them from the business rules and the acceptance criteria.
- **States** — the statuses of the entity, the transitions between them, and who or
  what starts each transition.
- **Flows** — the main flow and the alternative flows.
- **Risks** — the critical points (🔴 / 🟡 / 🟢) and the Affected areas of the spec.

### 3. Use test design techniques

Use each technique when its trigger is in the test model. If the trigger is not there,
do not use the technique. Write the technique on each check that it gives.

**Equivalence partitioning (EP)** — trigger: an input or a parameter.

Divide the values into classes. The system processes all values in one class in the
same way. Make valid classes and invalid classes: wrong type, wrong format, out of
range, empty, or not permitted for this role.

Write one check for each class. Use only one invalid class in each check, so that a
failure shows one cause. You can put more than one valid class in one check.

**Boundary value analysis (BVA)** — trigger: a range, length, count, amount, date or
time limit.

Check the values on each boundary and immediately next to it: `min-1`, `min`, `max`,
`max+1`. For 🔴 rules, also check `min+1` and `max-1`.

Also check `0`, empty, one item, the exact time of a deadline or expiration, and the
rounding limits for money (for example, 0.005). If the spec does not tell if the
boundary value is permitted, write a spec gap.

**Decision table (DT)** — trigger: the result depends on a combination of two or more
conditions. For example, role × status, or plan × amount × flag.

Put the table in the checklist. The conditions are the rows. Each rule is a column. The
expected action is at the bottom. If a condition has no effect in a column, write `–`
and merge the columns. Mark the combinations that cannot occur.

Write one check for each column that stays. If the spec does not give the action for a
column, write a spec gap.

**State transition (ST)** — trigger: the entity has statuses.

Make the state table: states × events. Cover these items:

- Each valid transition, one or more times (0-switch coverage).
- For 🔴 flows, each pair of transitions that follow each other (1-switch coverage).
- Invalid transitions: for each state, the events that the system must reject. Cover
  at least the events that a user can start, for example a button, an API call or an
  old browser tab.
- The side effects of each transition: dependent data, notifications and money.

**Pairwise (PW)** — trigger: three or more independent parameters, each with more than
one value. For example, platform, browser, locale, plan, payment method and client
version.

Do not test all combinations. Make a pairwise set, so that each pair of values occurs
one or more times. Add each combination that the spec or a critical point specifies.
Show the set as a table.

**Scenario / use case (UC)** — trigger: a main flow or an alternative flow in the spec.

Write one end-to-end check for each flow. The check starts with the first action of the
actor. It stops at the final result that you can see. The check for the main flow is
the smoke test.

**Error guessing (EG)** — trigger: the critical points and the usual failure areas.

For each risk that applies, write one or more checks. These are the usual failure areas:

- A user submits two times.
- A retry occurs after a timeout.
- Two users edit at the same time.
- The network connection stops during an action.
- An external service is slow or not available.
- Time zones and DST change the result.
- A related entity is deleted or archived.
- A user gets access through a direct URL or the API without permission.
- The input is very long or has special characters.
- A different browser tab shows old data.

**Non-functional (NF)** — trigger: an NFR in the spec.

Write one check for each NFR. Use the target value from the spec, and tell how to
measure it. Do not make up targets. If you cannot measure an NFR, write a spec gap.

**Regression (RG)** — trigger: the Affected areas of the spec, or conflicts with the
current logic.

Write checks that show that the current behavior of these areas did not change.

### 4. Write the checks

Write each check as one item of a Markdown checklist. The tester marks the item when the
check passes:

```markdown
- [ ] **CHK-1.2** ❌ Amount = 10 000.01 (max + 0.01) → the system shows "Amount is too large" and does not save the order. `AC-1.2 · BVA · P1`
```

Each item has these parts, in this sequence:

1. **ID** — `CHK-<FR>.<n>`, for example `CHK-2.4`. For checks that apply to more than
   one requirement, use `CHK-X.<n>`. Do not change IDs.
2. **Marks** — `❌` for a negative check. `⛔ B2` if the check depends on the open
   question B2. A positive check has no mark.
3. **Check** — one behavior: the precondition, the action and specific test data.
   Write "Amount = 10 000.01 (max + 0.01)", not "amount above the limit".
4. **Expected result** — after `→`. Get it from the spec. Write a result that you can
   see: a status, a message, a value, or the data that the system saves or sends.
5. **Tags** — in code format at the end of the item:
   - the spec IDs that the check proves, for example `AC-2.1`, `BR-3` or `CP-4`
   - the technique: EP, BVA, DT, ST, PW, UC, EG, NF or RG
   - the priority: P1 for the main flow, money, data, security and 🔴 risks. P2 for
     other acceptance criteria and 🟡 risks. P3 for 🟢 risks, texts and visual details.

Keep each item on one line. Do not use tables for checks.

Obey these rules:

- **Do not make up an expected result.** If the spec does not tell what must occur,
  write `❓ G<n>` after the arrow. Add the gap to Spec gaps.
- **Do not write duplicate checks.** If a BVA check already proves an acceptance
  criterion, do not add a different check for it. Write the two IDs in the tags.
- **Write atomic checks.** Each check has only one reason to fail. If a check examines
  two items, make two checks.
- **Write negative checks.** They are as important as positive checks. Each 🔴 critical
  point must have one or more ❌ checks.

### 5. Examine the coverage

Before you write the file, examine the conditions below. Add checks until all
conditions are true.

- Each AC has one or more checks.
- EP covers each BR. If the BR has limits, BVA also covers it.
- Each role in Actors and permissions has a positive check for an action that the role
  can do.
- Each role also has a ❌ check for an action that the role cannot do.
- Checks cover each valid state transition, and each invalid transition that a user can
  start.
- Each 🔴 critical point has a P1 ❌ check.
- Each NFR has an NF check.
- Each Affected area has an RG check.

If you cannot cover an item because the spec does not tell enough, write it in Spec gaps.

### 6. Write the file

Use the template below. Remove the sections that are empty.

Save the file next to the spec, with the name `test-checklist.md`. For example,
`docs/features/<feature-slug>/test-checklist.md`.

If `tasks.md` has a PR column, make one checklist for each PR key, with the name
`test-checklist-<pr-key>.md`. For example, `test-checklist-backend.md` and
`test-checklist-mobile.md`. Each PR is then tested and reviewed without conflicts.

- Put each check into the checklist of the PR whose tasks cover its AC.
- If a check needs more than one PR, for example an end-to-end flow from mobile to
  backend, put it into the checklist of the PR that completes the flow. Add the tag
  `needs: <pr-key>` for each other PR.
- Use one ID sequence for all checklists of the feature. A `CHK` ID occurs in only one
  file.
- Each checklist has its own coverage matrix and spec gaps for its ACs.
- Do step 5 for all checklists together: each AC of the spec must be in one or more
  checklists.

Do not use the name `checklist.md` or a `checklists/` folder. Spec Kit uses these names
for its requirement-quality checklists.

If you do not work in a repository, show the checklist in the reply.

After the file, tell the user these items in 2–3 lines:

- the number of checks for each priority (P1 / P2 / P3)
- if the coverage is complete
- the number of spec gaps and blocked checks

## Template

```markdown
# Test checklist: <Feature name>

**Spec:** <path or link> (status: <Draft / Ready>) · **Date:** <YYYY-MM-DD>
**Checks:** <total> — P1: <n> · P2: <n> · P3: <n> · ⛔ blocked: <n>

## Test model
**Inputs:** <field — type, permitted values, limits>
**States:** <list of states>. The state table below shows the transitions.

## FR-1: <requirement name>

- [ ] **CHK-1.1** <check> → <expected result> `AC-1.1 · UC · P1`
- [ ] **CHK-1.2** ❌ <check> → <expected result> `AC-1.2, BR-1 · BVA · P1`
- [ ] **CHK-1.3** ⛔ B2 <check> → ❓ G1 `AC-1.3 · BVA · P2`

## FR-2: <requirement name>

### Decision table: <what it decides>
| Condition | R1 | R2 | R3 |
|-----------|----|----|----|
| <condition> | Y | Y | N |
| <condition> | Y | N | – |
| **Action** | ... | ... | ... |

- [ ] **CHK-2.1** R1: <check> → <expected result> `AC-2.1 · DT · P1`

## State transitions

| From \ Event | <event> | <event> |
|--------------|---------|---------|
| <state> | → <state> | ✗ rejected |

- [ ] **CHK-X.1** <check> → <expected result> `AC-3.1 · ST · P1`

## Cross-cutting checks
<error guessing, pairwise set, non-functional and regression checks>

## Coverage matrix
| Spec item | Checks | Covered |
|-----------|--------|---------|
| AC-1.1 | CHK-1.1 | ✅ |
| AC-1.2 | CHK-1.2 | ✅ |
| AC-1.3 | CHK-1.3 | ⛔ B2 |

## Spec gaps
| # | Found by | Gap | Question for the spec | Blocks |
|---|----------|-----|-----------------------|--------|
| G1 | BVA on amount | The spec does not tell if 10 000 is permitted. | Is the maximum limit included? | CHK-1.3 |
```

The static-review skill marks a check as `[x]` when a code diff implements it. It adds a
review note with the code reference at the end of the item. A check with a 🔍 note
needs a test run. The tester marks it as `[x]` after the test passes.

## Send spec gaps back to the spec

Test design frequently finds items that the requirement analysis did not find. For
example, a boundary without a definition, a decision table column without an action, or
a transition that the spec does not describe.

Do not solve these gaps in the checklist. Write them in Spec gaps. Tell the user to add
them to the spec as new questions with the requirement-analyze skill. The spec stays the
single source of truth.

## When the spec changes

Update the same file:

1. Add checks for new or changed criteria.
2. Mark the checks for removed criteria as removed: `~~CHK-2.3~~ removed`. Do not use
   the ID again.
3. Remove the ⛔ mark from the checks whose questions got answers.
4. Do step 5 again to examine the coverage.
