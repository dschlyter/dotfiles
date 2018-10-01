-- pin windows to current screen

local export = {}
local l = {}

local windowSpawnRules = {}

function export.pinFocused()
    -- TODO use shared.findFocused

    local f = hs.window.focusedWindow()
    local a = hs.window.focusedWindow():application():name()
    local s = f:screen():id()

    if not windowSpawnRules[a] then
        hs.alert.show(a .. " pinned to screen")
        windowSpawnRules[a] = s
    else
        hs.alert.show("pin removed for " .. a)
        windowSpawnRules[a] = nil
    end
end

hs.window.filter.default:subscribe(hs.window.filter.windowCreated, function (w, appName) 
    if windowSpawnRules[appName] then
        local s = hs.screen.find(windowSpawnRules[appName])
        w:moveToScreen(s)
    end
end)

return export
