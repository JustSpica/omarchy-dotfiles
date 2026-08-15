# omarchy-dotfiles

Customizações pessoais sobre o **Omarchy Quattro (4.x)**.

O repositório guarda apenas o que difere do padrão do Omarchy. Tudo que é igual
ao default fica de fora de propósito: versionar a cópia completa de um arquivo
do Omarchy congela aquela versão e impede que melhorias das próximas releases
cheguem até você.

## Instalação

Em um Omarchy Quattro recém-instalado:

```bash
git clone git@github.com:JustSpica/omarchy-dotfiles.git ~/omarchy-dotfiles
cd ~/omarchy-dotfiles
./install.sh
hyprctl reload
```

| Comando | O que faz |
| --- | --- |
| `./install.sh` | Enlaça os arquivos e aplica os ajustes |
| `./install.sh --dry-run` | Mostra o que faria, sem gravar nada |
| `./install.sh --check` | Relata o estado atual (symlinks e ajustes) |
| `./install.sh --vscode-extensions` | Instala também as extensões do VS Code |

O script é idempotente: rodar de novo não duplica nada e informa o que já está
aplicado. Antes de substituir qualquer arquivo existente, guarda uma cópia em
`~/.config/.dotfiles-backup/<timestamp>/`.

## Como as customizações são aplicadas

São dois mecanismos, escolhidos conforme quem é o dono do arquivo.

### `link/` — arquivos que são inteiramente meus

Espelham a estrutura de `~/.config` e viram **symlink** apontando para o
repositório. O repo é a fonte da verdade: editar o arquivo no sistema já altera
o repo, bastando commitar.

| Arquivo | O que é |
| --- | --- |
| `hypr/workspaces.lua` | Distribuição de workspaces: ímpares no `DP-3`, pares no `HDMI-A-1` |
| `hypr/looknfeel.lua` | `gaps_in`/`gaps_out` 6 e `rounding` 6 |
| `hypr/monitors.lua` | Layout dos monitores (gerado pelo nwg-displays) |
| `bin/mullvad-vpn.sh` | Script auxiliar do Mullvad |
| `omarchy/shell.json` | Layout da barra |
| `omarchy/plugins/spica.*/` | Plugins clonados do shell (lock, workspaces) |
| `omarchy/themes/nico-robin/` | Tema próprio: `colors.toml`, `icons.theme`, wallpapers |

Um tema no Quattro é essencialmente o `colors.toml`. A partir dele o
`omarchy-theme-set-templates` gera ~17 arquivos por aplicativo (alacritty, foot,
kitty, btop, neovim, hyprland, obsidian…) em `~/.local/state/omarchy/current/theme/`.
Guardar arquivos por aplicativo dentro do tema é formato pré-Quattro e não tem efeito.

O `looknfeel.lua` carrega depois dos overrides do tema, então fixa a aparência
independente do tema em uso. Sem ele, o `rounding` vinha do tema `solitude` — o
único de fábrica que mexe nisso — e voltava a zero em qualquer outro.

### `tweaks.sh` — ajustes em arquivos do Omarchy

Arquivos que o Omarchy instala e continua atualizando. Aqui o repositório guarda
só o **valor desejado**, reaplicado por cima do arquivo atual. Assim o Omarchy
segue melhorando o resto do arquivo.

| Alvo | Ajuste |
| --- | --- |
| `hypr/hyprland.lua` | Acrescenta `require("hypr.workspaces")` ao loader |
| `xdg-terminals.list` | Alacritty como terminal padrão (via `omarchy default terminal`) |
| `mimeapps.list` | Chrome como navegador padrão (via `omarchy default browser`) |
| `alacritty/alacritty.toml` | Fonte tamanho 11 |
| `git/config` | Nome e e-mail |
| `btop/btop.conf` | `update_ms = 100` |
| `obsidian/user-flags.conf` | Comenta `-disable-gpu` (mantém a GPU ligada) |
| `opencode/opencode.json` | Remove `theme`, para seguir o tema do terminal |

Para mudar um valor, edite a constante no topo do `tweaks.sh` e rode
`./install.sh` de novo.

### `vscode/`

`settings.json` é **copiado** (o VS Code reescreve o arquivo ao mexer nas
preferências pela interface, o que quebraria um symlink). `extensions.txt` é a
lista de extensões, instalada sob demanda.

Para atualizar o repo depois de mexer nas configurações do VS Code:

```bash
cp ~/.config/Code/User/settings.json vscode/settings.json
code --list-extensions | grep -v '^local\.' | sort > vscode/extensions.txt
```

O `grep` descarta extensões geradas na máquina — o `omarchy-theme-set-vscode`
cria uma `local.omarchy-theme` a cada troca de tema, e ela não existe no
marketplace. O `install.sh` também as ignora ao instalar.

## O que deliberadamente não está aqui

Foram avaliados e ficaram de fora por já serem idênticos ao padrão do Quattro,
ou por serem estado de runtime:

- `omarchy/shell.json` — semanticamente idêntico ao default (só a ordem das chaves difere)
- `tmux/tmux.conf` e `kitty/kitty.conf` — cópias de defaults antigos, sem ajuste próprio
- `chromium/Default/Preferences` — estado do navegador, não configuração
- Temas customizados — os antigos (`frieren-light`, `seraphina`) seguiam o formato
  pré-Quattro, em que cada aplicativo tinha seu arquivo. No Quattro quase tudo é
  gerado a partir do `colors.toml`.

Se um desses divergir de verdade no futuro, o caminho é adicioná-lo ao
`tweaks.sh` como ajuste pontual — não copiar o arquivo inteiro para `link/`.

## Manutenção

Depois de um `omarchy update`, vale conferir se algum ajuste foi sobrescrito:

```bash
./install.sh --check     # relata
./install.sh             # reaplica
```

Para descobrir se surgiu alguma customização nova ainda não versionada, compare
sua `~/.config` com os defaults que o pacote distribui:

```bash
cd /usr/share/omarchy/config
find . -type f | sed 's|^\./||' | while read -r f; do
  diff -q "$f" ~/.config/"$f" >/dev/null 2>&1 || echo "difere: $f"
done
```

Atenção ao resultado: nem toda diferença é customização. Verifique se o arquivo
não é apenas um default antigo que ficou para trás — foi o caso do `tmux.conf`
e do `kitty.conf` aqui.
