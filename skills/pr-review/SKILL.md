---
name: pr-review
description: Do a critical review of a GitHub pull request. Examine each possible finding against the source code before you write it. Then post short inline comments with a severity mark and a fix effort mark. The review looks for correctness, side effects, efficiency, layer violations of the project, and acceptance criteria that the PR does not meet. Style and small details are out of scope. Use this skill when the user asks you to review a PR, gives a PR number or URL, or gives a branch from the PR of a colleague. Also use it for a second review of a PR after the author changed it.
---

# PR review

Do one review of a GitHub PR. Post the findings as inline comments.

Each comment must be correct. A wrong 🔴 comment costs the author more time than the
bug. Thus, examine each finding against the source code before you write it.

## Find the repository first

Before you use `gh`, find the repository of the PR. A PR number without a repository has
no meaning when the user works with more than one repository.

Run each `gh` command with `--repo <owner>/<repo>`. If the user gives a PR URL, get the
owner and the repository from the URL.

## Read the rules of the project

Before you review, read the project rules that apply to the diff:

- `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` and the docs that they refer to
- the architecture rules: layers, modules, dependency direction
- the ADRs, for example in `docs/tech/adr/`

A violation of a written rule of the project is a finding. A violation of your personal
preference is not a finding.

## Procedure

Diffs can be large. Keep the diff in a file in the scratchpad. Do not put a full diff
into the context.

1. **Get the PR data, and use the diff of the PR.** Do not use a diff of the local
   `HEAD`.
   - Run `gh pr view <n> --repo <owner>/<repo> --json baseRefName,headRefOid,changedFiles,additions,deletions,body`.
   - Run `gh pr diff <n> --repo <owner>/<repo>` and save the output to a file.
   - GitHub calculates this diff against the base of the PR. If you use a wrong base,
     the diff contains other changes, and the review can show no defects in error.
2. **Get the code of the PR head before you read local files.**
   - If the local clone is not used by other work, run
     `gh pr checkout <n> --repo <owner>/<repo>`.
   - If the clone is used by other work, use a worktree:
     `git worktree add <path> <headRefOid>`. Remove the worktree at the end.
   - Make sure that `git rev-parse HEAD` is the same as `headRefOid`. If it is
     different, stop. Do not review a different revision.
3. **Examine the CI status.** Run `gh pr checks <n> --repo <owner>/<repo>`.
   - If CI is green, do not run the full build or the tests again.
   - If CI failed, read the log: `gh run view <id> --log-failed --repo <owner>/<repo>`.
     Each failure that the PR causes is a finding.
4. **Read the production diff before the test diff.** Side effects come from the
   production code. A test file can only be wrong about itself.
5. **Examine the requirements.** Find the requirements of the PR:
   - the linked issue: `gh issue view <n> --repo <owner>/<repo>`
   - the spec and the test checklist, if the PR changes or refers to
     `docs/features/<feature-slug>/spec.md` or a test checklist
   - the PR body

   Examine each acceptance criterion against the diff. An acceptance criterion that the
   PR does not meet is 🔴. If a static review file (`static-review.md` or `static-review-<pr-key>.md`) exists for
   the same commit, use its
   defects. Do not do the same work again.
6. **Examine each possible finding against the source.** A finding is almost always
   about code that the diff does not show. For example:
   - the other callers of a changed or moved function
   - an import that breaks a layer rule of the project
   - a DTO or API change that breaks a consumer on the other side of the contract
   - a database migration that adds a non-null column without a default, or deletes data

   Open these files. Most possible findings stop here. Each finding that stays has a
   `file:line` reference.
7. **Remove the small details.** Names, comment text, formats and "this can be a
   constant" are out of scope, if they do not cause a bug. If you cannot write a finding
   as "this breaks, costs or leaks X", it is not a finding.
8. **Write the comments** in a file in the scratchpad. Obey the comment rules below.
   Show the comments to the user, and wait for approval. A post to GitHub is outward
   facing.
9. **Examine each anchor before you post.** Run `sed -n '<line>p' <path>`. It must show
   the code of the comment. The line must be an added line or a context line of the PR
   diff. GitHub rejects an anchor outside the diff.
10. **Post one comment for each finding.** Use
    `POST /repos/<owner>/<repo>/pulls/<n>/comments` with `commit_id` (the `headRefOid`),
    `path`, `line`, `side: RIGHT` and `body`.
    - Post each comment alone, not as a group review. A group review needs a summary
      body, and this review has no summary.
    - Comment bodies contain backticks and code blocks. Make the JSON from a file with
      `python3`. Do not write the JSON in the shell command.
11. **Make sure that the comments are on the PR.** Run
    `gh api repos/<owner>/<repo>/pulls/<n>/comments -q '.[] | "\(.path):\(.line)  \(.user.login)"'`.

## Second review

If the PR got a review before, and the author changed it, do a second review:

1. Find the commit of the first review.
2. Examine only `git diff <reviewed-sha>..<headRefOid>` and the open comment threads.
3. For each thread, examine if the author corrected the defect or answered it.
4. Examine if the correction adds a new defect.

Do not review the rest of the PR again.

## Comment rules

- **Do not post a summary comment.** The inline comments are the full review.
- **Start each comment with two marks on the first line**: the severity, then the fix
  effort.
  - Severity: `🔴 Major`, `🟠 Medium` or `🟡 Optional`.
  - Fix effort: `🏗️ heavy`, `👷 medium` or `⚡ easy`.
  - Example: `🔴 Major · ⚡ easy`.
- **Severity:**
  - 🔴 — a bug, a side effect that nobody sees, a layer violation, an acceptance
    criterion that the PR does not meet, or a test that is green in error.
  - 🟠 — a real cost, or a trap that will cause a bug with the next change.
  - 🟡 — quality. The author can ignore it safely.
- **Limit the 🟡 comments.** If the review has a 🔴 or a 🟠 comment, post a maximum of
  one 🟡 comment. If the review has no 🔴 or 🟠 comments, you can post three or four 🟡
  comments.
- **Do not limit the 🔴 and 🟠 comments.** Post each one that you examined against the
  source. A limit that hides a real defect is worse than a long review.
- **Write short comments.** A comment has a maximum of about 120 words. Use this
  sequence: the claim, the evidence (`file:line`), the result, the fix. Use a code block
  only when the fix is shorter as code than as text.
- **Write one comment for each defect, not for each location.** If the same mistake is
  in five locations, write one comment. Put it at the most clear location, and give the
  other four locations.
- **If there are more than about eight 🔴 and 🟠 comments, tell the user before you
  post.** So many defects usually show that the PR is too large for one review. The user
  decides if you post them.
- **Write the comments in English**, in ASD-STE100. Use the writing-style skill.
- **Tell the user what you examined and found correct.** Do not post this on the PR.

## Guardrails

- **Do not post without approval.** Write the comments, show them, and wait. Approval for
  one PR is not approval for the next PR.
- **Do not post a claim that you did not examine in the source file.**
- **Do not commit or push.** Do not push a fix to the branch of a colleague. The review
  gives a proposal. The author decides.
- **Do not run the full build or test suite.** CI ran it on the same commit. You can run
  one narrow command to examine one specific claim.
- **A review without 🔴 or 🟠 comments is a valid result.** Tell the user this clearly.
- **If the PR is yours** and you answer review comments, do not use this skill. Push the
  fix and answer each thread.

## Report to the user

After you post, tell the user these items in 2–5 lines:

- the PR and the repository
- the number of comments for each severity
- one line for each 🔴 and 🟠 comment
- the items that you examined and did not post
