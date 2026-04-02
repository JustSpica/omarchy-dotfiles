# Omarchy 3.x.x Files

This repository stores my personal dotfiles and helper scripts for **Omarchy 3.x.x**. The layout is organized by component (Hyprland, Waybar, Omarchy assets, terminal/tools) to keep updates simple and reproducible.

## Directory overview

| Directory | Purpose | Key files |
| --- | --- | --- |
| `bash/` | Personal shell helpers and local environment setup. | `functions` |
| `bin/` | Executable scripts used by Waybar/Hyprland and Omarchy workflows. | `mullvad-vpn.sh`, `spotify-module.py`, `weather-module.sh`, `temperature-info-module.sh`, `volume-info-module.sh`, `omarchy-move-to.sh`, `omarchy-toggle-layout.sh`, `omarchy-sync-spotify-theme.sh` |
| `btop/` | btop configuration and local themes. | `btop.conf`, `themes/` |
| `hypr/` | Main Hyprland configuration split by concern. | `hyprland.conf`, `bindings.conf`, `autostart.conf`, `envs.conf`, `input.conf`, `looknfeel.conf`, `monitors.conf`, `workspaces.conf`, `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf`, `shaders/`, `avatars/` |
| `omarchy/` | Omarchy branding/assets and current theme state. | `backgrounds/`, `branding/`, `current/theme/`, `current/theme.name`, `hooks/`, `extensions/menu.sh`, `themed/`, `themes/` |
| `spicetify/` | Spicetify configuration and theme packs. | `config-xpui.ini`, `Themes/omarchy-sync/color.ini` |
| `sgpt/` | sgpt assistant settings. | `config.yaml` |
| `waybar/` | Waybar layout and CSS style. | `config.jsonc`, `style.css` |
| `zathura/` | Zathura PDF viewer config. | `zathurarc` |

_This repository is intended for personal use with Omarchy 3.x.x. Adjust paths and settings as needed for your own environment._
