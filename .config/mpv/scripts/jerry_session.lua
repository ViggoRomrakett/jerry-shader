local msg = require("mp.msg")

local function getenv(k)
local v = os.getenv(k)
if v == nil or v == "" then return nil end
    return v
    end

    local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
        local s = f:read("*a")
        f:close()
        if not s then return nil end
            s = s:gsub("^%s+", ""):gsub("%s+$", "")
            if s == "" then return nil end
                return s
                end

                local function split_colon(s)
                local t = {}
                for part in string.gmatch(s, "([^:]+)") do
                    table.insert(t, part)
                    end
                    return t
                    end

                    local function file_exists(path)
                    local f = io.open(path, "r")
                    if f then f:close(); return true end
                        return false
                        end

                        -- Only activate for jerry launches
                        if not getenv("JERRY_SESSION") then return end

                            mp.set_property_native("fullscreen", true)
                            local fs_screen = getenv("JERRY_FS_SCREEN")
                            if fs_screen then mp.set_property("fs-screen", fs_screen) end

                                local cache = getenv("JERRY_GLSL_CACHE") or ((getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jerry-glsl-chain")
                                msg.info("jerry_session watcher active, cache=" .. cache)

                                local last = nil

                                local function apply_chain(chain)
                                mp.commandv("no-osd", "change-list", "glsl-shaders", "clr", "")
                                local parts = split_colon(chain)

                                local ok = 0
                                for i = 1, #parts do
                                    local p = parts[i]
                                    if file_exists(p) then
                                        mp.commandv("no-osd", "change-list", "glsl-shaders", "append", p)
                                        ok = ok + 1
                                        else
                                            msg.warn("Missing shader: " .. p)
                                            end
                                            end

                                            mp.osd_message(("Anime4K shaders: %d/%d"):format(ok, #parts), 1.0)
                                            end

                                            local function tick()
                                            local chain = read_file(cache)

                                            if not chain then
                                                if last ~= nil then
                                                    mp.commandv("no-osd", "change-list", "glsl-shaders", "clr", "")
                                                    mp.osd_message("Anime4K shaders: cleared", 1.0)
                                                    last = nil
                                                    end
                                                    return
                                                    end

                                                    if chain ~= last then
                                                        last = chain
                                                        apply_chain(chain)
                                                        end
                                                        end

                                                        mp.add_timeout(0.2, tick)
                                                        mp.add_periodic_timer(0.25, tick)
