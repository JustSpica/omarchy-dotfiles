#!/usr/bin/env bash
# Instala as customizações deste repositório sobre um Omarchy Quattro limpo.
#
#   ./install.sh                    enlaça os arquivos e aplica os ajustes
#   ./install.sh --dry-run          mostra o que faria, sem tocar em nada
#   ./install.sh --check            só relata o estado atual
#   ./install.sh --vscode-extensions  instala também as extensões do VS Code

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_ROOT/lib/common.sh"

WITH_VSCODE_EXTENSIONS=0
CHECK_ONLY=0

usage() {
  sed -n '2,8p' "$0" | sed 's/^# \?//'
  exit "${1:-0}"
}

while (($#)); do
  case $1 in
  --dry-run) DRY_RUN=1 ;;
  --check) CHECK_ONLY=1; DRY_RUN=1 ;;
  --vscode-extensions) WITH_VSCODE_EXTENSIONS=1 ;;
  -h | --help) usage 0 ;;
  *) err "opção desconhecida: $1"; usage 1 ;;
  esac
  shift
done

# --- verificações -----------------------------------------------------------

section "Ambiente"

if command -v omarchy >/dev/null; then
  ok "Omarchy $(omarchy version 2>/dev/null || echo '?')"
else
  warn "comando omarchy não encontrado — os ajustes do Omarchy serão pulados"
fi

((DRY_RUN)) && warn "modo dry-run: nenhuma alteração será gravada"

# --- estado atual -----------------------------------------------------------

if ((CHECK_ONLY)); then
  section "Symlinks"
  while IFS= read -r rel; do
    dst="$CONFIG_HOME/$rel"
    src="$REPO_ROOT/link/$rel"
    if [[ ! -e $dst ]]; then
      warn "$rel (ausente)"
    elif [[ -L $dst && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
      ok "$rel"
    elif [[ -L $dst ]]; then
      err "$rel (aponta para outro lugar: $(readlink "$dst"))"
    else
      err "$rel (arquivo comum — o symlink foi substituído)"
    fi
  done < <(cd "$REPO_ROOT/link" && find . -type f | sed 's|^\./||' | sort)

  section "Ajustes"
  "$REPO_ROOT/tweaks.sh"
  exit 0
fi

# --- symlinks ---------------------------------------------------------------

section "Symlinks"

while IFS= read -r rel; do
  link_file "$rel"
done < <(cd "$REPO_ROOT/link" && find . -type f | sed 's|^\./||' | sort)

# --- ajustes em arquivos do Omarchy ----------------------------------------

DRY_RUN=$DRY_RUN "$REPO_ROOT/tweaks.sh"

# --- VS Code ----------------------------------------------------------------

section "VS Code"

vscode_user="$CONFIG_HOME/Code/User"
if [[ -d $(dirname "$vscode_user") ]]; then
  if [[ -f "$vscode_user/settings.json" ]] &&
    cmp -s "$REPO_ROOT/vscode/settings.json" "$vscode_user/settings.json"; then
    skip "settings.json (já sincronizado)"
  else
    backup "$vscode_user/settings.json"
    run mkdir -p "$vscode_user"
    run cp "$REPO_ROOT/vscode/settings.json" "$vscode_user/settings.json"
    ok "settings.json"
  fi
else
  skip "VS Code não instalado"
fi

if ((WITH_VSCODE_EXTENSIONS)); then
  if command -v code >/dev/null; then
    installed=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort)
    while IFS= read -r ext; do
      [[ -n $ext ]] || continue
      # local.* são extensões geradas na máquina (o omarchy-theme-set-vscode
      # cria local.omarchy-theme). Não existem no marketplace.
      [[ $ext == local.* ]] && continue
      if grep -qxF "${ext,,}" <<<"$installed"; then
        skip "$ext"
      else
        run code --install-extension "$ext" --force >/dev/null && ok "$ext"
      fi
    done <"$REPO_ROOT/vscode/extensions.txt"
  else
    warn "comando 'code' não encontrado"
  fi
else
  skip "extensões (use --vscode-extensions)"
fi

# --- final ------------------------------------------------------------------

section "Pronto"

if ((DRY_RUN)); then
  ok "nada foi alterado (dry-run)"
else
  [[ -d $BACKUP_DIR ]] && warn "backups em ${BACKUP_DIR/#$HOME/\~}"
  ok "recarregue o Hyprland com: hyprctl reload"
fi
