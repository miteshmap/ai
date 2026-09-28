#!/bin/sh
# Claude Code status line — usage-bar style
input=$(cat)

# ANSI colours
RESET='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
WHITE='\033[37m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
CYAN='\033[36m'
GREEN='\033[32m'
ORANGE='\033[38;5;214m'
RED='\033[31m'
GREY='\033[90m'

# ── Helpers ────────────────────────────────────────────────────────────────────

# colour_for_pct <pct>  →  prints the ANSI escape for that usage level
colour_for_pct() {
  pct=$1
  if [ -z "$pct" ]; then printf "%s" "$GREY"; return; fi
  int_pct=$(printf "%.0f" "$pct")
  if   [ "$int_pct" -ge 90 ]; then printf "%s" "$RED"
  elif [ "$int_pct" -ge 71 ]; then printf "%s" "$ORANGE"
  else                              printf "%s" "$GREEN"
  fi
}

# status_label <pct>  →  prints  Normal / Warning / Critical  with colour
status_label() {
  pct=$1
  if [ -z "$pct" ]; then printf "${GREY}Normal${RESET}"; return; fi
  int_pct=$(printf "%.0f" "$pct")
  if   [ "$int_pct" -ge 90 ]; then printf "${RED}${BOLD}Critical${RESET}"
  elif [ "$int_pct" -ge 71 ]; then printf "${ORANGE}${BOLD}Warning${RESET}"
  else                              printf "${GREEN}${BOLD}Normal${RESET}"
  fi
}

# make_bar <pct> <width>  →  e.g.  ██████░░░░
make_bar() {
  pct=$1
  width=${2:-10}
  if [ -z "$pct" ]; then
    i=0; while [ "$i" -lt "$width" ]; do printf "░"; i=$((i+1)); done
    return
  fi
  filled=$(awk -v p="$pct" -v w="$width" 'BEGIN { v=int(p/100*w+0.5); if(v>w) v=w; print v }')
  empty=$((width - filled))
  i=0; while [ "$i" -lt "$filled" ]; do printf "█"; i=$((i+1)); done
  i=0; while [ "$i" -lt "$empty"  ]; do printf "░"; i=$((i+1)); done
}

# format_countdown <unix_epoch>  →  Xh Ym  or  Xd Xh
format_5h_countdown() {
  secs=$1
  now=$(date +%s)
  diff=$((secs - now))
  [ "$diff" -le 0 ] 2>/dev/null && { printf "now"; return; }
  h=$((diff / 3600))
  m=$(( (diff % 3600) / 60 ))
  printf "%dh %dm" "$h" "$m"
}

format_7d_countdown() {
  secs=$1
  now=$(date +%s)
  diff=$((secs - now))
  [ "$diff" -le 0 ] 2>/dev/null && { printf "now"; return; }
  d=$((diff / 86400))
  h=$(( (diff % 86400) / 3600 ))
  printf "%dd %dh" "$d" "$h"
}

# ── Data extraction ─────────────────────────────────────────────────────────────

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir=$(pwd)
short_dir=$(basename "$dir")
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)

ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Overall worst usage (for the status label)
worst=""
for pct in "$five_pct" "$week_pct" "$ctx_used"; do
  if [ -n "$pct" ]; then
    if [ -z "$worst" ]; then
      worst=$pct
    else
      worst=$(awk -v a="$worst" -v b="$pct" 'BEGIN { print (a>b)?a:b }')
    fi
  fi
done

# ── Render ──────────────────────────────────────────────────────────────────────

# Project dir + branch
printf "${YELLOW}${short_dir}${RESET}"
if [ -n "$branch" ]; then
  printf "${WHITE} on ${RESET}${MAGENTA}${branch}${RESET}"
fi

printf "  "

# Status indicator
status_label "$worst"

# Separator
printf " ${GREY}│${RESET} "

# 5h bar
if [ -n "$five_pct" ]; then
  col=$(colour_for_pct "$five_pct")
  bar=$(make_bar "$five_pct" 10)
  int_five=$(printf "%.0f" "$five_pct")
  printf "${WHITE}5h:${RESET} ${col}[${bar}]${RESET} ${col}${int_five}%%${RESET}"
  if [ -n "$five_reset" ]; then
    cd5=$(format_5h_countdown "$five_reset")
    printf " ${GREY}reset ${cd5}${RESET}"
  fi
  printf " ${GREY}│${RESET} "
fi

# 7d bar
if [ -n "$week_pct" ]; then
  col=$(colour_for_pct "$week_pct")
  bar=$(make_bar "$week_pct" 10)
  int_week=$(printf "%.0f" "$week_pct")
  printf "${WHITE}7d:${RESET} ${col}[${bar}]${RESET} ${col}${int_week}%%${RESET}"
  if [ -n "$week_reset" ]; then
    cd7=$(format_7d_countdown "$week_reset")
    printf " ${GREY}reset ${cd7}${RESET}"
  fi
  printf " ${GREY}│${RESET} "
fi

# ctx bar
if [ -n "$ctx_used" ]; then
  col=$(colour_for_pct "$ctx_used")
  bar=$(make_bar "$ctx_used" 10)
  int_ctx=$(printf "%.0f" "$ctx_used")
  printf "${WHITE}ctx:${RESET} ${col}[${bar}]${RESET} ${col}${int_ctx}%%${RESET}"
fi

# Model name
if [ -n "$model" ]; then
  printf " ${GREY}|${RESET} ${CYAN}${model}${RESET}"
fi

printf "\n"
