#!/usr/bin/env bash
# Helpers compartilhados pelos scripts do repositório.

set -euo pipefail

REPO_ROOT=${REPO_ROOT:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}
CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
BACKUP_DIR="$CONFIG_HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

DRY_RUN=${DRY_RUN:-0}

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_OK=$'\033[32m'
  C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_HEAD=$'\033[1;36m'
else
  C_RESET=; C_DIM=; C_OK=; C_WARN=; C_ERR=; C_HEAD=
fi

section() { printf '\n%s==> %s%s\n' "$C_HEAD" "$1" "$C_RESET"; }
ok()      { printf '  %s✓%s %s\n' "$C_OK" "$C_RESET" "$1"; }
skip()    { printf '  %s·%s %s\n' "$C_DIM" "$C_RESET" "$1"; }
warn()    { printf '  %s!%s %s\n' "$C_WARN" "$C_RESET" "$1"; }
err()     { printf '  %s✗%s %s\n' "$C_ERR" "$C_RESET" "$1" >&2; }

run() {
  if ((DRY_RUN)); then
    printf '  %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"
  else
    "$@"
  fi
}

# Guarda uma cópia antes de substituir um arquivo real.
backup() {
  local target=$1
  [[ -e $target && ! -L $target ]] || return 0
  local dest="$BACKUP_DIR/${target#"$CONFIG_HOME"/}"
  run mkdir -p "$(dirname "$dest")"
  run cp -a "$target" "$dest"
  warn "backup: ${target/#$HOME/\~} -> ${dest/#$HOME/\~}"
}

# Cria (ou corrige) um symlink de ~/.config/<rel> para <repo>/link/<rel>.
link_file() {
  local rel=$1
  local src="$REPO_ROOT/link/$rel"
  local dst="$CONFIG_HOME/$rel"

  if [[ ! -e $src ]]; then
    err "ausente no repo: link/$rel"
    return 1
  fi

  if [[ -L $dst && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    skip "$rel (já enlaçado)"
    return 0
  fi

  backup "$dst"
  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  ok "$rel -> link/$rel"
}

# Substitui a primeira linha que casa com um padrão, só se ainda não estiver aplicada.
ensure_line() {
  local file=$1 pattern=$2 replacement=$3 label=$4

  [[ -f $file ]] || { skip "$label (arquivo ausente: ${file/#$HOME/\~})"; return 0; }

  if grep -qxF -- "$replacement" "$file"; then
    skip "$label (já aplicado)"
    return 0
  fi

  if ! grep -qE -- "$pattern" "$file"; then
    warn "$label (padrão não encontrado em ${file/#$HOME/\~})"
    return 0
  fi

  run sed -i -E "0,/$pattern/s//$replacement/" "$file"
  ok "$label"
}
