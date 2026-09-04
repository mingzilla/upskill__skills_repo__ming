# knowledge_map.md — Template

> Read on first creation only. On subsequent updates, read the live knowledge_map.md instead.
> Token efficiency is a priority. Every line should carry signal. Remove any line that can be removed without losing meaning.

## Bootstrap (first creation)

No source_commit exists. Run heading scan to get full structure:
```bash
cd <agent_root> && find . -name '*.md' \
  -not -path './**/__bk/**' -not -path './**/bk/**' \
  -not -path './**/*deprecated*/**' -not -path './**/*archive*/**' \
  -not -path './**/_archived*/**' -not -path './**/_temp*/**' \
  | sort | while read f; do \
    headings=$(grep -E '^#{1,3} ' "$f" 2>/dev/null); \
    if [ -n "$headings" ]; then echo "=== $f ==="; echo "$headings"; echo; fi; \
  done
```
Only read the output of this command. Never open individual files to read body content.

---

source_commit: <hash>
generated_at: <timestamp>
scope: [<agent_folder>]
exclude: ["__bk", "bk", "bk__*", "deprecated", "archive", "_archived*", "_temp*"]

## Confidence Scoring

### High
- `knowledge_base/` — stable, reused across topics, structured headings

### Medium
- `wip/` — useful but still changing

### Low
- `_temp/` — scratch area

## Topic Mapping

## Example Topic
- relative/path/file.md#Heading
- relative/path/file.md#Another Heading

> A heading can appear under multiple topics. Topics group by meaning, not by file.

## Key Questions

### Example question?
- relative/path/file.md#Relevant Heading

> Questions link to 2-5 sections max. Derived from real conversation topics, not pre-designed.
