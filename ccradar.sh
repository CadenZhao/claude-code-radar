#!/usr/bin/env bash
# ccradar — read-only radar for your Claude Code projects on a server.
# Prints a self-contained "Mission Control" dashboard directly. No AI needed.
# A dir counts as a project only if it has a CLAUDE.md (third-party software and
# data folders are skipped). SAFETY: read-only commands ONLY.
#   ./ccradar.sh                    # scan $HOME + Claude Code history
#   ./ccradar.sh /path/to/projects  # scan given root(s)
STALE_DAYS=14
set -uo pipefail
ROOTS=("$@")
[ ${#ROOTS[@]} -eq 0 ] && ROOTS=("$HOME")
CC_DIR="$HOME/.claude/projects"
if [ -t 1 ]; then
  BOLD=$(tput bold 2>/dev/null||true); DIM=$(tput dim 2>/dev/null||true)
  RED=$(tput setaf 1 2>/dev/null||true); YEL=$(tput setaf 3 2>/dev/null||true)
  GRN=$(tput setaf 2 2>/dev/null||true); RST=$(tput sgr0 2>/dev/null||true)
else BOLD=""; DIM=""; RED=""; YEL=""; GRN=""; RST=""; fi
declare -A SEEN
NAMES=(); LASTS=(); GITS=(); DESCS=(); DIRTIES=(); EPOCHS=()
now_epoch=$(date +%s)
collect() {
  local path="$1"
  [ -z "$path" ] && return
  [ ! -d "$path" ] && return
  [ -n "${SEEN[$path]:-}" ] && return
  [ ! -f "$path/CLAUDE.md" ] && return
  SEEN[$path]=1
  local name last gitinfo desc dirty epoch lastepoch branch
  name=$(basename "$path"); dirty=0
  if [ -d "$path/.git" ]; then
    last=$(git -C "$path" log -1 --format=%cd --date=short 2>/dev/null||echo "")
    lastepoch=$(git -C "$path" log -1 --format=%ct 2>/dev/null||echo "")
    branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null||echo "?")
    dirty=$(git -C "$path" status --porcelain 2>/dev/null|wc -l|tr -d ' ')
    if [ "$dirty" -gt 0 ]; then gitinfo="${branch} (${dirty} uncommitted)"; else gitinfo="${branch} clean"; fi
    if [ -z "$last" ]; then
      last=$(date -r "$path/CLAUDE.md" '+%Y-%m-%d' 2>/dev/null||echo "?")
      epoch=$(date -r "$path/CLAUDE.md" '+%s' 2>/dev/null||echo "0")
    else epoch="${lastepoch:-0}"; fi
  else
    last=$(date -r "$path/CLAUDE.md" '+%Y-%m-%d' 2>/dev/null||echo "?")
    epoch=$(date -r "$path/CLAUDE.md" '+%s' 2>/dev/null||echo "0")
    gitinfo="no-git"
  fi
  desc=$(grep -m1 -v '^[[:space:]]*$' "$path/CLAUDE.md" 2>/dev/null|sed 's/^#* *//'|cut -c1-70)
  [ -z "$desc" ] && desc="(no description)"
  NAMES+=("$name"); LASTS+=("$last"); GITS+=("$gitinfo")
  DESCS+=("$desc"); DIRTIES+=("$dirty"); EPOCHS+=("${epoch:-0}")
}
if [ -d "$CC_DIR" ]; then
  for d in "$CC_DIR"/*/; do
    [ -d "$d" ] || continue
    encoded=$(basename "$d"); decoded="/$(echo "$encoded"|sed 's|^-||; s|-|/|g')"
    collect "$decoded"
  done
fi
for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || continue
  while IFS= read -r marker; do collect "$(dirname "$marker")"; done \
    < <(find "$root" -maxdepth 4 -name 'CLAUDE.md' 2>/dev/null)
done
N=${#NAMES[@]}
order=()
if [ "$N" -gt 0 ]; then
  for i in $(seq 0 $((N-1))); do order+=("$i"); done
  for ((a=1; a<N; a++)); do
    key=${order[a]}; ke=${EPOCHS[$key]}; b=$((a-1))
    while [ $b -ge 0 ] && [ "${EPOCHS[${order[b]}]}" -lt "$ke" ]; do
      order[$((b+1))]=${order[b]}; b=$((b-1))
    done
    order[$((b+1))]=$key
  done
fi
stale_cutoff=$(( now_epoch - STALE_DAYS*86400 ))
echo
echo "${BOLD}${GRN}===============================================${RST}"
echo "${BOLD}${GRN}  MISSION CONTROL — $(date '+%Y-%m-%d %H:%M')${RST}"
echo "${BOLD}${GRN}===============================================${RST}"
echo
echo "  Projects found: ${BOLD}${N}${RST}"
echo
attn=""
for i in "${order[@]:-}"; do
  [ -z "${i:-}" ] && continue
  if [ "${EPOCHS[$i]}" -gt 0 ] && [ "${EPOCHS[$i]}" -lt "$stale_cutoff" ]; then
    attn+="  ${RED}(!)${RST}  ${NAMES[$i]} — last touched ${LASTS[$i]} (stale > ${STALE_DAYS}d)\n"
  fi
  if [ "${DIRTIES[$i]}" -gt 0 ]; then
    attn+="  ${YEL}(*)${RST}  ${NAMES[$i]} — ${DIRTIES[$i]} uncommitted changes\n"
  fi
done
if [ -n "$attn" ]; then
  echo "${BOLD}--- NEEDS ATTENTION ---------------------------${RST}"
  printf "%b" "$attn"; echo
fi
echo "${BOLD}--- ALL PROJECTS (most recent first) ----------${RST}"
echo
for i in "${order[@]:-}"; do
  [ -z "${i:-}" ] && continue
  printf "  ${BOLD}%s${RST} ${DIM}— last %s | %s${RST}\n" "${NAMES[$i]}" "${LASTS[$i]}" "${GITS[$i]}"
  printf "    ${DIM}%s${RST}\n\n" "${DESCS[$i]}"
done
echo "${BOLD}${GRN}===============================================${RST}"
echo
