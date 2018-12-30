-- save and restore window positions when switching monitors

local minimumMoveDistance = 10

local export = {}
local l = {}

local shared = require "shared"

local windowPositions = {}

-- pro tip: use listWindows from console to find correct names
local windowPresetTable = {}
windowPresetTable["iTerm2"] = "internal"
windowPresetTable["Spotify"] = "secondary"
windowPresetTable["IntelliJ IDEA"] = "main"
windowPresetTable["Eclipse"] = "main"
windowPresetTable["Google Chrome"] = "secondary"
windowPresetTable["Slack"] = "secondary"

function export.positionWindowsByPreset()
    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local name = window:application():name()
        local mapping = windowPresetTable[name]
        if mapping then
            -- moveWindowToScreen(window, index)
            local target = l.getScreenByMapping(mapping)
            window:moveToScreen(target)
            -- maximize
            shared.scaleWindow(window, 0, 0, 1, 1)
        end
    end
    export.storeWindowPos()
end

function export.restoreWindowPos()
    local screenCount = #hs.screen.allScreens()

    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local id = window:id()
        if id then -- finder bugs out in el capitan
            local key = screenCount .. "--" .. id
            local frame = windowPositions[key]
            if frame then
                window:setFrame(frame)
            end
        end
    end
end

function export.storeWindowPos()
    local screenCount = #hs.screen.allScreens()

    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local id = window:id()
        if id then -- finder bugs out in el capitan
            local key = screenCount .. "--" .. id
            windowPositions[key] = window:frame()
        end
    end
end

function listWindows()
    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local name = window:application():name()
        log.i(name)
    end
end

function l.getScreenByMapping(mapping)
    -- the internal screen is currently the primary screen
    local internal = hs.screen.primaryScreen()

    local screens = shared.orderedScreens()

    -- the main is the middlemost screen, but not the internal screen unless there is only one window
    local main = internal
    local closestDistance = #screens
    for k,screen in pairs(screens) do
        local midDistance = math.abs(math.ceil(#screens / 2) - k)
        if screen ~= internal and midDistance < closestDistance then
            closestDistance = midDistance
            main = screen
        end
    end

    -- the secondary is the first screen that is left, or internal if there is no such window
    local secondary = internal
    for k,screen in pairs(screens) do
        if screen ~= internal and screen ~= main then
            secondary = screen
        end
    end

    local ret = {["internal"]=internal, ["main"]=main, ["secondary"]=secondary}
    return ret[mapping]
end


return export
