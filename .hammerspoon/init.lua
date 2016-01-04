-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "ctrl", "cmd"}
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
                log.d('Application stole focus, refocusing')
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
    end)
end)

hs.hotkey.bind(modifierMoveScreen, 'l', function()
    findFocused(function(win)
        win:moveOneScreenEast()
    end)
end)


-- Reload config on write
-------------------------
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Hammerspoon config loaded")

-- save and restore window positions when switching monitors
------------------------------------------------------------
local windowPositions = {}

function store_window_pos()
    local screenCount = #hs.screen.allScreens()
    windowPositions[screenCount] = {}
    local screenPositions = windowPositions[screenCount]

    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        screenPositions[window:id()] = window:frame()
        log.d(k, window:application():title())
    end
end

function restore_window_pos()
    local screenCount = #hs.screen.allScreens()
    local screenPositions = windowPositions[screenCount]

    if screenPositions then
        local windows = hs.window.visibleWindows()
        for i,window in pairs(windows) do
            local frame = screenPositions[window:id()]
            if frame then
                window:setFrame(frame)
                log.d(k, window:application():title())
            end
        end
    end
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
