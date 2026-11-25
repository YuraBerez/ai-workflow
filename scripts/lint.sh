#!/usr/bin/env bash
# Examines the consistency of this repository. Run it before you commit.
#
#   scripts/lint.sh
#
# Checks:
#   1. Each skills/<name>/SKILL.md and agents/<name>.md has frontmatter with a `name` that
#      is the same as the folder or file name, and a `description`.
#   2. Each relative Markdown link points to a file that exists.
#   3. Each `~/.claude/skills/<name>/` reference points to a skill of this repository.
#   4. Each agent is in the Team table of the orchestrator, in contract.md, in WORKFLOW.md
#      and in the Agents table of README.md, and these tables name no other agents.
#   5. Each skill is in the Skills table of README.md.
#   6. Each hook is in the Hooks table of README.md.
# Exit code 1 if a check fails.
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 - <<'PY'
import pathlib, re, sys

root = pathlib.Path('.')
errors = []

def err(msg):
    errors.append(msg)

def frontmatter(path):
    text = path.read_text()
    m = re.match(r'^---\n(.*?)\n---\n', text, re.S)
    if not m:
        return None
    fields = {}
    for line in m.group(1).splitlines():
        k, _, v = line.partition(':')
        if v and not line.startswith(' '):
            fields[k.strip()] = v.strip()
    return fields

skills = sorted(p.parent.name for p in root.glob('skills/*/SKILL.md'))
agents = sorted(p.stem for p in root.glob('agents/*.md'))
hooks = sorted(p.name for p in root.glob('hooks/*.sh'))

# 1. frontmatter
for name in skills:
    p = root / 'skills' / name / 'SKILL.md'
    fm = frontmatter(p)
    if fm is None:
        err(f'{p}: no frontmatter')
        continue
    if fm.get('name') != name:
        err(f'{p}: name "{fm.get("name")}" is not the folder name "{name}"')
    if not fm.get('description'):
        err(f'{p}: no description')
for name in agents:
    p = root / 'agents' / f'{name}.md'
    fm = frontmatter(p)
    if fm is None:
        err(f'{p}: no frontmatter')
        continue
    if fm.get('name') != name:
        err(f'{p}: name "{fm.get("name")}" is not the file name "{name}"')
    if not fm.get('description'):
        err(f'{p}: no description')

# 2. relative links, outside code blocks and inline code
md_files = [p for p in root.rglob('*.md') if '.git' not in p.parts]
for p in md_files:
    text = re.sub(r'```.*?```', '', p.read_text(), flags=re.S)
    text = re.sub(r'`[^`\n]*`', '', text)
    for target in re.findall(r'\]\(([^)\s]+)\)', text):
        if re.match(r'^[a-z]+:', target) or target.startswith('#') or '<' in target:
            continue
        path = target.split('#', 1)[0]
        if not path:
            continue
        if not (p.parent / path).exists():
            err(f'{p}: broken link "{target}"')

# 3. ~/.claude/skills references
for p in md_files:
    for name in re.findall(r'~/\.claude/skills/([a-z0-9-]+)/', p.read_text()):
        if name not in skills and name != '<name>':
            err(f'{p}: refers to the skill "{name}", which is not in skills/')

# 4. agent tables
def names_in(path, section=None):
    text = (root / path).read_text()
    if section:
        m = re.search(rf'^##+ {re.escape(section)}\n(.*?)(?=^## )', text, re.S | re.M)
        text = m.group(1) if m else ''
    found = set()
    for name in agents:
        if re.search(rf'(?<![\w-]){re.escape(name)}(?![\w-])', text):
            found.add(name)
    return found

checks = [
    ('skills/sdd-orchestrator/SKILL.md', 'Team'),
    ('skills/sdd-orchestrator/contract.md', 'Feature folder'),
    ('WORKFLOW.md', 'When the orchestrator calls each agent'),
    ('README.md', 'Agents'),
]
for path, section in checks:
    missing = set(agents) - names_in(path, section)
    for name in sorted(missing):
        err(f'{path} (section "{section}"): agent "{name}" is not there')

# agents named in the orchestrator Team table that have no file
team = (root / 'skills/sdd-orchestrator/SKILL.md').read_text()
m = re.search(r'^## Team\n(.*?)(?=^## )', team, re.S | re.M)
for row in (m.group(1) if m else '').splitlines():
    if row.startswith('| ') and not row.startswith('| Agent') and not row.startswith('|--'):
        for name in re.split(r',\s*', row.split('|')[1].strip()):
            if name and name not in agents:
                err(f'skills/sdd-orchestrator/SKILL.md (Team): "{name}" has no file in agents/')

# 5. skills table, 6. hooks table
readme = (root / 'README.md').read_text()
for name in skills:
    if f'[{name}](skills/{name}/SKILL.md)' not in readme:
        err(f'README.md: skill "{name}" is not in the Skills table')
for name in hooks:
    if f'(hooks/{name})' not in readme:
        err(f'README.md: hook "{name}" is not in the Hooks table')

if errors:
    print('\n'.join(errors))
    print(f'\n{len(errors)} problem(s) found.')
    sys.exit(1)
print(f'OK: {len(skills)} skills, {len(agents)} agents, {len(hooks)} hooks, {len(md_files)} Markdown files.')
PY
