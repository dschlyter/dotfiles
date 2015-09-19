-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "ctrl", "cmd"}

hs.window.animationDuration = 0

-- i to show window hints
----------------------------------

hs.hints.style = "vimperator" -- prefix hint with first letter in application name, to make it deterministic
hs.hotkey.bind(modifierFocus, 'i', function()
    hs.hints.windowHints()
end)

-- hjkl to switch window focus
---------------------------------------


local findFocused = function(func) 
    local window = hs.window.focusedWindow() 
    if window then
        func(window)
    else
        hs.alert.show("No active window")
    end
end

hs.hotkey.bind(modifierFocus, 'k', function()
    findFocused(function(window) 
        window:focusWindowNorth()
    end)
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    findFocused(function(window) 
        window:focusWindowSouth()
    end)
end)

hs.hotkey.bind(modifierFocus, 'l', function()
    findFocused(function(window) 
        window:focusWindowEast()
    end)
end)

hs.hotkey.bind(modifierFocus, 'h', function()
    findFocused(function(window) 
        window:focusWindowWest()
    end)
end)

-- u for fullscreen
-- jkhl for half screen
-- yinm for quarter window 
-----------------------------------

local scaleFocused = function(x, y, w, h)
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

-- hl for sending to next/prev monitor
------------------------------

hs.hotkey.bind(modifierMoveScreen, 'h', function()
    findFocused(function(win)
        win:moveToScreen(win:screen():next())
    end)
end)

hs.hotkey.bind(modifierMoveScreen, 'l', function()
    findFocused(function(win)
        win:moveToScreen(win:screen():previous())
    end)
end)


-- Reload config on write
-------------------------
function reload_config(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reload_config):start()
hs.alert.show("Hammerspoon config loaded")
