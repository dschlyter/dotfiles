-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierPrimary = {"alt", "ctrl"}
local modifierSecondary = {"alt", "shift"}

local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "shift"}
local modifierMoveScreenIndex = {"alt", "ctrl"}
local modifierMoveSpace = {"alt", "ctrl"}
local modifierComplicated = {"alt", "ctrl", "cmd"}
local minimumMoveDistance = 10

hs.window.animationDuration = 0

local log = hs.logger.new('logger','debug')

-- i to show window hints
-------------------------

hs.hints.style = "vimperator" -- prefix hint with first letter in application name, to make it deterministic
hs.hotkey.bind(modifierFocus, 'i', function()
    -- threshold for showing full titles should increase based on number of screens
    hs.hints.showTitleThresh = #hs.screen.allScreens() * 4
    hs.hints.windowHints()
end)

-- hjkl to switch window focus
------------------------------

hs.hotkey.bind(modifierFocus, 'k', function()
    orChain(focusDirection("North", false), function()
        focusLayer(-1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    orChain(focusDirection("South", false), function() 
        focusLayer(1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'l', function()
    orChain(focusDirection("East", false), function()
        focusLayer(1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'h', function()
    orChain(focusDirection("West", false), function()
        focusLayer(-1)
    end)
end)

-- reimplements focusWindowX with less buggy and more powerful functionality
-- first try to find the best window, then fallback to all windows in that direction
function focusDirection(direction, retryNonStrict)
    return findFocused(function(window) 
        local found = focusDirectionFrom(window, direction, true)
        if not found and retryNonStrict then
            found = focusDirectionFrom(window, direction, false)
        end
        return found
    end)
end

function focusDirectionFrom(window, direction, strict)
    -- otherWindows will be ordered with on-top window first
    local otherWindows = window["windowsTo"..direction](window, nil, strict, strict)

    for k,v in pairs(otherWindows) do
        -- when finding non-strict, stay on the same screen, to avoid completely confusing refocuses
        if v:isStandard() and (strict or v:screen():id() == window:screen():id()) then
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

function findFocused(func)
    local window = hs.window.frontmostWindow()
    if window then
        return func(window)
    else
        hs.alert.show("No window found")
        return false
    end
end

-- u for fullscreen
-- jkhl for half screen
-- yinm for quarter window 
--------------------------

hs.hotkey.bind(modifierResize, 'u', function()
    scaleFocused(0, 0, 1, 1)
end)

hs.hotkey.bind(modifierResize, 'j', function()
    scaleFocused(0, 0.5, 1, 0.5)
end)

hs.hotkey.bind(modifierResize, 'k', function()
    scaleFocused(0, 0, 1, 0.5)
end)

hs.hotkey.bind(modifierResize, 'h', function()
    orChain(scaleFocused(0, 0, 0.5, 1), moveWindowOneScreenWest)
end)

hs.hotkey.bind(modifierResize, 'l', function()
    orChain(scaleFocused(0.5, 0, 0.5, 1), moveWindowOneScreenEast)
end)

hs.hotkey.bind(modifierResize, 'y', function()
    scaleFocused(0, 0, 0.5, 0.5)
end)

hs.hotkey.bind(modifierResize, 'i', function()
    scaleFocused(0.5, 0, 0.5, 0.5)
end)

hs.hotkey.bind(modifierResize, 'm', function()
    scaleFocused(0.5, 0.5, 0.5, 0.5)
end)

hs.hotkey.bind(modifierResize, 'n', function()
    scaleFocused(0, 0.5, 0.5, 0.5)
end)

function scaleFocused(x, y, w, h)
    return findFocused(function(win)
        return scaleWindow(win, x, y, w, h)
    end)
end

function scaleWindow(win, x, y, w, h)
    local existingFrame = win:frame()
    local f = win:frame()
    local max = win:screen():frame()

    f.x = max.x + max.w * x
    f.y = max.y + max.h * y
    f.w = max.w * w
    f.h = max.h * h

    if not existingFrame:equals(f) then
        win:setFrame(f)
        storeWindowPos()
        return true
    end

    return false
end

function orChain(f1ret, f2)
    if not f1ret then
        f2()
    end
end

-- hl for sending to next/prev monitor
--------------------------------------

hs.hotkey.bind(modifierMoveScreen, 'h', function()
    moveWindowOneScreenWest()
end)


hs.hotkey.bind(modifierMoveScreen, 'l', function()
    moveWindowOneScreenEast()
end)

function moveWindowOneScreenWest()
    findFocused(function(win)
        win:moveOneScreenWest()
        storeWindowPos()
    end)
end

function moveWindowOneScreenEast()
    findFocused(function(win)
        win:moveOneScreenEast()
        storeWindowPos()
    end)
end

-- 123 for move to screen by index (better than above)
------------------------------------------------------

hs.hotkey.bind(modifierMoveScreenIndex, '1', function()
    moveFocusedWindowToScreen(1)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '2', function()
    moveFocusedWindowToScreen(2)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '3', function()
    moveFocusedWindowToScreen(3)
end)

-- duplicate keys for easier two hand access
hs.hotkey.bind(modifierMoveScreenIndex, '7', function()
    moveFocusedWindowToScreen(1)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '8', function()
    moveFocusedWindowToScreen(2)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '9', function()
    moveFocusedWindowToScreen(3)
end)

function moveFocusedWindowToScreen(index)
    findFocused(function(win)
        moveWindowToScreen(win, index)
    end)
end

function orderedScreens()
    return sorted(hs.screen.allScreens(), function(t,a,b)
        return t[a]:position() < t[b]:position()
    end)
end

function moveWindowToScreen(window, index)
    local target = orderedScreens()[index]
    window:moveToScreen(target)
    storeWindowPos()
    return ret
end

-- cmd-ctrl left-right for sending to next/prev space
-- (this is pretty much a hack that captures the mouse, and sends ctrl-left/right)

hs.hotkey.bind(modifierMoveSpace, 'left', function()
    findFocused(function(focusedWindow)
        moveToSpace(focusedWindow, 'left')
    end)
end)

hs.hotkey.bind(modifierMoveSpace, 'right', function()
    findFocused(function(focusedWindow)
        moveToSpace(focusedWindow, 'right')
    end)
end)

function moveToSpace(focusedWindow, direction)
    local startMousePos = hs.mouse.getAbsolutePosition()

    local mouseDragPosition = focusedWindow:frame().topleft
    mouseDragPosition:move(hs.geometry(5,15))

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, mouseDragPosition):post()
    hs.eventtap.event.newKeyEvent({'ctrl'}, direction, true):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, mouseDragPosition):post()

    hs.mouse.setAbsolutePosition(startMousePos)
end


-- Reload config on write
-------------------------
function reloadConfig(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")

-- automatic reload does not always work - so allow manual reload
hs.hotkey.bind(modifierComplicated, 'r', function()
    hs.reload()
end)


-- hotkeys
----------

-- spawn a new iterm window
hs.hotkey.bind({'ctrl', 'alt'}, 'space', function()
    hs.application.launchOrFocus("iTerm")

    -- opening iTerm without open windows will open a new window, no need for cmd-n
    -- unless we are on a new space, and have the setting of auto-switch space disabled
    if not windowsExist("iTerm2") then
        hs.eventtap.keyStroke({'cmd'}, 'n')
    end
end)

function windowsExist(appName)
    local windows = hs.window.allWindows()
    for i,window in pairs(windows) do
        if window:application():title() == appName then
            return true
        end
    end
end

-- enable readline style word navigation
hs.hotkey.bind({'alt'}, 'f', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'right', true):post()
end)

hs.hotkey.bind({'alt'}, 'b', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'left', true):post()
end)

hs.hotkey.bind({'ctrl', 'alt'}, 'b', function()
    os.execute('curl -X POST 192.168.10.124:29330/blank')
end)

hs.hotkey.bind({'ctrl', 'alt'}, 's', function()
    hs.timer.doAfter(1, function()
        hs.caffeinate.startScreensaver()
    end)
end)

hs.hotkey.bind({'alt'}, 'p', function()
    hs.eventtap.event.newKeyEvent({}, 'up', true):post()
end)

hs.hotkey.bind({'alt'}, 'n', function()
    hs.eventtap.event.newKeyEvent({}, 'down', true):post()
end)

hs.hotkey.bind({'ctrl', 'alt'}, 'r', function()
    os.execute('osascript switchMouse.AppleScript')
end)

-- spotify hotkeys
hs.hotkey.bind(modifierPrimary, ',', function()
    hs.spotify.previous()
end)

hs.hotkey.bind(modifierPrimary, '.', function()
    hs.spotify.playpause()
end)

hs.hotkey.bind(modifierPrimary, '-', function()
    hs.spotify.next()
end)

hs.hotkey.bind(modifierSecondary, ',', function()
    hs.spotify.rw()
end)

hs.hotkey.bind(modifierSecondary, '-', function()
    hs.spotify.ff()
end)

-- save and restore window positions when switching monitors
------------------------------------------------------------
local windowPositions = {}

function storeWindowPos()
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

function restoreWindowPos()
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

local windowPresetTable = {}
windowPresetTable["iTerm2"] = "internal"
windowPresetTable["Spotify"] = "internal"
windowPresetTable["IntelliJ IDEA"] = "main"
windowPresetTable["Google Chrome"] = "secondary"

function positionWindowsByPreset()
    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local name = window:application():name()
        local mapping = windowPresetTable[name]
        if mapping then
            -- moveWindowToScreen(window, index)
            local target = getScreenByMapping(mapping)
            window:moveToScreen(target)
            -- maximize
            scaleWindow(window, 0, 0, 1, 1)
        end
    end
    storeWindowPos()
end

function getScreenByMapping(mapping)
    -- the internal screen is currently the primary screen
    local internal = hs.screen.primaryScreen()

    local screens = orderedScreens()

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

hs.hotkey.bind(modifierResize, 'o', function()
    restoreWindowPos()
end)

hs.hotkey.bind(modifierResize, 'p', function()
    positionWindowsByPreset()
end)

local savedApps = {}

-- quickly close and restore open apps (useful before user switching)
hs.hotkey.bind(modifierResize, 'a', function()
    local savedAppsBlacklist = Set{"Hammerspoon", "Finder"}

    if #savedApps > 0 then
        log.d("Restoring " .. #savedApps .. " saved apps " .. toString(savedApps))
        openAll(savedApps)
        savedApps = {}
        restartScrollReverser()
    else
        for i,app in pairs(hs.application.runningApplications()) do
            if #app:visibleWindows() > 0 and not savedAppsBlacklist[app:name()] then
                table.insert(savedApps, app:name())
            end
        end

        if #savedApps > 0 then
            log.d("Saving " .. #savedApps .. " apps " .. toString(savedApps))
            killAll(savedApps)
        else
            local defaultApps = {"IntelliJ IDEA", "Google Chrome", "iTerm", "Spotify"}
            log.d("Opening default apps" .. toString(defaultApps))
            openAll(defaultApps)
        end
    end
end)


function mapAppOpenName(appName)
    local mappedApps = {["iTerm2"]="iTerm"}

    local mappedName = mappedApps[appName]
    if mappedName then
        return mappedName
    else
        return appName
    end
end

function openAll(appsNames)
    for i,appName in pairs(appsNames) do
        local mappedName = mapAppOpenName(appName)
        hs.application.launchOrFocus(mappedName)
    end
end

function killAll(appNames)
    for i,appName in pairs(appNames) do
        local app = hs.application.get(appName)
        if app then
            app:kill()
        end
    end
end

-- advanced window focus - separate windows for current screen into non-overlapping layers and toggle between them
------------------------------------------------------------------------------------------------------------------

function focusLayer(dir)
    local layers = buildLayers()
    if #layers > 1 then
        local newLayerIndex = (currentLayerIndex(layers) - 1 + dir) % #layers + 1
        focusLayerWithIndex(layers, newLayerIndex)
    end
end

function buildLayers()
    local windows = windowsForCurrentScreen()
    local layers = {}

    for k,window in spairs(windows, windowOrdering) do
        local added = false
        for i,layer in ipairs(layers) do
            if not added and fitsInLayer(layer, window) then
                layer[#layer + 1] = window
                added = true
            end
        end

        if not added then
            layers[#layers + 1] = {}
            layers[#layers][1] = window
        end
    end

    return layers
end

function fitsInLayer(layer, window)
    for i,otherWindow in ipairs(layer) do
        local intersection = window:frame():intersect(otherWindow:frame())
        if intersection.w > 5 and intersection.h > 5 then
            return false
        end
    end

    return true
end

function currentLayerIndex(layers)
    local focusedWindow = hs.window.focusedWindow()
    for i,layer in ipairs(layers) do
        for j,window in ipairs(layer) do
            if window == focusedWindow then
                return i
            end
        end
    end
    return 1
end

function focusLayerWithIndex(layers, newLayerIndex)
    -- idea:
    -- 1. focus the closest window to the current window to preserve location (ie. right window to right window)
    -- 2. apply a small bias towards recently focused windows (ie. fullscreen window to right window, if more recently focused)

    local focusBias = {}
    for i,window in ipairs(hs.window.orderedWindows()) do
        focusBias[window:id()] = i;
    end

    local layer = layers[newLayerIndex]

    local focusedWindow = hs.window.frontmostWindow()
    local closestWindow = nil
    local bestDistance = nil
    for i,window in ipairs(layer) do
        local distance = window:frame():distance(focusedWindow:frame()) + focusBias[window:id()]
        if closestWindow == nil or distance < bestDistance then
            bestDistance = distance
            closestWindow = window
        end
    end

    for i,window in ipairs(layers[newLayerIndex]) do
        if window ~= closestWindow then
            -- raise would be better, but does not seem to work
            -- window:raise()
            window:focus()
        end
    end

    closestWindow:focus()
end

function windowsForCurrentScreen()
    local currScreen = hs.window.frontmostWindow():screen()
    local windows = hs.window.visibleWindows()
    local ret = {}
    for k,v in pairs(windows) do
        if v:isStandard() and v:screen():id() == currScreen:id() then
            ret[#ret + 1] = v
        end
    end
    return ret
end

-- base functionality that should really be in the language
-----------------------------------------------------------

-- http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function sorted(t, order)
    local ret = {}
    for k,v in spairs(t,order) do ret[#ret+1] = v end
    return ret
end

function windowOrdering(t, a, b)
    local aTitle = t[a]:application():title()
    local bTitle = t[b]:application():title()
    if aTitle ~= bTitle then
        return bTitle < aTitle
    end

    return t[b]:id() > t[a]:id()
end

function toString(list)
    return "[" .. table.concat(list, ", ") .. "]"
end

-- http://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
function Set (list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

-- restart scroll revserser on sleep wakeup, since it stops working
-------------------------------------------------------------------

hs.caffeinate.watcher.new(function(event)
    if (event == hs.caffeinate.watcher.systemDidWake) then
        restartScrollReverser()
    end
end):start()

function restartScrollReverser()
    log.d("Restarting scroll reverser after sleep wakeup")
    os.execute('pkill "Scroll Reverser" && open "/Applications/Scroll Reverser.app"')
end
