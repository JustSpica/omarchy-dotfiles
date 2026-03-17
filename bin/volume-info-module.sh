#!/usr/bin/env bash

set -u

FILLED="█"
EMPTY="░"
BAR_LENGTH=10

get_progress_bar() {
  local percent=$1
  local filled_len empty_len bar

  filled_len=$(( (percent * BAR_LENGTH + 50) / 100 ))
  if (( filled_len < 0 )); then filled_len=0; fi
  if (( filled_len > BAR_LENGTH )); then filled_len=$BAR_LENGTH; fi
  empty_len=$(( BAR_LENGTH - filled_len ))

  bar=""
  while (( filled_len > 0 )); do
    bar+="$FILLED"
    ((filled_len--))
  done
  while (( empty_len > 0 )); do
    bar+="$EMPTY"
    ((empty_len--))
  done

  printf '%s' "$bar"
}

get_volume_json() {
  local vol_output mute_output percent is_muted bar icon tooltip

  vol_output=$(pamixer --get-volume 2>/dev/null || true)
  mute_output=$(pamixer --get-mute 2>/dev/null || true)

  if [[ ! $vol_output =~ ^[0-9]+$ ]]; then
    printf '{"text":"","tooltip":""}\n'
    return 0
  fi

  percent=$vol_output
  is_muted=0
  if [[ "$mute_output" == "true" ]]; then
    is_muted=1
  fi

  bar=$(get_progress_bar "$percent")
  if (( is_muted == 1 || percent == 0 )); then
    icon=""
  else
    icon=""
  fi

  if (( is_muted == 1 )); then
    tooltip="Volume: ${percent}% (Silenciado)"
  else
    tooltip="Volume: ${percent}% "
  fi

  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg icon "$icon" --arg bar "$bar" --arg tooltip "$tooltip" '{
      text: ("<span color=\"#f9e2af\">[ " + $icon + " " + $bar + " ]</span>"),
      tooltip: $tooltip
    }'
  else
    printf '{"text":"<span color=\"#f9e2af\">[ %s %s ]</span>","tooltip":"%s"}\n' "$icon" "$bar" "$tooltip"
  fi
}

get_volume_json
