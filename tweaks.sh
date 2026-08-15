#!/usr/bin/env bash
# Ajustes pontuais em arquivos que o Omarchy também mantém.
#
# Estes arquivos NÃO são versionados inteiros de propósito: guardar a cópia
# completa congelaria o default do Omarchy e as melhorias das próximas versões
# nunca chegariam. Em vez disso, cada ajuste abaixo é reaplicado por cima do
# arquivo atual — e é idempotente, então rodar duas vezes não faz diferença.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_ROOT/lib/common.sh"

GIT_USER_NAME="Guilherme Spica Luiz"
GIT_USER_EMAIL="Guilhermespicaluiz@gmail.com"
ALACRITTY_FONT_SIZE=11
BTOP_UPDATE_MS=100
DEFAULT_TERMINAL=alacritty
DEFAULT_BROWSER=chrome

section "Hyprland"

# Registra o workspaces.lua no loader. O hyprland.lua é do Omarchy; só
# acrescentamos a linha do require, logo após o require dos monitores.
hyprland_lua="$CONFIG_HOME/hypr/hyprland.lua"
if [[ ! -f $hyprland_lua ]]; then
  warn "hyprland.lua ausente"
elif grep -q 'require("hypr.workspaces")' "$hyprland_lua"; then
  skip "require hypr.workspaces (já aplicado)"
elif ! grep -q 'require("hypr.monitors")' "$hyprland_lua"; then
  warn "require hypr.workspaces (âncora hypr.monitors não encontrada)"
else
  run sed -i '/require("hypr.monitors")/a require("hypr.workspaces")' "$hyprland_lua"
  ok "require hypr.workspaces"
fi

section "Terminal"

# A checagem lê o arquivo em vez de perguntar ao xdg-terminal-exec, para que o
# resultado acompanhe o CONFIG_HOME em uso e não o ambiente do processo.
terminals_list="$CONFIG_HOME/xdg-terminals.list"
if [[ -f $terminals_list ]] && grep -qi "^${DEFAULT_TERMINAL}\.desktop$" "$terminals_list"; then
  skip "terminal padrão já é $DEFAULT_TERMINAL"
elif command -v omarchy-default-terminal >/dev/null; then
  run omarchy-default-terminal "$DEFAULT_TERMINAL"
  ok "terminal padrão -> $DEFAULT_TERMINAL"
else
  warn "omarchy-default-terminal não encontrado"
fi

ensure_line "$CONFIG_HOME/alacritty/alacritty.toml" \
  '^size = .*' "size = $ALACRITTY_FONT_SIZE" \
  "alacritty: fonte $ALACRITTY_FONT_SIZE"

section "Navegador"

# O omarchy-default-browser grava via xdg-settings, que por sua vez escreve o
# mimeapps.list. Consultar pelo próprio comando mantém a checagem alinhada com
# a forma como ele grava.
if ! command -v omarchy-default-browser >/dev/null; then
  warn "omarchy-default-browser não encontrado"
elif [[ "$(omarchy-default-browser 2>/dev/null)" == "$DEFAULT_BROWSER" ]]; then
  skip "navegador padrão já é $DEFAULT_BROWSER"
else
  run omarchy-default-browser "$DEFAULT_BROWSER"
  ok "navegador padrão -> $DEFAULT_BROWSER"
fi

section "Git"

git_config="$CONFIG_HOME/git/config"
if [[ ! -f $git_config ]]; then
  warn "git/config ausente"
else
  for pair in "user.name:$GIT_USER_NAME" "user.email:$GIT_USER_EMAIL"; do
    key=${pair%%:*}; value=${pair#*:}
    if [[ "$(git config --file "$git_config" --get "$key" 2>/dev/null)" == "$value" ]]; then
      skip "$key (já aplicado)"
    else
      run git config --file "$git_config" "$key" "$value"
      ok "$key = $value"
    fi
  done
fi

section "Aplicativos"

ensure_line "$CONFIG_HOME/btop/btop.conf" \
  '^update_ms = .*' "update_ms = $BTOP_UPDATE_MS" \
  "btop: update_ms $BTOP_UPDATE_MS"

# Obsidian roda melhor com a GPU ligada; o default do Omarchy a desliga.
ensure_line "$CONFIG_HOME/obsidian/user-flags.conf" \
  '^-disable-gpu$' '#-disable-gpu' \
  "obsidian: GPU habilitada"

# O opencode segue o tema do terminal quando a chave não existe.
opencode_json="$CONFIG_HOME/opencode/opencode.json"
if [[ ! -f $opencode_json ]]; then
  warn "opencode.json ausente"
elif ! command -v jq >/dev/null; then
  warn "opencode: jq não instalado"
elif ! jq -e 'has("theme")' "$opencode_json" >/dev/null 2>&1; then
  skip "opencode: chave theme (já removida)"
else
  run bash -c "jq 'del(.theme)' '$opencode_json' > '$opencode_json.tmp' && mv '$opencode_json.tmp' '$opencode_json'"
  ok "opencode: chave theme removida"
fi
