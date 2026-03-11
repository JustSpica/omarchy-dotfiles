#!/usr/bin/env bash

USER_LOOKNFEEL="$HOME/.config/hypr/looknfeel.conf"
DEFAULT_LOOKNFEEL="$HOME/.local/share/omarchy/default/hypr/looknfeel.conf"

read_conf_value() {
    local file="$1"
    local key="$2"

    if [ ! -f "$file" ]; then
        return 0
    fi

    awk -v k="$key" '
        {
            sub(/#.*/, "")
        }
        $0 ~ "^[[:space:]]*" k "[[:space:]]*=" {
            sub("^[[:space:]]*" k "[[:space:]]*=", "")
            gsub(/^[[:space:]]+|[[:space:]]+$/, "")
            print
            exit
        }
    ' "$file"
}

read_var_value() {
    local file="$1"
    local var="$2"

    read_conf_value "$file" "\\$$var"
}

resolve_value() {
    local val="$1"
    local var
    local resolved

    if [[ "$val" == \$* ]]; then
        var="${val#\$}"
        resolved=$(read_var_value "$USER_LOOKNFEEL" "$var")
        if [ -z "$resolved" ]; then
            resolved=$(read_var_value "$DEFAULT_LOOKNFEEL" "$var")
        fi
        printf '%s' "$resolved"
        return 0
    fi

    printf '%s' "$val"
}

get_default_value() {
    local key="$1"
    local fallback="$2"
    local val

    val=$(read_conf_value "$USER_LOOKNFEEL" "$key")
    if [ -z "$val" ]; then
        val=$(read_conf_value "$DEFAULT_LOOKNFEEL" "$key")
    fi
    if [ -z "$val" ]; then
        val="$fallback"
    fi

    printf '%s' "$val"
}

GAPS_IN_DEF=$(get_default_value "gaps_in" "2")
GAPS_OUT_DEF=$(get_default_value "gaps_out" "4")
ROUNDING_SIZE_DEF=$(get_default_value "rounding" "0")

# Pega o ID do workspace atual
ID=$(hyprctl activeworkspace -j | jq -r '.id')
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-toggle-layout"
STATE="$STATE_DIR/ws-$ID"

if [ ! -f "$STATE" ]; then
    mkdir -p "$STATE_DIR"
    printf '%s\n' "1" > "$STATE"

    # ENTRA NO MODO FULLSCREEN (apenas neste workspace)
    hyprctl keyword workspace "$ID,rounding:0,gapsin:0,gapsout:0,decorate:0"
    killall -SIGUSR1 waybar
else
    if [ "$ROUNDING_SIZE_DEF" -gt 0 ]; then
        ROUNDING=1
    else
        ROUNDING=0
    fi

    GAPS_IN=$GAPS_IN_DEF
    GAPS_OUT=$GAPS_OUT_DEF

    # VOLTA AO NORMAL (restaura valores anteriores deste workspace)
    hyprctl keyword workspace "$ID,rounding:$ROUNDING,gapsin:$GAPS_IN,gapsout:$GAPS_OUT,decorate:1"
    rm -f "$STATE"
    killall -SIGUSR1 waybar
fi
