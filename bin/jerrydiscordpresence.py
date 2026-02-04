#!/usr/bin/env python3
import os
import re
import sys
import time
import signal
import subprocess

import httpx
from pypresence import Presence

CLIENT_ID = "1467607048433700979"
ENDPOINT = "https://kitsu.io/api/"


def guess_position_file(uid: str) -> str:
    # 1) Explicit override (best)
    env = os.environ.get("JERRY_POSITION_FILE")
    if env:
        return env

    # 2) Your patched mpv progress dump file(s)
    xr = os.environ.get("XDG_RUNTIME_DIR")
    if xr:
        cand = os.path.join(xr, f"jerry-mpv-progress-{uid}")
        # some of your earlier logs used this name
        cand2 = os.path.join(xr, f"jerry-mpv-progress-{uid}.txt")
        for c in (cand, cand2):
            if os.path.exists(c):
                return c

    # 3) Jerry’s older default temp file
    return "/tmp/jerry_position"


def safe_kitsu_lookup(http_client: httpx.Client, anime_name: str, release_year: str):
    # If this fails, we still want presence to work.
    try:
        resp = http_client.get(
            "edge/anime",
            params={
                "filter[text]": anime_name,
                "filter[year]": f"{release_year}..{release_year}",
            },
            timeout=8.0,
        )
        data = resp.json().get("data", [])
        if not data:
            return None
        return data[0].get("attributes", None)
    except Exception:
        return None


def parse_mpv_av_line(text: str):
    """
    Your old regex looked for:
      (Paused) AV: 00:01:23 / 00:24:38 (5%)
    Works on mpv terminal output.
    """
    pattern = r"(\(Paused\)\s)?AV:\s([0-9:]*)\s/\s([0-9:]*)\s\(([0-9]*)%\)"
    matches = re.findall(pattern, text)
    if not matches:
        return None
    paused_flag, elapsed, duration, percent = matches[-1]
    paused = bool(paused_flag)
    return paused, elapsed, duration, percent


def main():
    # jerry passes:
    # 0 script
    # 1 mpv_executable
    # 2 anime_name
    # 3 release_year
    # 4 episode_count
    # 5 content_stream
    # 6 subtitle_stream
    # 7.. opts
    if len(sys.argv) < 7:
        raise SystemExit("Not enough args")

    (
        _script,
        mpv_executable,
        anime_name,
        release_year,
        episode_count,
        content_stream,
        subtitle_stream,
        *opts,
    ) = sys.argv

    uid = str(os.getuid())
    position_file = guess_position_file(uid)

    rpc = Presence(CLIENT_ID)
    rpc.connect()

    http_client = httpx.Client(base_url=ENDPOINT)

    media = safe_kitsu_lookup(http_client, anime_name, release_year)

    # Build titles + poster
    if media:
        canonical = media.get("canonicalTitle") or anime_name
        poster = (media.get("posterImage") or {}).get("original", "")
    else:
        canonical = anime_name
        poster = ""

    media_title = f"{canonical} - Episode {episode_count}"

    # Build mpv args
    args = [
        mpv_executable,
        content_stream,
        f"--force-media-title={media_title}",
        "--msg-level=ffmpeg/demuxer=error",
    ] + opts

    if subtitle_stream != "":
        # NOTE: mpv option is usually --sub-files (okay), but you might prefer --sub-file
        args.insert(3, f"--sub-files={subtitle_stream}")

    proc = subprocess.Popen(args)

    # Ensure we always clear presence
    def cleanup():
        try:
            rpc.clear()
        except Exception:
            pass
        try:
            rpc.close()
        except Exception:
            pass

    def on_signal(signum, frame):
        cleanup()
        raise SystemExit(128 + signum)

    signal.signal(signal.SIGINT, on_signal)
    signal.signal(signal.SIGTERM, on_signal)

    small_image = "https://images-ext-1.discordapp.net/external/dUSRf56flwFeOMFjafsUhIMMS_1Xs-ptjeDHo6TWn6c/%3Fquality%3Dlossless%26size%3D48/https/cdn.discordapp.com/emojis/1138835294506975262.png"

    last_state = None

    try:
        while True:
            # Stop when mpv ends
            if proc.poll() is not None:
                break

            # Read position/progress
            position = "00:00:00"
            paused = False

            try:
                with open(position_file, "r", errors="ignore") as f:
                    txt = f.read()
                parsed = parse_mpv_av_line(txt)
                if parsed:
                    paused, elapsed, duration, _percent = parsed
                    position = f"{elapsed} / {duration}"
                else:
                    # fallback: if your *new* progress dumper writes "reason percent stopped_at"
                    # keep something non-empty
                    pass
            except Exception:
                # file may not exist yet; that's fine
                pass

            state = f"{'Paused — ' if paused else ''}{position}"

            # Avoid spamming Discord if nothing changed
            if state != last_state:
                rpc.update(
                    details=f"{canonical}",
                    state=f"Episode {episode_count} • {state}",
                    large_image=poster if poster else None,
                    large_text=canonical,
                    small_image=small_image,
                    small_text=f"Episode {episode_count}",
                )

                last_state = state

            time.sleep(2.0)

    finally:
        # Always clear so it doesn't stick after closing jerry/mpv
        cleanup()
        try:
            proc.wait(timeout=2.0)
        except Exception:
            pass


if __name__ == "__main__":
    main()
