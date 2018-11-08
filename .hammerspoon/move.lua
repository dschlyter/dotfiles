local export = {}
local l = {}

local shared = require "shared"
local positions = require "positions"

function export.fullscreen()
    l.scaleFocused(0, 0, 1, 1)
end

function export.sendToBack()
    shared.findFocused(function(win)
        -- TODO this is totally broken
        win:sendToBack()
    end)
end

function export.left()
    orChain(l.scaleFocused(0, 0, 0.5, 1), export.moveWindowOneScreenWest)
end

function export.right()
    orChain(l.scaleFocused(0.5, 0, 0.5, 1), export.moveWindowOneScreenEast)
end

function export.moveWindowOneScreenWest()
    shared.findFocused(function(win)
        win:moveOneScreenWest()
        positions.storeWindowPos()
    end)
end

function export.moveWindowOneScreenEast()
    shared.findFocused(function(win)
        win:moveOneScreenEast()
        positions.storeWindowPos()
    end)
end

function export.screen1()
    l.moveFocusedWindowToScreen(1)
end

function export.screen2()
    l.moveFocusedWindowToScreen(2)
end

function export.screen3()
    l.moveFocusedWindowToScreen(3)
end

-- private functions

function l.moveFocusedWindowToScreen(index)
    shared.findFocused(function(win)
        return l.moveWindowToScreen(win, index)
    end)
end

function l.moveWindowToScreen(window, index)
    local target = shared.orderedScreens()[index]
    window:moveToScreen(target)
    positions.storeWindowPos()
    return true
end

function l.scaleFocused(x, y, w, h)
    return shared.findFocused(function(win)
        local ret = shared.scaleWindow(win, x, y, w, h)
        positions.storeWindowPos()
        return ret
    end)
end

return export
