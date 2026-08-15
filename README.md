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
omarchy restart shell
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

## Estrutura

```
install.sh              orquestra tudo
tweaks.sh               ajustes idempotentes em arquivos do Omarchy
lib/common.sh           helpers de log, backup, symlink e substituição de linha
link/                   espelha ~/.config — vira symlink
vscode/                 settings.json + lista de extensões (copiados)
waybar-*.old.*          config e style da waybar pré-Quattro, só para consulta
```

## Como as customizações são aplicadas

São dois mecanismos, escolhidos conforme quem é o dono do arquivo.

### `link/` — arquivos que são inteiramente meus

Espelham a estrutura de `~/.config` e viram **symlink** apontando para o
repositório. O repo é a fonte da verdade: editar o arquivo no sistema já altera
o repo, bastando commitar.

| Arquivo | O que é |
| --- | --- |
| `hypr/workspaces.lua` | Distribuição de workspaces: ímpares no `DP-3`, pares no `HDMI-A-1` |
| `hypr/input.lua` | `kb_layout = "br"` e `sensitivity = -0.75` |
| `hypr/looknfeel.lua` | Gaps 6, `rounding` 6 com `rounding_power` 3, opacidades 1.0/0.9, e as animações `workspaces` e `fadeSwitch` |
| `hypr/monitors.lua` | Layout dos monitores (gerado pelo nwg-displays) |
| `bin/mullvad-vpn.sh` | Script auxiliar do Mullvad |
| `omarchy/shell.json` | Layout da barra: quais widgets, em que seção |
| `omarchy/shell.toml` | Estilo do shell: altura da barra em 32px |
| `omarchy/plugins/spica.lock/` | Lockscreen clonada, com o layout traduzido do antigo `hyprlock.conf` |
| `omarchy/plugins/spica.workspaces/` | Widget de workspaces clonado, exibindo os 10 |
| `omarchy/themes/nico-robin/` | Tema próprio: `colors.toml`, `icons.theme`, `preview.png`, wallpapers |

Três observações sobre por que esses arquivos ficam aqui e não no `tweaks.sh`:

O **`looknfeel.lua`** carrega depois dos overrides do tema, então fixa a
aparência independente do tema em uso. Sem ele, o `rounding` vinha do tema
`solitude` — o único de fábrica que mexe nisso — e voltava a zero em qualquer
outro. As duas animações precisam ser religadas explicitamente porque o default
do Omarchy desliga ambas.

Os **plugins clonados** existem porque o valor não é configurável: o
`Workspaces.qml` de fábrica fixa `[1,2,3,4,5]` em código, e a lockscreen só
expõe 6 cores. Clonar é o caminho suportado — `omarchy plugin clone <id>` copia
o diretório para `~/.config/omarchy/plugins/<usuário>.<id>/` e a cópia sobrevive
a updates. O id fica fixo no `manifest.json`, então funciona em qualquer máquina.

Um **tema** no Quattro é essencialmente o `colors.toml`. A partir dele o
`omarchy-theme-set-templates` gera ~17 arquivos por aplicativo (alacritty, foot,
kitty, btop, neovim, hyprland, obsidian…) em
`~/.local/state/omarchy/current/theme/`. Guardar arquivos por aplicativo dentro
do tema é formato pré-Quattro e não tem efeito.

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
lista de extensões, instalada sob demanda com `--vscode-extensions`.

Para atualizar o repo depois de mexer nas configurações do VS Code:

```bash
cp ~/.config/Code/User/settings.json vscode/settings.json
code --list-extensions | grep -v '^local\.' | sort > vscode/extensions.txt
```

O `grep` descarta extensões geradas na máquina — o `omarchy-theme-set-vscode`
cria uma `local.omarchy-theme` a cada troca de tema, e ela não existe no
marketplace. O `install.sh` também as ignora ao instalar.

## O que deliberadamente não está aqui

Foram avaliados e ficaram de fora por serem cópias de defaults antigos ou estado
de runtime:

- `tmux/tmux.conf` e `kitty/kitty.conf` — divergem do padrão atual, mas apenas
  porque são versões anteriores dele, sem ajuste próprio. O `tmux.conf` local é
  o default de antes das descrições `-N`, e por isso não tem o atalho `?` que
  abre o popup de keybindings.
- `chromium/Default/Preferences` — estado do navegador, não configuração
- Temas antigos (`frieren-light`, `seraphina`) — seguiam o formato pré-Quattro,
  em que cada aplicativo tinha seu arquivo

Se um desses divergir de verdade no futuro, o caminho é adicioná-lo ao
`tweaks.sh` como ajuste pontual — não copiar o arquivo inteiro para `link/`.

## Manutenção

### Depois de um `omarchy update`

```bash
./install.sh --check     # relata
./install.sh             # reaplica
```

### Symlinks podem ser substituídos

Alguns arquivos do `link/` são reescritos por programas que gravam de forma
atômica (arquivo temporário + rename). Quando isso acontece, o symlink vira
arquivo comum e o repositório para de receber as mudanças:

| Arquivo | Quem reescreve |
| --- | --- |
| `omarchy/shell.json` | `omarchy bar move/put/set` |
| `omarchy/shell.toml` | `omarchy display text size` |
| `hypr/monitors.lua` | nwg-displays |

O `./install.sh --check` reporta esses casos como `arquivo comum — o symlink foi
substituído`; um `./install.sh` restabelece.

### Reiniciar o shell depois de criar symlinks novos

Plugins do tipo `service` são instanciados na inicialização do shell e não são
trocados a quente. Além disso, o watcher do Quickshell perde o arquivo quando um
arquivo comum é substituído por symlink. Depois de um `./install.sh` que criou
links novos sob `omarchy/plugins/`, rode:

```bash
omarchy restart shell
```

### Procurar customizações ainda não versionadas

```bash
cd /usr/share/omarchy/config
find . -type f | sed 's|^\./||' | while read -r f; do
  diff -q "$f" ~/.config/"$f" >/dev/null 2>&1 || echo "difere: $f"
done
```

Duas ressalvas. Nem toda diferença é customização — verifique se o arquivo não é
apenas um default antigo que ficou para trás, como aconteceu com o `tmux.conf` e
o `kitty.conf`. E a comparação só cobre arquivos que o pacote distribui: coisas
como `hypr/workspaces.lua`, `xdg-terminals.list` e `omarchy/shell.toml` não têm
contraparte no default e nunca aparecem nessa lista.
