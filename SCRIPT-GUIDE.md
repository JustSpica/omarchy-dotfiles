# Script Guide

Este repositorio guarda minhas configuracoes do Arch + Omarchy.

Este guia define:

- onde cada pasta ou arquivo deste repositorio deve ser colocado no sistema;
- o que fazer quando o destino ja existir;
- qual versao deve prevalecer em caso de conflito.

## Regra de prevalencia

Use estas regras sempre que houver algo ja existente no sistema:

1. `Substituir`: remover ou sobrescrever o item atual e usar a versao deste repositorio.
2. `Mesclar`: juntar com o item ja existente, mas manter os arquivos deste repositorio quando houver conflito.

## Itens que vao para `~/.config`

Todos os itens abaixo devem ser colocados dentro de `~/.config`.

| Origem no repositorio | Destino no sistema | Se ja existir | Prevalencia |
| --- | --- | --- | --- |
| `bash/` | `~/.config/bash/` | Substituir a pasta | Este repositorio |
| `bin/` | `~/.config/bin/` | Substituir a pasta | Este repositorio |
| `btop/` | `~/.config/btop/` | Mesclar a pasta | Este repositorio |
| `hypr/` | `~/.config/hypr/` | Mesclar a pasta | Este repositorio |
| `omarchy/` | `~/.config/omarchy/` | Substituir a pasta | Este repositorio |
| `sgpt/` | `~/.config/sgpt/` | Substituir a pasta | Este repositorio |
| `spicetify/` | `~/.config/spicetify/` | Substituir a pasta | Este repositorio |
| `waybar/` | `~/.config/waybar/` | Substituir a pasta | Este repositorio |
| `zathura/` | `~/.config/zathura/` | Substituir a pasta | Este repositorio |

## Itens com destino especifico

### VS Code

- `vscode/settings.json` deve ser copiado para `~/.config/Code/User/settings.json`.
- Se esse arquivo ja existir, ele deve ser substituido pela versao deste repositorio.
- `vscode/extensions.txt` contem a lista das extensões utilizadas.

Para instalar as extensões listadas:

```bash
cat vscode/extensions.txt | xargs -L 1 code --install-extension
```
