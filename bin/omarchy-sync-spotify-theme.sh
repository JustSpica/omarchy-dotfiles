#!/usr/bin/env bash
set -euo pipefail

SOURCE_FILE="${OMARCHY_COLORS_FILE:-$HOME/.config/omarchy/current/theme/colors.toml}"
TARGET_FILE="${SPICETIFY_COLOR_FILE:-$HOME/.config/spicetify/Themes/omarchy-sync/color.ini}"
SCHEME_NAME="${1:-OmarchySync}"

if [[ ! -f "$SOURCE_FILE" ]]; then
  printf 'Erro: arquivo de origem nao encontrado: %s\n' "$SOURCE_FILE" >&2
  exit 1
fi

python3 - "$SOURCE_FILE" "$TARGET_FILE" "$SCHEME_NAME" <<'PY'
import sys
import tomllib

source_file, target_file, scheme_name = sys.argv[1:4]

with open(source_file, "rb") as f:
    data = tomllib.load(f)


def color(name, fallback=None):
    value = data.get(name, fallback)
    if value is None:
        raise KeyError(f"Token de cor ausente: {name}")
    if not isinstance(value, str):
        raise TypeError(f"Token invalido para {name}: {value!r}")
    return value.lstrip("#").upper()


mapping = {
    "text": color("foreground", "D9D9D9"),
    "subtext": color("selection_foreground", data.get("foreground", "CFCFCF")),
    "main": color("background", "1E1E1E"),
    "sidebar": color("background", "1E1E1E"),
    "player": color("background", "1E1E1E"),
    "card": color("color0", data.get("background", "151515")),
    "shadow": color("background", "1E1E1E"),
    "selected-row": color("selection_background", data.get("accent", "2A2A2A")),
    "button": color("accent", data.get("color4", "4A8BFF")),
    "button-active": color("selection_foreground", data.get("foreground", "FFFFFF")),
    "button-disabled": color("color8", data.get("color0", "666666")),
    "tab-active": color("accent", data.get("color4", "4A8BFF")),
    "notification": color("color0", data.get("background", "151515")),
    "notification-error": color("color1", data.get("accent", "FF5555")),
    "misc": color("cursor", data.get("color7", "999999")),
}

ordered_keys = [
    "text",
    "subtext",
    "main",
    "sidebar",
    "player",
    "card",
    "shadow",
    "selected-row",
    "button",
    "button-active",
    "button-disabled",
    "tab-active",
    "notification",
    "notification-error",
    "misc",
]

max_key_len = max(len(k) for k in ordered_keys)

with open(target_file, "w", encoding="utf-8") as out:
    out.write(f"[{scheme_name}]\n")
    for key in ordered_keys:
        out.write(f"{key.ljust(max_key_len)} = {mapping[key]}\n")
PY

printf 'Arquivo gerado: %s\n' "$TARGET_FILE"
