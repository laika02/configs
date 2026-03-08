# Theme Portability Requirements

## Goal
Make this dotfiles set copyable to a fresh install while preserving your current visual theme.

## Required Runtime Packages
- `hyprland`
- `hyprpaper`
- `waybar`
- `wofi`
- `mako`
- `kitty`
- `fish`
- `micro`
- `python-pywal` (`wal`)
- `wl-clipboard` (`wl-copy`)
- `grim`
- `slurp`
- `wireplumber`/`pipewire` (`wpctl`)
- `brightnessctl`
- `network-manager-applet` (`nm-applet`)
- `polkit-gnome` auth agent (path is distro-specific)
- `curl` and `python3` (for `waybar/scripts/xmr_price.sh`)
- `pavucontrol` (Waybar pulseaudio click action)
- `nnn` (bound in Hyprland config)

## Required Fonts
- `Noto Sans` (explicitly set in Waybar/Wofi/Mako CSS/config)
- A symbol/icon font for Waybar glyphs (`󰤢`, ``, ``), such as a Nerd Font symbols package and/or Font Awesome

## Required Files And Paths
- Copy these directories into `~/.config`: `hypr`, `waybar`, `wofi`, `kitty`, `mako`, `micro`, `fish`.
- Wallpapers are expected at:
  - `~/Pictures/Wallpapers/wallpaper.jpg`
  - `~/Pictures/Wallpapers/wallpaper2.jpg`
- Theme files are loaded from:
  - `~/.config/wal/colors-kitty.conf`
  - `~/.config/wal/colors-waybar.css`
  - `~/.config/wal/colors-mako`

## First-Run Setup
1. Run the installer from this folder:
   - `./install.sh`
2. Start/restart Hyprland, Waybar, Mako, Wofi, and Kitty.
