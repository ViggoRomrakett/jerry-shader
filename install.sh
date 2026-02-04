#!/usr/bin/env bash
set -euo pipefail

echo "== Jerry Shader Setup Installer =="

# Where to install
HOME_BIN="$HOME/bin"
CONFIG_DIR="$HOME/.config"

# Files
echo "[*] Installing scripts into $HOME_BIN…"
mkdir -p "$HOME_BIN"

install -m755 bin/jerry-shader         "$HOME_BIN/jerry-shader"
install -m755 bin/jerry-patched        "$HOME_BIN/jerry-patched"
install -m755 bin/jerrydiscordpresence.py "$HOME_BIN/jerrydiscordpresence.py"

echo "[*] Installing mpv scripts…"
mkdir -p "$CONFIG_DIR/mpv/scripts"

install -m644 .config/mpv/scripts/jerry_session.lua \
  "$CONFIG_DIR/mpv/scripts/jerry_session.lua"

install -m644 .config/mpv/scripts/jerry_progress_dump.lua \
  "$CONFIG_DIR/mpv/scripts/jerry_progress_dump.lua"

echo "[*] Installing Anime4K shaders…"
mkdir -p "$CONFIG_DIR/mpv/shaders"

cp -n .config/mpv/shaders/*.glsl \
  "$CONFIG_DIR/mpv/shaders/"

echo "[*] Installing rofi themes…"
mkdir -p "$CONFIG_DIR/rofi/themes"

install -m644 .config/rofi/themes/jerry-cards.rasi \
  "$CONFIG_DIR/rofi/themes/jerry-cards.rasi"

install -m644 .config/rofi/jerry.rasi \
  "$CONFIG_DIR/rofi/jerry.rasi"

echo "[*] Installing jerry config…"
mkdir -p "$CONFIG_DIR/jerry"

install -m644 .config/jerry/jerry.conf \
  "$CONFIG_DIR/jerry/jerry.conf"

echo
echo "✅ Done!"
echo "Make sure ~/bin is in your PATH:"
echo "  export PATH=\"\$HOME/bin:\$PATH\""
echo
echo "Run:"
echo "  jerry-shader"
