# AGENTS.md

Instructions for AI coding agents that work in this repository. `CLAUDE.md` imports
this file. Put all rules here, not in `CLAUDE.md`.

## What this repository is

This repository contains personal skills, SDD agents and hooks for Claude Code. It has no
application code, and no build, lint or test step. The content is Markdown files and
shell scripts. `WORKFLOW.md` tells how the parts work together.

## Check

Run `scripts/lint.sh` before you commit. It examines the frontmatter, the links, the
references to skills, and the agent, skill and hook tables. Correct each problem that it
shows.

## Writing style

Write all skills and documentation in this repository in ASD-STE100 Simplified
Technical English. Use the `writing-style` skill when you write or change text.

These items are exceptions: code, commands, file paths, IDs, EARS keywords and quoted
text that a user types.

## Layout and conventions

- Each skill is in `skills/<skill-name>/SKILL.md`. Put the support files of a skill
  (templates, references, scripts) in the same folder.
- `SKILL.md` starts with YAML frontmatter: `name` and `description`. The `name` must be
  the same as the folder name.
- Claude Code reads only the `description` to decide when to use a skill. Thus, the
  `description` must tell what the skill does and when to use it.
- Write skill files only in English. Do not put trigger phrases in other languages in a
  skill file. Do not write in the `description` that the skill applies to requests in
  other languages. Claude Code already matches requests in all languages.
- Skills tell Claude to write the output in the language of the user. If the output is
  in English, it must follow ASD-STE100.
- The skills are installed as links in `~/.claude/skills/` (see README). Changes in this
  repository apply immediately to all Claude Code sessions.

## Agents

- Each SDD agent is in `agents/<agent-name>.md`. The `sdd-orchestrator` skill dispatches
  them from the main session.
- Do not duplicate rules. Put a rule in only one location:
  - rules for all agents: `skills/sdd-orchestrator/contract.md`
  - a procedure that a skill already has: the skill. The agent file tells the agent to
    read the skill.
  - rules of one role: the agent file
- Each artifact of the feature folder has one owner agent. The owner table is in
  `contract.md`. If you add an agent or an artifact, update the owner table and the Team
  table in `skills/sdd-orchestrator/SKILL.md`. `scripts/lint.sh` examines that each agent
  is in these tables.
- Agents read skill files at `~/.claude/skills/<name>/SKILL.md`. Thus, the skills must
  have links in `~/.claude/skills/`.

## Skills that work together

- `requirement-analyze` makes `docs/features/<feature-slug>/spec.md`. The spec has stable IDs:
  `FR`, `AC`, `BR`, `NFR`, `CP` for critical points, `B` and `I` for questions, and `D`
  for decisions.
- `test-checklist` reads the spec and makes `test-checklist.md` in the same folder. If
  `tasks.md` has PR keys, it makes one `test-checklist-<pr-key>.md` for each PR. Each
  check refers to the spec IDs. The spec gaps that the checklist finds go back to the
  spec as questions.
- `static-review` examines a code diff against the checklist. It marks the checks that
  the diff implements as `[x]` in the checklist of the PR, with a review note after
  ` — `. It writes the defects (`DEF` IDs) and the spec gaps in `static-review.md`, or in
  `static-review-<pr-key>.md` for a checklist of a PR.
- If you change the ID format or the file location in one skill, change the other skills
  too.

## Templates

- `templates/` contains the start structure for a project: `PRODUCT.md`, `docs/tech/`
  and `docs/features/`. The skills and agents use these paths by default.
- If you change a path in a template, change the same path in the skills, the agents,
  `contract.md` and `WORKFLOW.md`.

## Hooks

- Optional hooks are in `hooks/`. The README tells how to add them to
  `~/.claude/settings.json`. Do not change the settings of the user without approval.

## When you add or rename a skill, agent or hook

- Update `WORKFLOW.md`: the phases, the agent triggers and the skills of each agent.
- Add or update its row in the **Skills** table in `README.md`.
- For an agent, add its row to the **Agents** table in `README.md`.
- For a hook, add its row to the **Hooks** table in `README.md`.
