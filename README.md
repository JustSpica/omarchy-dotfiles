# Omarchy 3.x.x iles

This repository stores the configuration files and helper scripts I use with **Omarchy 3.x.x**. The structure is organized by component (Hyprland, Waybar, shell, utilities) so it is easier to maintain and reuse.

---

## Directory Overview

| Directory | Purpose | Key Files |
| --- | --- | --- |
| `bash/` | Personal shell helpers and local environment setup. | `functions/` reusable shell functions |
| `bin/` | Executable scripts used by Waybar and Hyprland modules. | `mullvad-vpn.sh`, `spotify-module.py`, `weather-module.sh`, `temperature-info-module.sh`, `volume-info-module.sh`, `omarchy-move-to.sh`, `omarchy-toggle-layout.sh`, `omarchy-sync-spotify-theme.sh`. |
| `btop/` | btop configuration and theme files. | `btop.conf`, `themes/current.theme`. |
| `hypr/` | Main Hyprland configuration. | `hyprland.conf`, `bindings.conf`, `autostart.conf`, `envs.conf`, `hypridle.conf`, `hyprlock.conf`, `looknfeel.conf`, `monitors.conf`, `workspaces.conf`, `xdph.conf`, `shaders/`. |
| `waybar/` | Waybar layout and styles. | `config.jsonc`, `style.css` (modules now call scripts from `bin/`). |
| `sgpt/` | sgpt assistant settings and personas. | `config.yaml`, `personas/`. |
| `zathura/` | Zathura PDF viewer config. | `zathurarc`. |

_This repository is intended for personal use with Omarchy 3.x.x.  Adjust paths and settings as needed for your own environment._
