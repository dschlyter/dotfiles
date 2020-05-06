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

function export.recentOnSameScreen()
    shared.findFocused(function(window)
        l.focusRecentOnSameScreen()
    end)
end

function export.focusChrome()
    l.focusNextWindow("Google Chrome")
end

function export.focusFirefox()
    l.focusNextWindow("Firefox")
end

function export.focusTerminal()
    l.focusNextWindow("iTerm2", "iTerm")
end

function export.focusIntellij()
    l.focusNextWindow("IntelliJ IDEA")
end

function export.focusSpotify()
    l.focusNextWindow("Spotify", "Spotify", true)
end

function export.focusSlack()
    l.focusNextWindow("Slack", "Slack", true)
end

function export.focusVsCode()
    l.focusNextWindow("Visual Studio Code")
end

function export.focusOtherApp()
    l.focusNot({"Google Chrome", "Firefox", "iTerm2", "IntelliJ IDEA", "Spotify", "Slack"})
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

-- same screen focus next
function l.focusRecentOnSameScreen()
    local currScreen = hs.window.frontmostWindow():screen()
    local windows = l.orderedWindowsOnScreen(currScreen)

    if #windows >= 2 then
        windows[2]:focus()
    end
end

function l.orderedWindowsOnScreen(screen)
    local windows = hs.window.orderedWindows()

    local ret = {}
    for i,window in pairs(windows) do
        if window:isStandard() and window:screen():id() == screen:id() then
            ret[#ret + 1] = window
        end
    end
    return ret
end

-- focus apps
function l.focusNextWindow(appName, launchName, toggle)
    if not launchName then
        launchName = appName
    end

    local windows = shared.orderedWindows(appName)
    if hs.window.focusedWindow():application():title() == appName then
        if #windows > 1 then
            windows[2]:focus()
        else
            if toggle then
                windows[1]:sendToBack()
            else
                l.focusNext()
            end
        end
    elseif #windows > 0 then
        windows[1]:focus()
    else
        hs.application.launchOrFocus(launchName)
    end
end

function l.focusNot(appNames)
    local focused = hs.window.focusedWindow()
    local windows = hs.window.orderedWindows()

    for i,window in pairs(windows) do
        local focused = window:id() == focused:id()

        local application = window:application():title()
        local match = false
        for i,appName in pairs(appNames) do
            if appName == application then
                match = true
            end
        end

        if not (match or focused) then
            window:focus()
            return
        end
    end
end

function l.focusNext()
    local ordered = hs.window.orderedWindows()
    if #ordered > 1 then
        ordered[2]:focus()
    end
end

--[[

local focusFile = "/var/tmp/hammerspoon-focus-log"

hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function (w, appName)
    log.d(appName)
    local f = io.open(focusFile, "a")

    if f then
        f:write(os.date("%Y-%m-%d %T ") .. appName .. "\n")
        f:close()
    else
        hs.alert.show("Error saving timestamp, write permission error?")
    end
end)
--]]


return export
