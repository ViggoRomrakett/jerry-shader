-- ~/.config/mpv/scripts/jerry_progress_dump.lua
-- Robust progress dump for jerry:
-- - caches time-pos & duration while playing
-- - writes on end-file even if mpv clears properties
-- - writes reason so jerry can distinguish EOF vs quit

local msg = require("mp.msg")

local function getenv(k)
  local v = os.getenv(k)
  if v == nil or v == "" then return nil end
  return v
end

if not getenv("JERRY_SESSION") then return end

local path = getenv("JERRY_PROGRESS_FILE")
if not path then
  local rt = getenv("XDG_RUNTIME_DIR") or "/tmp"
  local uid = getenv("UID") or "0"
  path = rt .. "/jerry-mpv-progress-" .. uid
end

local last_tpos = nil
local last_dur  = nil

local function hhmmss(sec)
  sec = math.floor(sec + 0.5)
  local h = math.floor(sec / 3600)
  local m = math.floor((sec % 3600) / 60)
  local s = sec % 60
  return string.format("%02d:%02d:%02d", h, m, s)
end

-- Cache time-pos continuously
mp.observe_property("time-pos", "number", function(_, v)
  if v and v >= 0 then last_tpos = v end
end)

mp.observe_property("duration", "number", function(_, v)
  if v and v > 0 then last_dur = v end
end)

local function write_progress(ev)
  -- Use cached values (properties may be cleared at end-file)
  if not last_tpos or last_tpos < 0 then
    msg.warn("time-pos unavailable (cached); not writing progress")
    return
  end

  local reason = (ev and ev.reason) and tostring(ev.reason) or "unknown"

  local pct = -1
  if last_dur and last_dur > 0 then
    pct = (last_tpos / last_dur) * 100.0
  end
  if not pct or pct < 0 then pct = 0 end

  local f = io.open(path, "w")
  if not f then
    msg.warn("Could not write progress file: " .. path)
    return
  end

  -- Format: REASON PERCENT HH:MM:SS
  f:write(string.format("%s %d %s\n", reason, math.floor(pct + 0.5), hhmmss(last_tpos)))
  f:close()

  msg.info("Wrote progress: " .. path .. " (" .. reason .. ")")
end

mp.register_event("end-file", write_progress)
