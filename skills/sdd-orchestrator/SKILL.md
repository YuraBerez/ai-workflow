---
name: sdd-orchestrator
description: Run spec-driven development (SDD) with a team of agents - product manager, business analyst, legal advisor, UI/UX designer, marketing specialist, researcher, architect, architecture reviewer, security, devops, backend, web and mobile implementers, tester, code reviewer and documenter. The main session is the orchestrator. It selects a track (bugfix, small, feature or epic) and the agents that the work needs, selects the model and the effort for each task, dispatches the agents in the correct sequence, runs independent agents in parallel, stops at gates for the user, merges in the correct sequence after approval, and keeps a status file. Use this skill when the user asks to deliver a feature or a fix with SDD, to run the agent pipeline or the orchestration, to take a feature from an idea to a release, to change a requirement of a feature in progress, or to continue work that has a status.md file.
---

# SDD orchestrator

The main session is the orchestrator, because only the main session can dispatch agents.
You select, dispatch, put in sequence and stop at gates. The agents do the work.

Do not write the artifacts or the code of an agent. If a result is wrong, send it back to
the agent that owns it. You write only `status.md`, and you commit the feature folder.

The shared rules of all agents are in [contract.md](contract.md): file owners, IDs,
language, git and the report format. Do not repeat these rules in dispatch prompts.

## Team

| Agent | Phase | Writes | Modes |
|-------|-------|--------|-------|
| product-manager | 1 Brief, 8 Measure | `brief.md`, `measure.md` | `brief`, `fix`, `measure` |
| business-analyst | 2–3 Spec | `spec.md` | `draft`, `short`, `merge`, `answers`, `gaps`, `change` |
| legal-advisor | 3 Spec review | `legal.md` | `review` |
| ux-designer | 3 Spec review | `ux.md` | `review` |
| marketing-specialist | 3 and 7 | `marketing.md` | `review`, `launch` |
| researcher | when an agent needs research | `research-<topic>.md` | — |
| architect | 4 Plan | `plan.md`, `tasks.md`, ADRs | `plan`, `fix` |
| architecture-reviewer | 4 Plan | `plan-review.md` | `review`, `re-review` |
| security | 4 and 6 | `security.md`, `security-<pr-key>.md` | `plan`, `pr` |
| tester | 4–7 | `test-checklist-<pr-key>.md`, `static-review-<pr-key>.md`, `contract-check.md`, `release-check.md` | `checklist`, `static-review`, `contract`, `runtime` |
| backend-implementer, web-implementer, mobile-implementer, devops | 5 Build | code, branch, PR | `build`, `fix`, `bugfix` |
| code-reviewer | 6 Verify | PR comments | `review`, `re-review` |
| documenter | 7 Release | project docs, docs PR | `feature`, `sync` |

## Tracks

Select one track before the first dispatch. Each track uses only the phases that it
needs.

| Track | When | Phases |
|-------|------|--------|
| `bugfix` | The current behavior is wrong, and the correct behavior is known. | implementer (`bugfix`) → code-reviewer ║ tester (`runtime`, if a person can see the defect) → merge |
| `small` | One platform, one PR. No new entity, no migration, no contract change, no new dependency. | business-analyst (`short`) → tester (`checklist`) → implementer → tester (`static-review`) ║ code-reviewer → documenter, if users see the change → merge |
| `feature` | All other work. | the full pipeline below |
| `epic` | More than one feature, or more than six tasks for one platform. | product-manager makes one brief with a list of features. Then the `feature` track for each feature. |

If you are not sure, use the higher track. If a `small` or `bugfix` task needs a contract
change, a new entity or a migration, the implementer stops. Then change the track to
`feature`.

For an `epic`, run the features that do not depend on each other in parallel. Each
feature has its own feature folder and `status.md`. The first feature that needs a shared
contract owns it.

## Pipeline of the feature track

`║` shows agents that run in parallel.

```text
0 Start     read or make status.md, select the track and the route, user confirms
1 Brief     product-manager                                  → G1 user approves the brief
2 Spec      business-analyst (draft)
3 Review    legal-advisor ║ ux-designer ║ marketing-specialist (review)
            business-analyst (merge) → user answers → business-analyst (answers)
                                                             → G2 spec is Ready
4 Plan      architect
            architecture-reviewer ║ security (plan) ║ tester (checklist), max 2 rounds
                                                             → G3 plan APPROVED
5 Build     backend ║ web ║ mobile ║ devops, in waves
            tester (contract), if more than one platform     → G4 PRs open, gate green
6 Verify    tester (static-review) ║ code-reviewer ║ security (pr, high-risk PRs only)
            implementer (fix), max 3 rounds
            tester (runtime)                                 → G5 no open defects
7 Release   documenter (feature) ║ marketing-specialist (launch)
            merge plan → user approves → merge in sequence
            tester (runtime, after deploy)                   → G6 released
8 Measure   product-manager (measure), at the date of the brief
```

The researcher can run in each phase, when an agent asks for research.

Do not start a phase before its gate is complete.

## 0. Start or continue

If `status.md` exists in the feature folder, read it. Continue from the phase that it
records. After a context compaction, read `status.md` first.

If there is no `status.md`, find the location of the feature folder. Use the rules of
the requirement-analyze skill (step 6). If the project has no `PRODUCT.md` and no
`docs/tech/` and `docs/features/` folders, propose to copy them from `templates/` of the
ai-workflow repository. Copy them only after the user approves.

For the `bugfix` track, do not make a feature folder. Keep the status in the PR body and
in your replies.

Make `status.md` from this template:

```markdown
# Status: <feature name>

**Track:** <small | feature | epic> · **Phase:** <n> · **Updated:** <YYYY-MM-DD>
**Code review comments:** <post without approval | approval for each PR>
**Screenshots in PRs:** <yes | no>

## Route
| Phase | Agents | Parallel | Skipped and why |
|-------|--------|----------|-----------------|

## Gates
- [ ] G1 Brief approved by the user
- [ ] G2 Spec is Ready for development
- [ ] G3 Plan APPROVED
- [ ] G4 PRs open, gate green, contract check passed
- [ ] G5 No open defects, runtime checks passed
- [ ] G6 Released, checks after deploy passed
- [ ] Measure on <YYYY-MM-DD>

## Runs
| Date | Agent | Mode | Model · Effort | Result |
|------|-------|------|----------------|--------|

## Change requests
| # | Change | Changed IDs | Affected tasks, checks and PRs | Status |
|---|--------|-------------|--------------------------------|--------|

## Waiting for the user
- ...

## PRs and merge plan
| Order | PR key | Repo | PR | Depends on | Status |
|-------|--------|------|----|------------|--------|
```

## 1. Select the track and the route

First, select the track. Then, for the `feature` and `epic` tracks, answer these
questions from the user input and the code:

| Question | If yes | If no |
|----------|--------|-------|
| Is the problem, the goal or the scope not clear? Is it a new product area? | Use product-manager | Skip phase 1. The business-analyst uses the user input. |
| Does the feature touch personal data, payments, consent, minors, content licenses, terms of an external service, or a regulated area? | Use legal-advisor | Skip |
| Does the feature change the UI or text that the user sees? | Use ux-designer | Skip |
| Do users see the feature? Does it change acquisition, activation, conversion, prices, public pages or store listings? | Use marketing-specialist | Skip |
| Which platforms change: backend, web, mobile? | Use the implementer of each platform | — |
| Does the feature need infrastructure, CI, deploy, environment variables or secrets? | Use devops | Skip |
| Does the feature touch authentication, sessions, permissions, payments, personal data, administrator access or external input on a public entry point? | Use security | Skip |
| Does the feature add an entity or a migration, change a contract, touch more than one repository, need an ADR, or touch security, payments or personal data? | Full plan and architecture-reviewer | The architect writes a short plan. Skip architecture-reviewer. |

The `feature` route always contains business-analyst, architect, tester, code-reviewer
and documenter.

Write the track and the route in `status.md`. Show them to the user in a short table,
with the parallel groups. Ask the user two more questions:

1. Can the code-reviewer post comments on the PRs of the pipeline without approval for
   each PR?
2. Do the PRs with UI changes need screenshots?

Wait for the answers before the first dispatch. Each agent costs tokens.

## 2. Track bugfix

1. Dispatch the implementer of the platform in mode `bugfix`. Give the bug report, the
   repository and the branch name.
2. Examine the facts: the PR is open, CI is green, and the PR has a regression test that
   failed before the fix.
3. Dispatch code-reviewer in mode `review`. If a person can see the defect in the
   application, also dispatch tester in mode `runtime`, in the same message.
4. Send the defects to the implementer in mode `fix`. Use a maximum of three rounds.
5. If the cause is a gap in a spec, send it to business-analyst in mode `gaps`, for the
   spec of that feature.
6. Do the merge of phase 7, steps 3–6, for one PR.

## 3. Phases of the feature track

### Phase 1 — Brief

1. Dispatch product-manager in mode `brief`. Give the user input.
2. Show the summary of `brief.md` and the `P` questions to the user.
3. If the user corrects the brief, send the corrections to the same agent in mode `fix`.
4. G1 is complete when the user approves the brief.

### Phase 2 — Spec draft

Dispatch business-analyst in mode `draft`. The input is `brief.md`, or the user input if
phase 1 was skipped. For the `small` track, use mode `short`.

### Phase 3 — Spec review and questions

1. Dispatch legal-advisor, ux-designer and marketing-specialist (mode `review`) in one
   message. All three read the draft spec.
2. Dispatch business-analyst in mode `merge`. It adds the `L`, `UX` and `MK` findings to
   the spec as requirements or questions. If all three agents were skipped, skip this
   step.
3. Collect the blocking and important questions from `spec.md` and from the reports.
   Remove duplicates. Ask the user all questions in one group:
   - Use AskUserQuestion for questions with options, with a maximum of four questions
     in each call.
   - Use a numbered list in the reply for other questions.
4. Do not answer a question yourself. If the user tells you to use the defaults, tell
   this to the business-analyst.
5. Dispatch business-analyst in mode `answers`, with the answers of the user.
6. If an answer changes the area of legal-advisor, ux-designer or marketing-specialist,
   dispatch that agent again.
7. Do steps 3–6 again until the spec is Ready. G2 is complete when the status of
   `spec.md` is **Ready for development**.

### Phase 4 — Plan and test checklist

1. Dispatch architect in mode `plan`.
2. Dispatch architecture-reviewer in mode `review`, security in mode `plan` and tester in
   mode `checklist` in one message. The tester needs `tasks.md` to make one checklist
   for each PR key.
3. If the tester reports blocking spec gaps, send them to business-analyst in mode
   `gaps`. Then go back to phase 3, step 3.
4. If the verdict is `CHANGES`, or `security.md` has a 🔴 or 🟠 finding, send
   `plan-review.md` and `security.md` to architect in mode `fix`. Then dispatch
   architecture-reviewer in mode `re-review`. If the fix changes the PR keys or the
   Covers column of `tasks.md`, dispatch tester in mode `checklist` again.
5. After two rounds with `CHANGES`, stop and ask the user.
6. G3 is complete when the verdict in `plan-review.md` is `APPROVED`.

### Phase 5 — Build

1. Read the waves and the PR keys in `tasks.md`. Start with wave 1. Each PR key has one
   implementer, one branch and one PR.
2. Dispatch one implementer for each PR key in the wave, in one message. Use
   `isolation: "worktree"` when two implementers work in the same repository.
3. When an implementer reports `done`, examine the facts, not the report:
   - The commit is on the branch: `git branch -r --contains <sha>`.
   - The PR is open, and CI is green: `gh pr checks <n> --repo <owner>/<repo>`.
   Do not wait in the foreground. Wait for CI in the background, and do other work.
4. If the gate fails, send the failure to the same implementer in mode `fix`. If it
   fails again, increase the effort or the model (see Model and effort). Then ask the
   user.
5. If an implementer reports that a contract must change, stop the implementers that use
   this contract. Dispatch architect in mode `fix`, then architecture-reviewer in mode
   `re-review`. Then continue.
6. Start the next wave when all tasks of the current wave are complete.
7. If the feature has more than one platform, dispatch tester in mode `contract` when
   the PRs on the two sides of a contract are open. Send each mismatch to the
   implementer of the PR that is different from `plan.md`.
8. G4 is complete when each PR key has an open PR with a green gate, and
   `contract-check.md` has no open mismatch.

### Phase 6 — Verify

1. For each PR, dispatch tester in mode `static-review` and code-reviewer in mode
   `review` in one message. You can do this for all PRs in parallel, because each PR has
   its own checklist and review files.
2. For a high-risk PR, also dispatch security in mode `pr`. A high-risk PR changes
   authentication, sessions, permissions, payments, personal data, administrator access,
   migrations, CI or deploy, or more than 800 lines of source code.
3. If the user did not permit comments without approval, code-reviewer writes drafts to
   `pr-review-<n>.md`. Show the drafts to the user, and wait for approval.
4. Send the defects (`DEF` and `SEC` IDs and the review threads) to the implementer of the
   PR in mode `fix`.
5. Dispatch tester in mode `static-review` and code-reviewer in mode `re-review` again,
   only for the new commits.
6. When the static review and the code review have no open 🐞, 🔴 or 🟠 items, dispatch
   tester in mode `runtime` for each PR that has 🔍 checks or UI changes. Give the
   environment: local, or the preview environment of the PR.
7. After three rounds with open defects, stop and ask the user.
8. G5 is complete when all these conditions are true:
   - There are no open 🐞, 🔴 or 🟠 items.
   - CI is green on each PR.
   - Each check in each `test-checklist-<pr-key>.md` is `[x]`, or has a 🔍 note because
     the runtime test cannot do it. Tell the user each of these checks.

### Phase 7 — Release

1. Dispatch documenter in mode `feature` and marketing-specialist in mode `launch` in
   one message. The marketing-specialist reads the docs of the documenter, if they are
   ready. If not, it uses `spec.md` and `ux.md`.
2. Send the differences that the documenter reports to their owners. For example, a
   difference from an ADR goes to the architect.
3. Write the merge plan in `status.md`. Use the Release sequence of `plan.md`:
   - The PRs that give a contract go first, for example backend and devops.
   - The PRs that use the contract go after the deploy of the PR that gives it.
   - The docs PR goes last.
   - If a contract change is not backward compatible, the plan must give the sequence:
     for example, a feature flag, or support for the old and the new version at the same
     time.
4. Show the merge plan to the user. Merge only after the user approves this plan.
   Approval of one plan is not approval of the next plan.
5. Merge each PR in the sequence of the plan:
   - Before each merge, examine that CI is green and that no review thread is open.
   - Merge with the merge method of the project.
   - Wait for the deploy, if the merge starts one.
   - Dispatch tester in mode `runtime` with the environment of the deploy. The tester
     runs the P1 smoke checks and writes `release-check.md`.
   - If a check after deploy fails, stop the merge plan. Tell the user, and propose a
     rollback. A rollback needs a separate approval.
6. G6 is complete when all PRs of the plan are merged and `release-check.md` has no
   failed check.
7. Tell the user these items:
   - the merged PRs, also the docs PR
   - the checklist result: the number of `[x]` checks, and the checks for a manual test
   - the number of review rounds, and the items that are not complete
8. Propose the measure date from `brief.md`, for example two or four weeks after the
   release. If the user agrees, schedule it with the schedule skill.
9. Use the learn-loop skill one time for the full feature.
10. Update `status.md`.

### Phase 8 — Measure

At the measure date, dispatch product-manager in mode `measure`. It compares the metric
of `brief.md` with the real data and writes `measure.md`. Send its proposals to the user:
for example, a change of `PRODUCT.md`, a new feature, or the removal of the feature.

## Change request after G2

If the user changes a requirement after the spec is Ready:

1. Stop the dispatch of new waves. Agents that run now can complete their work.
2. Dispatch business-analyst in mode `change`. It changes the spec, gives the change a
   `CR` ID, and lists the changed `FR`, `AC`, `BR` and `NFR` IDs.
3. Find the effect from the IDs:
   - the tasks in `tasks.md` whose Covers column contains a changed ID
   - the checks in the test checklists whose tags contain a changed ID
   - the open PRs of these tasks
4. Write the change in the Change requests table of `status.md`. Show the effect to the
   user, and ask for approval to continue.
5. Dispatch again only the agents that the change affects, in the normal sequence:
   - ux-designer, legal-advisor or marketing-specialist, if the change is in their area
   - architect in mode `fix`, if the plan changes
   - tester in mode `checklist`, for the affected PR keys
   - the implementers in mode `fix`, for the affected PRs
   - tester in mode `static-review` and code-reviewer in mode `re-review`
6. Continue the waves.

## Research on request

An agent can write a research request in the Requests field of its report. If the
question needs more than a few web searches, dispatch the researcher:

1. Give the question, the decision that it is for, and the file name
   `research-<topic>.md`.
2. You can run more than one researcher in parallel, each with a different topic and
   file.
3. Send the path of the research file to the agent that asked for it.

## Dispatch rules

- **Run independent agents in parallel.** Send their Agent calls in one message.
- **Run a maximum of three agents at the same time.**
- **Do not run two agents that write the same file at the same time.** Use the owner
  table in `contract.md`.
- **Write short prompts.** Refer to files and IDs. Do not copy the spec. Give only the
  facts that the files do not have:

  ```text
  Feature folder: <path>
  Track: <bugfix | small | feature | epic> · Mode: <mode>
  Language: <language of the artifacts>
  Repo: <owner/repo> · Base: <branch> · Branch: <branch>   (implementers and reviewers)
  PR key: <key> · Tasks: <T-IDs> · Owned files: <list>     (implementers, tester, security)
  PR: <URL> · Post comments: yes | no                      (code-reviewer)
  Environment: local | preview | staging | production      (tester in mode runtime)
  Screenshots: yes | no                                    (tester in mode runtime)
  Context: <user decisions from this session that are not in a file>
  ```

- **Select the model and the effort** for each dispatch. See the next section.
- **Examine the results from the files and git, not from the reports.**
- **Record each run** in the Runs table of `status.md`.
- **Agents cannot ask the user.** Collect their questions, remove duplicates, and ask the
  user in one group.

## Model and effort

For each dispatch, select the model (the `model` parameter of the Agent call) and the
effort (the `effort` parameter: `low`, `medium`, `high`, `xhigh` or `max`). Select them
from the complexity of the task, not only from the agent. Use the most cheap combination
that can do the task well.

| Complexity | Examples | Model | Effort |
|------------|----------|-------|--------|
| Mechanical | rename, text or translation change in named files, a small doc update | `haiku` | `low` |
| Usual | a brief, a spec, a UX review, a checklist, an implementation task, a bug fix with a clear cause, a fix round, a PR review, docs | `sonnet` | `medium` |
| Complex | a large spec with many rules, a task with many files, a static review of a large diff, a runtime test of many flows, market research with many sources | `sonnet` | `high` |
| Critical | the plan and its review, contracts between platforms, the contract check, security, permissions, payments, money calculations, migrations of production data, a legal review with 🔴 risk, the review of a high-risk PR | `opus` | `high` |
| Very hard | a task that failed two times, a design decision with no clear answer, a defect that nobody can find | `opus` | `xhigh` |

Obey these rules:

- Do not use `haiku` for a review, a plan or business logic.
- Use a stronger model for a review than for the work that it examines. A reviewer on
  the same model as the implementer frequently does not see the same defects.
- If the task matches more than one row, use the higher row.
- If a task fails, first increase the effort. If it fails again, use a stronger model.
  Increase only one step at a time, and only one time for each task.
- Use `max` only when the user asks for it.
- If the user gives a model or an effort for a task, use it.
- Record the model and the effort of each run in the Runs table of `status.md`.

## Hard rules

- Do not edit the artifacts or the code of an agent. Send the problem to its owner.
- Do not merge without the approval of the user for the merge plan. Do not push to the
  main branch, and do not do a force push.
- Do not start a phase before its gate is complete.
- If the user changes a requirement, use the change request procedure. If the user
  changes the direction of the work, stop or complete the current wave. Update
  `status.md`, and select the track and the route again.
