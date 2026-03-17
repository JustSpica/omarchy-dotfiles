#!/usr/bin/env bash

set -u

FILLED="█"
EMPTY="░"
BAR_LENGTH=10

# Limites (Kelvin)
MIN_K=4000  # Quente (4000K)
MAX_K=6000  # Padrão (6000K)
STEP=200    # Passo do scroll

HYPRCTL_BIN=$(command -v hyprctl 2>/dev/null || true)

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

get_current_k() {
  local output value

  if [[ -z "$HYPRCTL_BIN" ]]; then
    printf '%s' "$MAX_K"
    return 0
  fi

  output=$($HYPRCTL_BIN hyprsunset temperature 2>/dev/null || true)

  if [[ $output =~ ([0-9]+)[[:space:]]*K ]]; then
    value=${BASH_REMATCH[1]}
  elif [[ $output =~ ([0-9]+) ]]; then
    value=${BASH_REMATCH[1]}
  else
    value=""
  fi

  if [[ -n "$value" ]]; then
    printf '%s' "$value"
  else
    printf '%s' "$MAX_K"
  fi
}

change_temperature() {
  local direction=$1
  local current new_k

  current=$(get_current_k)
  if [[ "$direction" == "up" ]]; then
    new_k=$(( current - STEP ))
  else
    new_k=$(( current + STEP ))
  fi

  if (( new_k < MIN_K )); then new_k=$MIN_K; fi
  if (( new_k > MAX_K )); then new_k=$MAX_K; fi

  if [[ -n "$HYPRCTL_BIN" ]]; then
    $HYPRCTL_BIN hyprsunset temperature "$new_k" >/dev/null 2>&1 || true
  fi
  printf '{}\n'
}

get_temperature() {
  local current_k is_active range_k diff percent bar text_state class_name

  current_k=$(get_current_k)
  if (( current_k < MAX_K )); then
    is_active=1
  else
    is_active=0
  fi

  if (( is_active == 1 )); then
    range_k=$(( MAX_K - MIN_K ))
    diff=$(( MAX_K - current_k ))
    percent=$(( (diff * 100) / range_k ))
    bar=$(get_progress_bar "$percent")
    text_state="${current_k}K"
    class_name="active"
  else
    bar=$(get_progress_bar 0)
    text_state="Off"
    class_name="inactive"
  fi

  jq -cn --arg bar "$bar" --arg text_state "$text_state" --arg class_name "$class_name" '{
    text: ("<span color=\"#f38ba8\">[  " + $bar + " ]</span>"),
    tooltip: ("Night Light: " + $text_state + " (Hyprsunset)"),
    class: $class_name
  }'
}

main() {
  if [[ $# -gt 0 ]]; then
    case "$1" in
      up)
        change_temperature up
        return 0
        ;;
      down)
        change_temperature down
        return 0
        ;;
    esac
  fi

  if ! command -v jq >/dev/null 2>&1; then
    printf '{"text":"[  ░░░░░░░░░░ ]","tooltip":"Night Light: jq missing","class":"inactive"}\n'
    return 0
  fi

  get_temperature
}

main "$@"
