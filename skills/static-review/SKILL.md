---
name: static-review
description: Do a static review of a code diff against a test checklist, and mark the checks that the diff implements. Read the diff without a run of the application. For each check, find the changed code that gives its expected result. Mark the check as done in test-checklist.md with a file and line reference, or record a defect. Find boundary errors, permission checks that are not on the server, invalid state transitions and other defects before testing starts. The skill works best with a test-checklist.md file from the test-checklist skill and a spec from the requirement-analyze skill (CHK, AC, BR and CP IDs). Use this skill when the user asks for a static review, a static test, a review of a diff, branch or PR against a checklist, a spec or acceptance criteria, asks which checks are done, or asks if the code implements the requirements.
---

# Static review

Examine the code diff against the checks of the test checklist. Mark each check that
the diff implements. A defect that you find in the diff costs one fix. A defect that a
tester finds costs a bug report, a fix and a new test run.

The results are:

- marks in `test-checklist.md`: `[x]` for each check that the diff implements, with a
  file and line reference
- a review file with the defects and the spec gaps

## Scope of this skill

Examine only the diff. Do not run the application. Do not change the code. If the user
asks you to correct the defects, do this only after the review is complete.

You can change only two files: the test checklist (marks and review notes) and the
review file. If the checklist is `test-checklist-<pr-key>.md`, the review file is
`static-review-<pr-key>.md`. If not, it is `static-review.md`. Do not change the
checklists of other PRs.

## Language

Write the review notes and the review file in the language of the checklist. Do not
translate IDs, code identifiers, file paths, technical terms and the verdict names.

If the text is in English, write it in ASD-STE100. Use the writing-style skill.

## Workflow

### 1. Collect the input

Find these items:

1. **The test checklist** — `test-checklist.md` next to the spec, for example
   `docs/features/<feature-slug>/test-checklist.md`. If the feature has one checklist for
   each PR (`test-checklist-<pr-key>.md`), use the checklist of the PR that you examine.
   If the user gives a different checklist, use it.
2. **The spec** — `spec.md` or `requirements.md` in the same folder. Use it to read the
   full text of the acceptance criteria and business rules.
3. **The diff** — use the first item that applies:
   - the PR, commit range or branch that the user gives
   - the changes of the current branch: `git diff <main-branch>...HEAD`
   - the changes that are not committed: `git diff HEAD`

If there is no checklist, tell the user to run the test-checklist skill first. Do not
continue without a checklist.

If the diff is empty, tell the user. Do not examine the full code base instead.

### 2. Connect the diff to the checks

Read the full diff. For each changed file, find the checks that it applies to. Use the
spec IDs, the names of fields, statuses, roles and messages, and the entry points.

Then put each check into one group:

- **In the diff** — the diff adds or changes code for this check. Examine it in step 3.
- **Done before** — the check has `[x]`, and the diff does not change its code. Do not
  examine it again.
- **Done before, changed now** — the check has `[x]`, and the diff changes its code.
  Examine it again in step 3.
- **Not in the diff** — the diff has no code for this check. Do not change the check.

To understand a change, you can read the code around it: the full function, the
callers, the validation, the permission checks and the tests. But give a verdict only
for the behavior that the diff adds or changes.

### 3. Examine each check in the diff

For each check, find the code that gives the expected result. Follow the path from the
entry point to the data that is saved or sent. Do not stop at the first function that
has a correct name. Then give the check one verdict:

| Verdict | When to use it | Mark in the checklist |
|---------|----------------|-----------------------|
| ✅ Done | The diff gives the expected result on all paths. You can show the lines. | `[x]` |
| 🐞 Defect | The diff gives a different result. | `[ ]` |
| ⚠️ Partly | The diff gives the expected result only on some paths, or only some parts of it. | `[ ]` |
| 🔍 Runtime only | The result depends on items that the code does not show: performance, visual layout, browsers, the environment, an external service. | `[ ]` |
| ⛔ Blocked | The check has an open question of the spec. | `[ ]` |

Obey these rules:

- **Show evidence for each verdict.** Give the file and line
  (`src/orders/refund.ts:42`) and the condition or statement that proves the verdict.
  Do not give ✅ without a reference.
- **Examine the real condition, not the name.** A function with the name
  `validateAmount` can have no maximum. Read the body.
- **Examine all paths.** A rule in the UI is not a rule on the server. If an API call
  can go around the rule, the verdict is ⚠️ or 🐞.
- **Compare the exact values.** Compare limits, statuses, messages and error codes with
  the expected result. A different message text is a defect if the spec gives the text.
- **Do not guess.** If you cannot prove the verdict from the code, use 🔍. Tell which
  data or test you need.
- **Remove the mark if the code is broken now.** If a check has `[x]` and the diff
  breaks it, change the mark to `[ ]` and record a 🐞 defect. This is a regression.

For each check, also record if an automated test covers it: `test: yes` (with the file)
or `test: no`.

### 4. Use the technique of each check

The technique tag of a check tells what to examine in the diff:

- **EP** — each invalid class has a validation that rejects it. Each valid class goes
  through all validations.
- **BVA** — each comparison operator against the boundary: `>` or `>=`, `<` or `<=`.
  Examine off-by-one errors, rounding of money, the type of the number (integer, float,
  decimal), and the time zone of dates.
- **DT** — each column of the decision table has one branch in the code. Find branches
  that the table does not have, and columns that the code does not have.
- **ST** — compare the state table with the code. Find each location that changes the
  status. Each transition that the code permits and the table does not have is a
  defect. Examine the side effects of each transition.
- **PW** — usually 🔍. Examine only the code that is different for each value, for
  example a branch for each platform or plan.
- **UC** — follow the full flow from the first action to the final result. Examine that
  each step calls the next step, and that errors stop the flow correctly.
- **EG** — examine the protection for each risk:
  - submits two times: idempotency keys, unique constraints, disabled buttons
  - concurrent edits: transactions, locks, version fields
  - external services: timeouts, retries, error processing, data that is left
    half-saved
  - permissions: a check on the server for each entry point, not only in the UI
  - input: length limits, escaping, parameterized queries
- **NF** — usually 🔍. Examine only the items that are in the code: indexes, pagination,
  queries in loops, caching, the content of audit logs.
- **RG** — examine that the diff did not change the current behavior of the Affected
  areas.

### 5. Find changes that the spec does not have

Examine the diff in the other direction too. Find changes that no check and no
requirement describes. For example: an extra status transition, an extra field, a
different default value, or an error that the spec does not mention.

Write each item as a spec gap. Do not decide if the code or the spec is correct.

### 6. Mark the checklist

Update `test-checklist.md`. Change only the checks that you examined in step 3.

Add a review note at the end of each examined item, after ` — `. The note has the
verdict, the code reference and, for a defect, the defect ID:

```markdown
- [x] **CHK-1.1** <check> → <expected result> `AC-1.1 · UC · P1` — ✅ `src/orders/create.ts:31` test: yes
- [ ] **CHK-1.2** ❌ <check> → <expected result> `AC-1.2 · BVA · P1` — 🐞 DEF-1 `src/orders/limits.ts:18` test: no
- [ ] **CHK-2.4** <check> → <expected result> `AC-2.2 · EG · P1` — ⚠️ DEF-2 `src/orders/api.ts:77` test: no
- [ ] **CHK-X.3** <check> → <expected result> `NFR-1 · NF · P2` — 🔍 needs a load test
```

Do not change the check text, the expected result or the tags. If an item already has a
review note, replace the note.

In the header of the checklist, add or update this line:

```markdown
**Static review:** <date> · <branch or commit> · ✅ <n> · 🐞 <n> · ⚠️ <n> · 🔍 <n> · ⛔ <n> · not in the diff: <n>
```

### 7. Write the review file

Save the review file (`static-review.md` or `static-review-<pr-key>.md`) next to the
checklist. Use the template below. Remove the
sections that are empty. If you do not work in a repository, show the marked checks and
the review in the reply.

After the files, tell the user these items in 2–3 lines:

- the number of checks that the diff implements (marked `[x]`)
- the number of P1 defects, and the most dangerous defect
- the number of checks that are not in the diff or need a test run (🔍)

## Template

```markdown
# Static review: <Feature name>

**Checklist:** <path> · **Diff:** <base>...<head> · **Date:** <YYYY-MM-DD>
**Result:** ✅ <n> · 🐞 <n> · ⚠️ <n> · 🔍 <n> · ⛔ <n> · not in the diff: <n>

## Defects
1. **DEF-1** · CHK-1.2 · 🐞 · P1 — <what is wrong>. Expected: <expected result>.
   Code: `src/orders/limits.ts:18` uses `amount > MAX`, but the limit is included.
2. ...

## Spec gaps
| # | Found in | Behavior in the code | Question for the spec |
|---|----------|----------------------|-----------------------|
| G1 | `src/orders/status.ts:40` | The code permits `cancelled → paid`. | Is this transition permitted? |
```

Sort the defects by priority (P1 first). In each priority, put 🐞 before ⚠️.

Do not reuse a defect ID. When a defect is corrected, mark it as `~~DEF-1~~ corrected in
<commit>`.

## When the diff changes

Run the review again on the new diff:

1. Examine again each check with 🐞, ⚠️ or ⛔.
2. Examine again each check with `[x]` whose code the new diff changes.
3. Examine the checks that the new diff adds code for.
4. Update the marks, the review notes, the header line and `static-review.md`.

Send the spec gaps to the spec as new questions with the requirement-analyze skill.
When the spec changes, run the test-checklist skill again before the next static review.
