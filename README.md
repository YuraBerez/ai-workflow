# ai-workflow

Personal skills for Claude Code.

[WORKFLOW.md](WORKFLOW.md) tells how the skills, the agents and the hooks work together:
the phases, when each agent runs, and which skills each agent uses.

## Skills

| Skill | What it does |
|-------|--------------|
| [requirement-analyze](skills/requirement-analyze/SKILL.md) | Finds gaps in the business logic of a feature before development starts. Makes a spec for spec-driven development (SDD), with numbered requirements, EARS acceptance criteria, and blocking and important questions. |
| [test-checklist](skills/test-checklist/SKILL.md) | Makes a test checklist from a spec with test design techniques: EP, BVA, decision tables, state transition, pairwise and error guessing. Each check refers to the spec IDs. A coverage matrix shows the coverage of each acceptance criterion. |
| [static-review](skills/static-review/SKILL.md) | Examines a code diff against the checks of the test checklist without a run of the application. Marks each check that the diff implements as `[x]` with a file and line reference, and makes a list of defects and spec gaps. |
| [pr-review](skills/pr-review/SKILL.md) | Does a critical review of a GitHub PR. Examines each finding against the source code, then posts short inline comments with a severity mark and a fix effort mark, after the user approves them. |
| [learn-loop](skills/learn-loop/SKILL.md) | At the end of a task, saves the lessons, corrections and decisions in the correct store: memory, glossary, ADR, runbook or skill. The default action is to discard. |
| [sdd-orchestrator](skills/sdd-orchestrator/SKILL.md) | Runs spec-driven development of a feature with the SDD agents. Selects the agents that the feature needs, runs independent agents in parallel, and stops at gates for the user. |
| [ponytail](skills/ponytail/SKILL.md) | Makes the most simple solution that works: the current code of the project, the standard library and native features before new code or new dependencies. |
| [localization](skills/localization/SKILL.md) | Rules for text in more than one language: keys and placeholders, plurals, locale formats, RTL layout, text expansion and typography. |
| [memory-gc](skills/memory-gc/SKILL.md) | Finds duplicate, old and wrong memories, and proposes a merge, a correction or a delete. Changes files only after approval. |
| [writing-style](skills/writing-style/SKILL.md) | Writes and examines English text in ASD-STE100 Simplified Technical English. All skills and documentation in this repository follow it. |

## Agents

The `sdd-orchestrator` skill dispatches these agents. The shared rules of all agents are in
[contract.md](skills/sdd-orchestrator/contract.md). Each agent file contains only the rules
of its role.

| Agent | Phase | Writes |
|-------|-------|--------|
| [product-manager](agents/product-manager.md) | 1 Brief | `brief.md` |
| [business-analyst](agents/business-analyst.md) | 2–3 Spec | `spec.md` |
| [legal-advisor](agents/legal-advisor.md) | 3 Spec review | `legal.md` |
| [ux-designer](agents/ux-designer.md) | 3 Spec review | `ux.md` |
| [architect](agents/architect.md) | 4 Plan | `plan.md`, `tasks.md`, ADRs |
| [architecture-reviewer](agents/architecture-reviewer.md) | 4 Plan | `plan-review.md` |
| [tester](agents/tester.md) | 4 and 6 | `test-checklist-<pr-key>.md`, `static-review-<pr-key>.md` |
| [backend-implementer](agents/backend-implementer.md) | 5 Build | code, PR |
| [web-implementer](agents/web-implementer.md) | 5 Build | code, PR |
| [mobile-implementer](agents/mobile-implementer.md) | 5 Build | code, PR |
| [security](agents/security.md) | 4 and 6 | `security.md` |
| [devops](agents/devops.md) | 5 Build | infrastructure, CI, PR |
| [code-reviewer](agents/code-reviewer.md) | 6 Verify | PR comments |
| [documenter](agents/documenter.md) | 7 Close | project docs, docs PR |
| [marketing-specialist](agents/marketing-specialist.md) | 3 and 7 | `marketing.md` |
| [researcher](agents/researcher.md) | on request | `research-<topic>.md` |

```text
0 Start     track: bugfix | small | feature | epic
1 Brief     product-manager
2 Spec      business-analyst
3 Review    legal-advisor ║ ux-designer ║ marketing-specialist → user answers the questions
4 Plan      architect → architecture-reviewer ║ security ║ tester (checklist for each PR)
5 Build     backend ║ web ║ mobile ║ devops → tester (contract check)
6 Verify    tester (static review) ║ code-reviewer ║ security (high-risk PRs) → fixes → tester (runtime)
7 Release   documenter ║ marketing-specialist (launch) → merge plan → merge → tester (smoke after deploy)
8 Measure   product-manager, some weeks later → learn-loop
```

The researcher runs in each phase when an agent asks for research. The orchestrator
selects the model and the effort of each agent from the complexity of the task.

`║` shows agents that run in parallel.

## Workflow without agents

1. Use `requirement-analyze` to make the spec. Get answers to the blocking questions.
2. Use `test-checklist` to make the test checklist from the spec.
3. Use `static-review` to examine each diff against the checklist and mark the checks that are done.
4. Send the spec gaps from the checklist and the review back to the spec as new questions.
5. Use `pr-review` to review the PR.
6. Use `learn-loop` at the end of the task to save the lessons.

## Install

Make a link from one skill to the personal skills folder of Claude Code:

```sh
ln -s "$(pwd)/skills/requirement-analyze" ~/.claude/skills/requirement-analyze
```

To make links for all skills in the repository, use this command:

```sh
for s in skills/*/; do ln -sfn "$(pwd)/$s" ~/.claude/skills/"$(basename "$s")"; done
```

Make links for all agents in the repository:

```sh
mkdir -p ~/.claude/agents
for a in agents/*.md; do ln -sfn "$(pwd)/$a" ~/.claude/agents/"$(basename "$a")"; done
```

Because the skills are links, changes in this repository apply immediately. You do not
have to install the skills and agents again.

## Templates

The `templates/` folder contains the start structure of the docs for a project:

```text
PRODUCT.md           short description of the product: goal, users, scope, roadmap
docs/tech/           architecture and technical questions: architecture, API, configuration, ADRs, runbooks
docs/features/       product descriptions and specs of features, one folder for each feature
```

Copy the templates into a project:

```sh
cp -R templates/PRODUCT.md templates/docs <project>/
```

## Hooks

The `hooks/` folder contains optional hooks for `~/.claude/settings.json`:

| Hook | Event | What it does |
|------|-------|--------------|
| [learn-reminder.sh](hooks/learn-reminder.sh) | `SessionStart`, `Stop` | Reminds you about the `learn-loop` skill, only when the session changed a git ref. |
| [guard-large-image.sh](hooks/guard-large-image.sh) | `PreToolUse` (`Read`) | Blocks a Read of an image that is larger than 300 KB, to save tokens. |

To install them, add this to the `hooks` section of `~/.claude/settings.json`. Replace
`<repo>` with the path of this repository:

```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "<repo>/hooks/learn-reminder.sh start", "timeout": 20 }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "<repo>/hooks/learn-reminder.sh stop", "timeout": 20 }] }],
    "PreToolUse": [{ "matcher": "Read", "hooks": [{ "type": "command", "command": "<repo>/hooks/guard-large-image.sh" }] }]
  }
}
```

The hooks need `jq`.

## Repository layout

```
skills/<skill-name>/SKILL.md   # one folder for each skill, frontmatter with `name` and `description`
agents/<agent-name>.md         # one file for each SDD agent
hooks/<name>.sh                # optional hooks for ~/.claude/settings.json
AGENTS.md                      # instructions for AI agents in this repository
CLAUDE.md                      # imports AGENTS.md for Claude Code
WORKFLOW.md                    # how the skills, agents and hooks work together
templates/                     # PRODUCT.md and docs/ structure for a project
scripts/lint.sh                # consistency check of this repository; run it before you commit
```

## Add a skill

1. Make the file `skills/<skill-name>/SKILL.md`. In the frontmatter, `name` must be the
   same as the folder name.
2. In `description`, tell what the skill does and when Claude Code must use it.
3. Write all text in ASD-STE100. Use the `writing-style` skill.
4. Add a row to the **Skills** table above.
5. Make a link to the skill in `~/.claude/skills/`.
