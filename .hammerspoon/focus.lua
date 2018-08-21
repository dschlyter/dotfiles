local export = {}
local l = {}

local shared = require "shared"

function export.up()
    orChain(l.focusDirection("North", false), function()
        l.focusWindowOnSameScreen(-1)
    end)
end

function export.down()
    orChain(l.focusDirection("South", false), function()
        l.focusWindowOnSameScreen(1)
    end)
end

function export.left()
    orChain(l.focusDirection("East", false), function()
      l.focusWindowOnSameScreen(1)
    end)
end

function export.right()
    orChain(l.focusDirection("West", false), function()
        l.focusWindowOnSameScreen(-1)
    end)
end

function export.focusChrome()
    l.focusNextWindow("Google Chrome")
end

function export.focusTerminal()
    l.focusNextWindow("iTerm2", "iTerm")
end

function export.focusIntellij()
    l.focusNextWindow("IntelliJ IDEA")
end

function export.focusSpotify()
    l.focusNextWindow("Spotify")
end

-- reimplements focusWindowX with less buggy and more powerful functionality
-- first try to find the best window, then fallback to all windows in that direction
function l.focusDirection(direction)
    return shared.findFocused(function(window)
        return l.focusDirectionFrom(window, direction)
    end)
end

function l.focusDirectionFrom(window, direction)
    -- otherWindows will be ordered with on-top window first
    local strict = true
    local otherWindows = window["windowsTo"..direction](window, nil, strict, strict)

    for k,v in pairs(otherWindows) do
        -- when finding non-strict, stay on the same screen, to avoid completely confusing refocuses
        if v:isStandard() then
            v:focus()
            -- bug, if an application has multiple windows, a window on the current screen can steal focus
            -- solve this by focusing again if the intended window did not get the focus
            -- side effect: wrong window may remain on top
            if v:id() ~= hs.window.focusedWindow():id() then
                log.i('Application stole focus, refocusing')
                v:focus()
            end
            return true
        end
    end

    return false
end

-- same screen focus implementation
function l.focusWindowOnSameScreen(dir)
    local windows = l.windowsForCurrentScreen()
    if #windows > 1 then
        local newWindowIndex = indexMod(l.currentWindowIndex(windows) + dir, #windows)
        windows[newWindowIndex]:focus()
        -- focusLayerWithIndex(layers, newLayerIndex)
    end
end

function l.currentWindowIndex(windows)
    local focusedWindow = hs.window.focusedWindow()
    for i,window in ipairs(windows) do
        if window == focusedWindow then
            return i
        end
    end
    return 1
end

function l.windowsForCurrentScreen()
    local currScreen = hs.window.frontmostWindow():screen()
    local windows = hs.window.visibleWindows()
    local ret = {}
    for k,v in spairs(windows, l.windowOrdering) do
        if v:isStandard() and v:screen():id() == currScreen:id() then
            ret[#ret + 1] = v
        end
    end
    return ret
end

function l.windowOrdering(t, a, b)
    local aTitle = t[a]:application():title()
    local bTitle = t[b]:application():title()
    if aTitle ~= bTitle then
        return bTitle < aTitle
    end

    -- finder windows may have null id
    return default(t[b]:id(), 0) > default(t[a]:id(), 0)
end

-- focus apps
function l.focusNextWindow(appName, launchName)
    if not launchName then
        launchName = appName
    end

    local windows = shared.orderedWindows(appName)
    if hs.window.focusedWindow():application():title() == appName then
        if #windows > 1 then
            windows[2]:focus()
        else
            l.focusNext()
        end
    elseif #windows > 0 then
        windows[1]:focus()
    else
        hs.application.launchOrFocus(launchName)
    end
end

function l.focusNext()
    local ordered = hs.window.orderedWindows()
    if #ordered > 1 then
        ordered[2]:focus()
    end
end

return export
