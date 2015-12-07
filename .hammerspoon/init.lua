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
----------------------------------

hs.hints.style = "vimperator" -- prefix hint with first letter in application name, to make it deterministic
hs.hotkey.bind(modifierFocus, 'i', function()
    -- threshold for showing full titles should increase based on number of screens
    hs.hints.showTitleThresh = #hs.screen.allScreens() * 4
    hs.hints.windowHints()
end)

-- hjkl to switch window focus
---------------------------------------

hs.hotkey.bind(modifierFocus, 'k', function()
    local found = focusDirection("North")
    if not found then
        focusLayer(-1)
    end
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    local found = focusDirection("South")
    if not found then
        focusLayer(1)
    end
end)

hs.hotkey.bind(modifierFocus, 'l', function()
    focusDirection("East")
end)

hs.hotkey.bind(modifierFocus, 'h', function()
    focusDirection("West")
end)

-- reimplements focusWindowX with less buggy and more powerful functionality
-- first try to find the best window, then fallback to all windows in that direction
function focusDirection(direction)
    return findFocused(function(window) 
        local found = focusDirectionFrom(window, direction, true)
        if not found then
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

-- advanced window focus - separate windows for current screen into layers and toggle between then
--------------------------------------------------------------------------------------------------

function focusLayer(dir)
    hs.alert.show("focus dir "..dir)

    local layers = buildLayers()
    local newLayerIndex = (currentLayerIndex(layers) - 1 + dir) % #layers + 1
    focusLayerWithIndex(layers, newLayerIndex)
end

function buildLayers()
    local windows = windowsForCurrentScreen()
    -- TODO sort windows determistically
    -- TODO group into layers
    return windows
end

function currentLayerIndex(layers)
    local focusedWindow = hs.window.frontmostWindow()
    for k,v in pairs(layers) do
        if v == focusedWindow then
            log.d('found focused')
            return k
        end
    end
    return 1
end

function focusLayerWithIndex(layers, newLayerIndex)
    layers[newLayerIndex]:focus()
end

function windowsForCurrentScreen()
    local currScreen = hs.window.frontmostWindow():screen()
    local windows = hs.window.visibleWindows()
    local ret = {}
    for k,v in pairs(windows) do
        -- log:d('found '..v:application():title())
        if v:isStandard() and v:screen():id() == currScreen:id() then
            log:d('adding '..v:application():title())
            ret[#ret + 1] = v
        end
    end
    return ret
end
