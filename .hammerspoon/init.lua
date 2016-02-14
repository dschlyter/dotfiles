-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "ctrl", "cmd"}
local modifierMoveSpace = {"ctrl", "cmd"}
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
    local found = focusDirection("North", false)
    if not found then
        focusLayer(-1)
    end
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    local found = focusDirection("South", false)
    if not found then
        focusLayer(1)
    end
end)

hs.hotkey.bind(modifierFocus, 'l', function()
    focusDirection("East", true)
end)

hs.hotkey.bind(modifierFocus, 'h', function()
    focusDirection("West", true)
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
    scaleFocused(0, 0, 0.5, 1)
end)

hs.hotkey.bind(modifierResize, 'l', function()
    scaleFocused(0.5, 0, 0.5, 1)
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
    findFocused(function(win)
        local f = win:frame()
        local max = win:screen():frame()

        f.x = max.x + max.w * x
        f.y = max.y + max.h * y
        f.w = max.w * w
        f.h = max.h * h
        win:setFrame(f)

        store_window_pos()
    end)
end

-- hl for sending to next/prev monitor
--------------------------------------

hs.hotkey.bind(modifierMoveScreen, 'h', function()
    findFocused(function(win)
        win:moveOneScreenWest()
        store_window_pos()
    end)
end)

hs.hotkey.bind(modifierMoveScreen, 'l', function()
    findFocused(function(win)
        win:moveOneScreenEast()
        store_window_pos()
    end)
end)

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
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Hammerspoon config loaded")

-- hotkeys
----------

hs.hotkey.bind({'alt'}, 'space', function()
    local existingWindows = windowsExist("iTerm")
    hs.application.launchOrFocus("iTerm")
    if existingWindows then
        hs.eventtap.keyStroke({'cmd'}, 'n')
    else
        -- opening iTerm without open windows will open a new window, no need for cmd-n
        
        -- unless we are on a new space, and have the setting of auto-switch space disabled
        if not windowsExist("iTerm") then
            hs.eventtap.keyStroke({'cmd'}, 'n')
        end
    end
end)

-- enable readline style word navigation
hs.hotkey.bind({'alt'}, 'f', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'right', true):post()
end)

hs.hotkey.bind({'alt'}, 'b', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'left', true):post()
end)

hs.hotkey.bind({'ctrl', 'alt'}, 'b', function()
    os.execute('curl -X POST 192.168.1.66:29330/blank')
end)

hs.hotkey.bind({'ctrl', 'alt'}, 's', function()
    os.execute('curl -X POST 192.168.1.66:29330/sleep')
end)

function windowsExist(appName)
    local windows = hs.window.allWindows()
    for i,window in pairs(windows) do
        if window:application():title() == appName then
            return true
        end
    end
end

-- save and restore window positions when switching monitors
------------------------------------------------------------
local windowPositions = {}

function store_window_pos()
    local screenCount = #hs.screen.allScreens()

    local windows = visibleWindows_fixed()
    for i,window in pairs(windows) do
        local id = window:id()
        if id then -- finder bugs out in el capitan
            local key = screenCount .. "--" .. id
            windowPositions[key] = window:frame()
        end
    end
end

function restore_window_pos()
    local screenCount = #hs.screen.allScreens()

    local windows = visibleWindows_fixed()
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

-- copy of hs.window.visibleWindows with some add robustness to keep it from crashing
function visibleWindows_fixed() 
    local r = {}
    for _,app in ipairs(hs.application.runningApplications()) do
        -- speedup by excluding hidden app
        if app:kind() > 0 and not app:isHidden() then 
            log.d(app:name())
            log.d(app:visibleWindows())
            for _,w in ipairs(app:visibleWindows()) do 
                r[#r+1] = w 
            end 
        end
    end
    return r

end

hs.hotkey.bind(modifierResize, 'o', function()
    restore_window_pos()
end)

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
            if fitsInLayer(layer, window) then
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
        if intersection.w * intersection.h > 0 then
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
    local layer = layers[newLayerIndex]

    local focusedWindow = hs.window.frontmostWindow()
    local closestWindow = nil
    local bestDistance = nil
    for i,window in ipairs(layer) do
        local distance = window:frame():distance(focusedWindow:frame())
        if closestWindow == nil or distance < bestDistance then
            bestDistance = distance
            closestWindow = window
        end
    end

    for i,window in ipairs(layers[newLayerIndex]) do
        if window ~= closestWindow then
            window:raise()
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

function windowOrdering(t, a, b)
    local aTitle = t[a]:application():title()
    local bTitle = t[b]:application():title()
    if aTitle ~= bTitle then
        return bTitle < aTitle
    end

    return t[b]:id() > t[a]:id()
end
