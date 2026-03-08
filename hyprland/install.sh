#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
PICTURES_HOME="${XDG_PICTURES_DIR:-$HOME/Pictures}"
WALLPAPER_DIR="$PICTURES_HOME/Wallpapers"
CACHE_WAL_DIR="$HOME/.cache/wal"

log() {
  printf '[install] %s\n' "$*"
}

copy_tree() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  cp -a "$src/." "$dst/"
}

install_config_dir() {
  local name="$1"
  local src="$SCRIPT_DIR/$name"
  local dst="$CONFIG_HOME/$name"

  if [[ ! -d "$src" ]]; then
    return 0
  fi

  copy_tree "$src" "$dst"
  log "Synced $dst"
}

main() {
  log "Using dotfiles source: $SCRIPT_DIR"
  log "Using config destination: $CONFIG_HOME"

  install_config_dir "fish"
  install_config_dir "hypr"
  install_config_dir "kitty"
  install_config_dir "mako"
  install_config_dir "micro"
  install_config_dir "waybar"
  install_config_dir "wofi"
  install_config_dir "wal"

  if [[ -f "$CONFIG_HOME/hypr/hyprpaper.conf" ]]; then
    # Hyprpaper expects real paths; normalize any leading ~/ to $HOME.
    sed -i "s#path = ~/#path = $HOME/#g" "$CONFIG_HOME/hypr/hyprpaper.conf"
  fi

  if [[ -d "$SCRIPT_DIR/wallpapers" ]]; then
    copy_tree "$SCRIPT_DIR/wallpapers" "$WALLPAPER_DIR"
    log "Synced wallpapers to $WALLPAPER_DIR"
  fi

  if [[ -f "$CONFIG_HOME/waybar/scripts/xmr_price.sh" ]]; then
    chmod +x "$CONFIG_HOME/waybar/scripts/xmr_price.sh"
    log "Ensured executable: $CONFIG_HOME/waybar/scripts/xmr_price.sh"
  fi

  if command -v wal >/dev/null 2>&1 && [[ -f "$WALLPAPER_DIR/wallpaper.jpg" ]]; then
    log "Generating wal palette from $WALLPAPER_DIR/wallpaper.jpg"
    wal -i "$WALLPAPER_DIR/wallpaper.jpg" >/dev/null

    if [[ -d "$CACHE_WAL_DIR" ]]; then
      copy_tree "$CACHE_WAL_DIR" "$CONFIG_HOME/wal"
      log "Updated $CONFIG_HOME/wal from generated wal cache"
    fi
  else
    log "Skipping wal generation (install python-pywal and ensure wallpaper.jpg exists)."
    log "Using bundled palette from $CONFIG_HOME/wal"
  fi

  log "Done. Reload Hyprland/Waybar/Mako/Kitty to apply."
}

main "$@"
