---
name: memory-gc
description: Make the memory stores small and correct. Find duplicate memories, old or wrong memories, broken index lines and memories in the wrong store, and propose a merge, a correction, a move or a delete for each. Shows the list first and changes files only after the user approves. Use it about one time each month, after a week with three or more new memories, or when the user tells you that the memory has too much content, is old or contradicts itself.
---

# Memory GC

Keep the memory stores small, correct and without duplicates. Each always-loaded index
line costs context in each session.

This skill works together with the learn-loop skill. The learn-loop adds memories. This
skill removes and merges them.

## Scope

- personal memory: `~/.claude/projects/<project>/memory/` and its `MEMORY.md` index
- project memory: `.claude/memory/` and its `MEMORY.md` index, if the project has it
- the glossary of the project, for example `CONTEXT.md` — report only
- the ADR index — rows for ADR files that do not exist — report only

## Procedure

The first run is a dry run. Do not change files before the user approves.

1. **Collect** each memory file, each index line and each ADR index row.
2. **Find these problems:**
   - **Duplicates** — two memories with the same fact. Propose a merge: keep the more
     complete memory, add the other data to it, and keep the `[[links]]`.
   - **Old or wrong memories** — a memory that does not agree with the current code, a
     newer memory or an accepted ADR. Examine the claim against the repository first. A
     memory tells what was true when somebody wrote it.
   - **Broken index lines** — a line that points to a file that does not exist, or a
     file without a line.
   - **Wrong store** — a decision in a memory that belongs in an ADR or the glossary, or
     the opposite.
   - **Duplicate rules** — a memory that repeats a rule of `CLAUDE.md`, `AGENTS.md`, a
     skill, an agent file or a hook. Keep only the part that they do not tell, usually
     the reason. If there is no such part, delete the memory.
   - **Not examined** — `metadata.verified` is not there, or is older than 30 days.
     Examine the claim. If it is true, set `verified` to today. If not, correct or delete
     the memory.
   - **Enforced rules** — a hook, a lint or a script now enforces the rule of the memory.
     Make the memory short: the reason and a pointer to the file that enforces it.
   - **Failures that occur again** — the same failure class in two or more memories.
     Propose a runbook in `docs/tech/runbooks/`.
3. **Show the list** to the user: each problem, the proposed action (merge, delete,
   correct, move) and a one-line reason. Do not change files yet.
4. **After the user approves**, do only the approved actions. Update each `MEMORY.md`
   index that changed. Show the paths and the actions.

## Rules

- Do not delete a `user` or `feedback` memory without approval for that memory.
- Do not change the glossary or an ADR. Only report the problems. These stores need a
  separate approval.
- Give evidence for each "old or wrong" mark: the code, the ADR or the memory that
  contradicts it.
- Keep fewer and more correct files, not many files that repeat each other.
