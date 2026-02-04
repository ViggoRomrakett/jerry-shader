# jerry-shader

A patched and extended version of **jerry**, adding:
- Reliable autoplay
- Shader chaining via mpv
- Multi-monitor fullscreen selection
- Discord Rich Presence improvements

Usage:
  jerry-shader [options] -- [jerry args/query...]
  jerry-shader [options] [jerry args/query...]

Options (wrapper):
  --no-shader-menu     Skip shader picker (keep "No shader")
  --screen X           Force fullscreen to fs-screen X (mpv option. Numbers from 0-32 are allowed.)
  --pick-screen        Pick screen interactively (Hyprland monitors if available)
  --clear-screen       Unset forced screen (uses mpv default behavior)

Provider shortcuts (optional):
  --cr                 crunchyroll (to be implemented)
  --allanime           allanime
  --aniwatch           aniwatch
  --yugen              yugen
  --hdrezka            hdrezka

Menu shortcut:
  --rofi               Add --rofi to jerry (external menu is enabled by default)

Examples:
```  
  jerry-shader --screen 0
  jerry-shader Keijo
  jerry-shader --screen 1 --rofi --allanime Frieren
```
  

IMPORTANT:
  For the shader picker to work, this exact command must be added to `~/.config/mpv/input.conf`:
```
  s no-osd set pause yes; run /usr/bin/kitty --class mpv-shader-picker --title Shader-Picker sh -lc     "$HOME/bin/jerry-preset"; no-osd set pause no
```

⚠️ This is a personal patchset. Expect rough edges.


Installation:

```
git clone https://github.com/ViggoRomrakett/jerry-shader
cd jerry-shader
chmod +x install.sh
./install.sh
```
