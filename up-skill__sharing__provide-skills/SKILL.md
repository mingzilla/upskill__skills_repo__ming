---
name: up-skill__sharing__provide-skills
description: Share one of your skills with the team - outbound. Triggered by "share this skill", "share my <skill>", "publish my <skill>". Run when the user wants to GIVE a skill, not receive one.
---

# up-skill__sharing__provide-skills

Publish one skill (your choice) to your own skills repo so teammates can receive it.

Resolve the `<skill>`:
- a folder path that contains `SKILL.md`, or
- a skill name under the current project's `.claude/skills`.

Ask the user which skill if it is unclear, and for an optional short message. Then run the script -
**do not improvise git**:

```bash
bash .claude/skills/up-skill__sharing__provide-skills/scripts/up-skill__sharing__share.sh "<skill>" "<message>"
```

Run from the up-skill workspace. If the script reports a missing skills repo, tell the user to run
the installer first. Report the result in one line.
