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
  --cr                 crunchyroll
  --allanime           allanime
  --aniwatch           aniwatch
  --yugen              yugen
  --hdrezka            hdrezka

Menu shortcut:
  --rofi               Add --rofi to jerry (external menu is enabled by default)

Examples:
  jerry-shader --rofi -i "Keijo"
  jerry-shader --screen 1 --rofi -i -w allanime "Frieren"
  jerry-shader --pick-screen --cr --rofi -i "test"


⚠️ This is a personal patchset. Expect rough edges.
