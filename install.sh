#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_DIR="${OMARCHY_INSTALL_CONFIG_DIR:-$HOME/.config}"
PICTURES_DIR="${OMARCHY_INSTALL_PICTURES_DIR:-$HOME/Pictures}"
INSTALL_VSCODE_EXTENSIONS="${OMARCHY_INSTALL_VSCODE_EXTENSIONS:-0}"

usage() {
  cat <<'EOF'
Uso: ./install.sh [opcoes]

Instala os arquivos deste repositorio seguindo o SCRIPT-GUIDE.md.

Regras aplicadas:
  - Substituir: bin, omarchy/themes, waybar, vscode/settings.json
  - Mesclar: hypr, omarchy/backgrounds

Opcoes:
  --config-dir <caminho>          Base para destinos em ~/.config
  --pictures-dir <caminho>        Base para o destino ~/Pictures
  --install-vscode-extensions     Instala extensoes de vscode/extensions.txt
  -h, --help                      Mostra esta ajuda

Variaveis de ambiente equivalentes:
  OMARCHY_INSTALL_CONFIG_DIR
  OMARCHY_INSTALL_PICTURES_DIR
  OMARCHY_INSTALL_VSCODE_EXTENSIONS=1
EOF
}

log() {
  printf '[install] %s\n' "$*"
}

fail() {
  printf '[erro] %s\n' "$*" >&2
  exit 1
}

require_dir() {
  local path="$1"

  [[ -d "$path" ]] || fail "pasta obrigatoria ausente: $path"
}

require_file() {
  local path="$1"

  [[ -f "$path" ]] || fail "arquivo obrigatorio ausente: $path"
}

normalize_path() {
  realpath -m "$1"
}

assert_copy_target() {
  local src="$1"
  local dest="$2"
  local normalized_src
  local normalized_dest

  normalized_src="$(normalize_path "$src")"
  normalized_dest="$(normalize_path "$dest")"

  if [[ "$normalized_dest" == "$normalized_src" || "$normalized_dest" == "$normalized_src"/* ]]; then
    fail "destino nao pode ser igual ou interno a origem: $dest"
  fi
}

assert_safe_remove() {
  local path="$1"
  local normalized_path

  normalized_path="$(normalize_path "$path")"

  case "$normalized_path" in
    ''|'/')
      fail "recusando remover caminho perigoso: $path"
      ;;
  esac

  if [[ "$normalized_path" == "$HOME" || "$normalized_path" == "$CONFIG_DIR" || "$normalized_path" == "$PICTURES_DIR" ]]; then
    fail "recusando remover diretorio base: $path"
  fi
}

remove_path() {
  local path="$1"

  assert_safe_remove "$path"

  if [[ -e "$path" || -L "$path" ]]; then
    rm -rf -- "$path"
  fi
}

replace_dir() {
  local src="$1"
  local dest="$2"

  require_dir "$src"
  assert_copy_target "$src" "$dest"

  log "Substituir pasta: $dest"
  remove_path "$dest"
  mkdir -p -- "${dest%/*}"
  cp -a -- "$src" "$dest"
}

merge_dir_contents() {
  local src="$1"
  local dest="$2"
  local item
  local name
  local target

  mkdir -p -- "$dest"

  shopt -s dotglob nullglob
  for item in "$src"/*; do
    name="${item##*/}"
    target="$dest/$name"

    if [[ -d "$item" && ! -L "$item" ]]; then
      if [[ -e "$target" || -L "$target" ]]; then
        if [[ ! -d "$target" || -L "$target" ]]; then
          remove_path "$target"
          mkdir -p -- "$target"
        fi
      else
        mkdir -p -- "$target"
      fi

      merge_dir_contents "$item" "$target"
    else
      remove_path "$target"
      cp -a -- "$item" "$target"
    fi
  done
  shopt -u dotglob nullglob
}

merge_dir() {
  local src="$1"
  local dest="$2"

  require_dir "$src"
  assert_copy_target "$src" "$dest"

  log "Mesclar pasta: $dest (prioridade repositorio)"
  merge_dir_contents "$src" "$dest"
}

replace_file() {
  local src="$1"
  local dest="$2"

  require_file "$src"
  assert_copy_target "$src" "$dest"

  log "Substituir arquivo: $dest"
  mkdir -p -- "${dest%/*}"
  remove_path "$dest"
  cp -a -- "$src" "$dest"
}

install_vscode_extensions() {
  local file="$SCRIPT_DIR/vscode/extensions.txt"
  local extension

  require_file "$file"

  if ! command -v code >/dev/null 2>&1; then
    fail "comando code nao encontrado no PATH"
  fi

  log 'Instalando extensoes do VS Code...'
  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" =~ ^[[:space:]]*# ]] && continue
    code --install-extension "$extension"
  done <"$file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config-dir)
      [[ $# -ge 2 ]] || fail '--config-dir exige um argumento'
      CONFIG_DIR="$2"
      shift 2
      ;;
    --pictures-dir)
      [[ $# -ge 2 ]] || fail '--pictures-dir exige um argumento'
      PICTURES_DIR="$2"
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
      usage
      fail "opcao desconhecida: $1"
      ;;
  esac
done

case "$INSTALL_VSCODE_EXTENSIONS" in
  0|1) ;;
  *) fail 'OMARCHY_INSTALL_VSCODE_EXTENSIONS deve ser 0 ou 1' ;;
esac

CONFIG_DIR="$(normalize_path "$CONFIG_DIR")"
PICTURES_DIR="$(normalize_path "$PICTURES_DIR")"

log "Repositorio: $SCRIPT_DIR"
log "Destino .config: $CONFIG_DIR"
log "Destino Pictures: $PICTURES_DIR"

replace_dir "$SCRIPT_DIR/bin" "$CONFIG_DIR/bin"
merge_dir "$SCRIPT_DIR/hypr" "$CONFIG_DIR/hypr"
merge_dir "$SCRIPT_DIR/omarchy/backgrounds" "$PICTURES_DIR/backgrounds"
replace_dir "$SCRIPT_DIR/omarchy/themes" "$CONFIG_DIR/omarchy/themes"
replace_dir "$SCRIPT_DIR/waybar" "$CONFIG_DIR/waybar"
replace_file "$SCRIPT_DIR/vscode/settings.json" "$CONFIG_DIR/Code/User/settings.json"

if [[ "$INSTALL_VSCODE_EXTENSIONS" -eq 1 ]]; then
  install_vscode_extensions
else
  log 'Extensoes do VS Code nao instaladas (use --install-vscode-extensions).'
fi

log 'Instalacao concluida com sucesso.'
