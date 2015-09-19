-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "ctrl", "cmd"}
local minimumMoveDistance = 10

hs.window.animationDuration = 0

-- i to show window hints
----------------------------------

hs.hints.style = "vimperator" -- prefix hint with first letter in application name, to make it deterministic
hs.hotkey.bind(modifierFocus, 'i', function()
    hs.hints.windowHints()
end)

-- hjkl to switch window focus
---------------------------------------

hs.hotkey.bind(modifierFocus, 'k', function()
    focusDirection("North")
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    focusDirection("South")
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
    findFocused(function(window) 
        local found = focusDirectionFrom(window, direction, true)
        if not found then
            focusDirectionFrom(window, direction, false)
        end
    end)
end

function focusDirectionFrom(window, direction, strict)
    -- otherWindows will be ordered with on-top window first
    local otherWindows = window["windowsTo"..direction](window, nil, strict, strict)

    for k,v in pairs(otherWindows) do
        if v:isStandard() then
            v:focus()
            -- bug, if an application has multiple windows, a window on the current screen can steal focus
            -- solve this by focusing again if the intended window did not get the focus
            -- side effect: wrong window may remain on top
            if v:id() ~= hs.window.focusedWindow():id() then
                v:focus()
            end
            return true
        end
    end

    return false
end

function findFocused(func)
    local window = hs.window.focusedWindow()
    if window then
        func(window)
    else
        hs.alert.show("No active window")
    end
end

-- u for fullscreen
-- jkhl for half screen
-- yinm for quarter window 
-----------------------------------

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
------------------------------

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
