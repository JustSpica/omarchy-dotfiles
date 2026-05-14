# Omarchy 3.x.x Files

This repository stores my personal dotfiles and helper scripts for **Omarchy 3.x.x**. The layout is organized by component (Hyprland, Waybar, Omarchy assets, Spicetify, VS Code, and helper scripts) to keep updates simple and reproducible.

Installation targets and merge/replace rules are documented in `SCRIPT-GUIDE.md` and automated by `install.sh`.

## Directory overview

| Directory | Purpose | Key files |
| --- | --- | --- |
| `bin/` | Executable scripts used by Waybar/Hyprland and Omarchy workflows. | `mullvad-vpn.sh`, `spotify-module.py`, `weather-module.sh`, `temperature-info-module.sh`, `volume-info-module.sh`, `omarchy-move-to.sh`, `omarchy-sync-spicetify.sh` |
| `hypr/` | Main Hyprland configuration split by concern. | `hyprland.conf`, `bindings.conf`, `autostart.conf`, `envs.conf`, `input.conf`, `looknfeel.conf`, `monitors.conf`, `workspaces.conf`, `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf` |
| `omarchy/` | Omarchy backgrounds and hooks. | `backgrounds/`, `hooks/` |
| `spicetify/` | Spicetify configuration and theme packs. | `config-xpui.ini`, `Themes/omarchy-sync/color.ini` |
| `waybar/` | Waybar layout and CSS style. | `config.jsonc`, `style.css` |
| `vscode/` | VS Code settings and extension list. | `settings.json`, `extensions.txt` |

_This repository is intended for personal use with Omarchy 3.x.x. Adjust paths and settings as needed for your own environment._
