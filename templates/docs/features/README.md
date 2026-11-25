# Features

This folder contains the product descriptions and the specs of the features. Each
feature has its own folder: `<feature-slug>/`.

| Feature | Status | Folder |
|---------|--------|--------|
| ... | Draft | [<feature-slug>/](<feature-slug>/) |

Status: `Draft` → `Ready` → `In development` → `Shipped`.

## Feature folder

| File | Content | Owner |
|------|---------|-------|
| `README.md` | the product description of the feature as it works now | documenter |
| `brief.md` | the problem, the users, the goal and the scope | product-manager |
| `spec.md` | requirements, acceptance criteria and open questions | business-analyst |
| `ux.md` | flows, screens, states and texts | ux-designer |
| `legal.md` | legal risks | legal-advisor |
| `marketing.md` | positioning, analytics and the launch plan | marketing-specialist |
| `research-<topic>.md` | research reports | researcher |
| `plan.md`, `tasks.md` | the technical plan and the tasks | architect |
| `plan-review.md` | the review of the plan | architecture-reviewer |
| `security.md` | security findings for the plan | security |
| `security-<pr-key>.md` | security findings for one high-risk PR | security |
| `test-checklist-<pr-key>.md` | the test checklist of one PR | tester |
| `static-review-<pr-key>.md` | the defects of the static review of one PR | tester |
| `contract-check.md` | the comparison of the contracts between platforms | tester |
| `release-check.md` | the smoke checks after each deploy | tester |
| `screenshots/<pr-key>/` | the UI screenshots of one PR | tester |
| `measure.md` | the metric after the release | product-manager |
| `status.md` | the status of the pipeline | orchestrator |

A feature folder contains only the files that the feature needs. Decisions for the full
product go to [docs/tech/adr/](../tech/adr/README.md).
