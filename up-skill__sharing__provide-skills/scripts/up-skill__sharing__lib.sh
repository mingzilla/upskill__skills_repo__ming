#!/usr/bin/env bash
# up-skill__sharing__lib.sh - shared helpers for the up-skill client scripts.
# Sourced (never executed): `source .../up-skill__sharing__lib.sh`, then call `us_init`.
#
# Resolves the .up-skill__workspace (nearest ancestor holding up-skill__user-config.json,
# or $UP_SKILL_WORKSPACE) and loads the user config + team address book into US_* globals.

set -euo pipefail

US_WORKSPACE=""       # root of this machine's up-skill__workspace
US_USER=""            # this member's name (matches the address book)
US_TEAM=""            # e.g. team__sandbox
US_ADDRESS_BOOK=""    # dir of the cloned address-book repo
US_AB_JSON=""         # path to address_book.json
US_TEAM_DIR=""        # dir holding the address book + every member's sharing clone
US_ME_FOLDER=""       # my skills-repo clone folder name, e.g. up-skill__skills_repo__leah
US_ME_DIR=""          # absolute path of my sharing clone

us_require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: required tool not found: $1" >&2; exit 1; }
}

# us_jget <json-file> <python-expr-on-d> - print one value read from a JSON file
us_jget() {
  python3 -c 'import json,sys
d = json.load(open(sys.argv[1]))
r = eval(sys.argv[2])
print(r if isinstance(r, str) else json.dumps(r))' "$1" "$2"
}

# us_locate_workspace <start-dir> - set US_WORKSPACE to nearest ancestor holding the config
us_locate_workspace() {
  local dir="${1:-$PWD}"
  [[ -d "$dir" ]] || dir="$(dirname "$dir")"
  while :; do
    if [[ -f "$dir/up-skill__user-config.json" ]]; then
      US_WORKSPACE="$dir"
      return 0
    fi
    [[ "$dir" == "/" ]] && break
    dir="$(dirname "$dir")"
  done
  return 1
}

# us_load_config - fill US_* from up-skill__user-config.json
us_load_config() {
  local cfg="$US_WORKSPACE/up-skill__user-config.json"
  US_USER=$(us_jget "$cfg" 'd["user"]')
  US_TEAM=$(us_jget "$cfg" 'd.get("team", "")')
  local ab_rel
  ab_rel=$(us_jget "$cfg" 'd["address_book"]')
  US_ADDRESS_BOOK="$US_WORKSPACE/$ab_rel"
  US_AB_JSON="$US_ADDRESS_BOOK/address_book.json"
  US_TEAM_DIR="$(dirname "$US_ADDRESS_BOOK")"
}

# us_members - print address-book rows as: name<TAB>folder<TAB>repo
us_members() {
  python3 -c 'import json,sys
ab = json.load(open(sys.argv[1]))
for n, m in ab.get("users", {}).items():
    print(n + "\t" + m.get("folder", "") + "\t" + m.get("repo", ""))' "$US_AB_JSON"
}

# us_folder_of <member-name> - print that member's sharing-clone folder name
us_folder_of() {
  python3 -c 'import json,sys
ab = json.load(open(sys.argv[1]))
print(ab["users"].get(sys.argv[2], {}).get("folder", ""))' "$US_AB_JSON" "$1"
}

# us_skill_names <sharing-clone-dir> - print immediate child names that contain SKILL.md
us_skill_names() {
  local root="$1" d
  [[ -d "$root" ]] || return 0
  for d in "$root"/*/; do
    [[ -e "$d" ]] || continue
    [[ -f "$d/SKILL.md" ]] && printf '%s\n' "$(basename "$d")"
  done
}

# us_safe_name <name> - reject empty / pathy / dot-dot names before they reach a filesystem path
us_safe_name() {
  local n="$1"
  if [[ -z "$n" || "$n" == */* || "$n" == *".."* ]]; then
    echo "error: not a valid name: '$n'" >&2
    return 1
  fi
}

# us_init [start-dir] - resolve workspace, load config, validate address book + my membership
us_init() {
  local start="${1:-$PWD}"
  us_require python3
  us_require git
  if [[ -n "${UP_SKILL_WORKSPACE:-}" && -d "$UP_SKILL_WORKSPACE" ]]; then
    US_WORKSPACE="$UP_SKILL_WORKSPACE"
  elif ! us_locate_workspace "$start" && [[ -d "$HOME/.up-skill__workspace" ]]; then
    US_WORKSPACE="$HOME/.up-skill__workspace"   # global default: workspace lives under the user profile
  elif [[ -z "${US_WORKSPACE:-}" ]]; then
    echo "error: no .up-skill__workspace found from '$start' (looked upward for up-skill__user-config.json)" >&2
    echo "  run inside your .up-skill__workspace, or set UP_SKILL_WORKSPACE=<path>" >&2
    exit 1
  fi
  us_load_config || { echo "error: cannot read config in $US_WORKSPACE" >&2; exit 1; }
  if [[ ! -f "$US_AB_JSON" ]]; then
    echo "error: address book not found at $US_AB_JSON (run install.sh first)" >&2
    exit 1
  fi
  US_ME_FOLDER="$(us_folder_of "$US_USER")"
  if [[ -z "$US_ME_FOLDER" ]]; then
    echo "error: '$US_USER' is not in the address book ($US_AB_JSON)" >&2
    exit 1
  fi
  US_ME_DIR="$US_TEAM_DIR/$US_ME_FOLDER"

  # self-update: pull the workspace solution (prod) and refresh the global skills - quiet, best-effort
  us_self_update
}

# us_self_update - the user never reruns the installer; on use, pull prod + refresh ~/.claude/skills.
us_self_update() {
  local sol="$US_WORKSPACE/up-skill" src gh s
  [[ -d "$sol/.git" ]] || return 0
  git -C "$sol" pull --ff-only --quiet 2>/dev/null || true
  src="$sol/_system/l2_share_skills/.claude/skills"
  gh="$HOME/.claude/skills"
  [[ -d "$src/up-skill__sharing__receive-skills" ]] || return 0
  mkdir -p "$gh"
  for s in upskill up-skill__sharing__provide-skills up-skill__sharing__receive-skills; do
    [[ -d "$src/$s" ]] || continue
    rm -rf "$gh/$s"
    cp -R "$src/$s" "$gh/$s"
  done
}
