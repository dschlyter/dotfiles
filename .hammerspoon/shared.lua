-- shared code for multiple modules, mostly more high level hammerspoon things

local export = {}
local l = {}

function export.findFocused(func)
    local window = hs.window.frontmostWindow()
    if window then
        return func(window)
    else
        hs.alert.show("No window found")
        return false
    end
end

function export.orderedScreens()
    return sorted(hs.screen.allScreens(), function(t,a,b)
        return t[a]:position() < t[b]:position()
    end)
end

function export.orderedWindows(appName)
    local ret = {}
    local windows = hs.window.orderedWindows()
    for i,window in pairs(windows) do
        if window:application():title() == appName and window:isStandard() then
            ret[#ret + 1] = window
        end
    end
    return ret
end

function export.scaleWindow(win, x, y, w, h)
    local existingFrame = win:frame()
    local f = win:frame()
    local max = win:screen():frame()

    f.x = max.x + max.w * x
    f.y = max.y + max.h * y
    f.w = max.w * w
    f.h = max.h * h

    if not existingFrame:equals(f) then
        win:setFrame(f)
        return true
    end

    return false
end

return export
