#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OMARCHY_INSTALL_CONFIG_DIR:-$HOME/.config}"
INSTALL_VSCODE_EXTENSIONS=0

usage() {
  cat <<'EOF'
Uso: ./install.sh [opcoes]

Instala os arquivos deste repositorio seguindo o SCRIPT-GUIDE.md.

Opcoes:
  --config-dir <caminho>          Define destino base (padrao: ~/.config)
  --install-vscode-extensions     Instala extensoes de vscode/extensions.txt
  -h, --help                      Mostra esta ajuda

Variavel de ambiente equivalente:
  OMARCHY_INSTALL_CONFIG_DIR
EOF
}

log() {
  printf '[install] %s\n' "$1"
}

require_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    printf '[erro] caminho obrigatorio ausente: %s\n' "$path" >&2
    exit 1
  fi
}

replace_dir() {
  local src="$1"
  local rel_dest="$2"
  local dest="$CONFIG_DIR/$rel_dest"

  require_path "$src"

  log "Substituir pasta: $dest"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
}

merge_dir() {
  local src="$1"
  local rel_dest="$2"
  local dest="$CONFIG_DIR/$rel_dest"

  require_path "$src"

  log "Mesclar pasta: $dest (prioridade repositorio)"
  mkdir -p "$dest"
  cp -a "$src"/. "$dest"/
}

replace_file() {
  local src="$1"
  local rel_dest="$2"
  local dest="$CONFIG_DIR/$rel_dest"

  require_path "$src"

  log "Substituir arquivo: $dest"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
}

install_vscode_extensions() {
  local file="$SCRIPT_DIR/vscode/extensions.txt"

  require_path "$file"

  if ! command -v code >/dev/null 2>&1; then
    printf '[erro] comando code nao encontrado no PATH\n' >&2
    return 1
  fi

  log 'Instalando extensoes do VS Code...'
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" ]] && continue
    code --install-extension "$extension"
  done <"$file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config-dir)
      if [[ $# -lt 2 ]]; then
        printf '[erro] --config-dir exige um argumento\n' >&2
        exit 1
      fi
      CONFIG_DIR="$2"
      shift 2
      ;;
    --install-vscode-extensions)
      INSTALL_VSCODE_EXTENSIONS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '[erro] opcao desconhecida: %s\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
done

CONFIG_DIR="$(realpath -m "$CONFIG_DIR")"

log "Repositorio: $SCRIPT_DIR"
log "Destino .config: $CONFIG_DIR"

replace_dir "$SCRIPT_DIR/bash" "bash"
replace_dir "$SCRIPT_DIR/bin" "bin"
merge_dir "$SCRIPT_DIR/btop" "btop"
merge_dir "$SCRIPT_DIR/hypr" "hypr"
replace_dir "$SCRIPT_DIR/omarchy" "omarchy"
replace_dir "$SCRIPT_DIR/sgpt" "sgpt"
replace_dir "$SCRIPT_DIR/spicetify" "spicetify"
replace_dir "$SCRIPT_DIR/waybar" "waybar"
replace_dir "$SCRIPT_DIR/zathura" "zathura"

replace_file "$SCRIPT_DIR/vscode/settings.json" "Code/User/settings.json"

if [[ "$INSTALL_VSCODE_EXTENSIONS" -eq 1 ]]; then
  install_vscode_extensions
else
  log 'Extensoes do VS Code nao instaladas (use --install-vscode-extensions).'
fi

log 'Instalacao concluida com sucesso.'
