#!/usr/bin/env bash
set -euo pipefail

SOURCE_FILE="${OMARCHY_COLORS_FILE:-$HOME/.config/omarchy/current/theme/colors.toml}"
TARGET_FILE="${SPICETIFY_COLOR_FILE:-$HOME/.config/spicetify/Themes/omarchy-sync/color.ini}"
SCHEME_NAME="${1:-OmarchySync}"

if [[ ! -f "$SOURCE_FILE" ]]; then
  printf 'Erro: arquivo de origem nao encontrado: %s\n' "$SOURCE_FILE" >&2
  exit 1
fi

declare -A COLORS=()

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  if [[ "$line" =~ ^[[:space:]]*([[:alnum:]_]+)[[:space:]]*=[[:space:]]*\"([^\"]*)\"([[:space:]]*#.*)?$ ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    COLORS["$key"]="$value"
  fi
done <"$SOURCE_FILE"

get_value() {
  local key="$1"
  local fallback="$2"

  if [[ -n "${COLORS[$key]+_}" && -n "${COLORS[$key]-}" ]]; then
    printf '%s' "${COLORS[$key]-}"
  else
    printf '%s' "$fallback"
  fi
}

normalize_color() {
  local raw="$1"
  raw="${raw#\#}"
  printf '%s' "${raw^^}"
}

resolve_color() {
  local key="$1"
  local fallback="$2"
  local value

  value="$(get_value "$key" "$fallback")"

  if [[ -z "$value" ]]; then
    printf 'Erro: token de cor ausente: %s\n' "$key" >&2
    exit 1
  fi

  normalize_color "$value"
}

foreground_or_default="$(get_value "foreground" "CFCFCF")"
background_or_default="$(get_value "background" "151515")"
accent_or_default="$(get_value "accent" "2A2A2A")"
color4_or_default="$(get_value "color4" "4A8BFF")"
color0_or_default="$(get_value "color0" "666666")"
color7_or_default="$(get_value "color7" "999999")"

declare -A MAPPING=()
declare -a ORDERED_KEYS=(
  "text"
  "subtext"
  "main"
  "sidebar"
  "player"
  "card"
  "shadow"
  "selected-row"
  "button"
  "button-active"
  "button-disabled"
  "tab-active"
  "notification"
  "notification-error"
  "misc"
)

MAPPING["text"]="$(resolve_color "foreground" "D9D9D9")"
MAPPING["subtext"]="$(resolve_color "selection_foreground" "$foreground_or_default")"
MAPPING["main"]="$(resolve_color "background" "1E1E1E")"
MAPPING["sidebar"]="$(resolve_color "background" "1E1E1E")"
MAPPING["player"]="$(resolve_color "background" "1E1E1E")"
MAPPING["card"]="$(resolve_color "color0" "$background_or_default")"
MAPPING["shadow"]="$(resolve_color "background" "1E1E1E")"
MAPPING["selected-row"]="$(resolve_color "selection_background" "$accent_or_default")"
MAPPING["button"]="$(resolve_color "accent" "$color4_or_default")"
MAPPING["button-active"]="$(resolve_color "selection_foreground" "$(get_value "foreground" "FFFFFF")")"
MAPPING["button-disabled"]="$(resolve_color "color8" "$color0_or_default")"
MAPPING["tab-active"]="$(resolve_color "accent" "$color4_or_default")"
MAPPING["notification"]="$(resolve_color "color0" "$background_or_default")"
MAPPING["notification-error"]="$(resolve_color "color1" "$(get_value "accent" "FF5555")")"
MAPPING["misc"]="$(resolve_color "cursor" "$color7_or_default")"

mkdir -p "$(dirname "$TARGET_FILE")"

max_key_len=0
for key in "${ORDERED_KEYS[@]}"; do
  if (( ${#key} > max_key_len )); then
    max_key_len=${#key}
  fi
done

{
  printf '[%s]\n' "$SCHEME_NAME"
  for key in "${ORDERED_KEYS[@]}"; do
    printf "%-${max_key_len}s = %s\n" "$key" "${MAPPING[$key]}"
  done
} >"$TARGET_FILE"

printf 'Arquivo gerado: %s\n' "$TARGET_FILE"
