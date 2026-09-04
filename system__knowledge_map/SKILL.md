---
name: system__knowledge_map
description: Generate or update the knowledge_map.md index for an agent
user-invocable: false
allowed-tools: Bash Read Write
---

Derive agent root from CLAUDE.md path: CLAUDE.md loaded from <agent>/CLAUDE.md.
Check <agent_root>/_meta/knowledge_map.md:
- Missing → bootstrap: run heading scan (see assets/knowledge_map__template.md), create knowledge_map.md
- Exists → update: read source_commit, run git diff incremental, apply heading changes only

Constraints:
- Never commit, push, or git add
- Never modify source notes
- Only read .md files; only extract headings (#, ##, ###); never read body content

Scope: agent folder. Read scope/exclude from agent's CLAUDE.md if defined.
Default excludes: __bk, bk, bk__*, deprecated, archive, _archived*, _temp*

Format (token efficiency priority — terse, no filler):
  Paths relative from agent root. One line per link. No redundant grouping labels.

  source_commit: <hash>
  generated_at: <date>
  scope: [<agent>]
  exclude: [...]

  ## Confidence Scoring
  ### High / Medium / Low — one-line reason per folder/file
  Positive signals: stable paths, clear names, reused across topics, structured headings
  Negative signals: obsolete markers, scratch areas, draft-only
  Trigger: update when user says "update scoring based on what we learnt this time"
  Refine using only session context — never read additional files; only file read during update is knowledge_map.md itself

  ## Topic Mapping
  ## <Topic>
  - <relative_path>#<Heading>
  Tie-break: prefer existing topic; only create new when nothing fits — reduces drift
  Cleanup: remove topic if it has 0 links after diff processing

  ## Key Questions
  ### <Question>
  - <relative_path>#<Heading>
  2-5 links max; derived from conversation context only, not pre-designed

Retrieval (when answering questions):
1. Open knowledge_map.md
2. Locate relevant topic or question
3. Follow 2-5 linked sections
4. Avoid deep recursion
5. Prefer summaries if available

Update process:
1. Read source_commit from knowledge_map.md
2. Run: git diff <source_commit> HEAD -- '*.md' :(exclude)<excluded_paths> scoped to agent folder
3. Extract heading changes only from diff output: + added, - removed, rename = same file + similar level + similar text
4. Map changed headings directly to topics — do not open individual files to read or scan headings
5. Add new entries, remove deleted references, update renames
6. Update source_commit to current HEAD

Bootstrap only: after creating knowledge_map.md, update agent's CLAUDE.md to reference it with scope/exclude/location.
Update only: read knowledge_map.md directly — no template needed.
