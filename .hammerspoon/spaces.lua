local export = {}
local l = {}

local shared = require "shared"

-- cmd-ctrl left-right for sending to next/prev space
-- (this is pretty much a hack that captures the mouse, and sends ctrl-left/right)

function export.left()
    shared.findFocused(function(focusedWindow)
        l.moveToSpace(focusedWindow, 'left')
    end)
end

function export.right()
    shared.findFocused(function(focusedWindow)
        l.moveToSpace(focusedWindow, 'right')
    end)
end

function l.moveToSpace(focusedWindow, direction)
    local startMousePos = hs.mouse.getAbsolutePosition()

    local mouseDragPosition = focusedWindow:frame().topleft
    mouseDragPosition:move(hs.geometry(5,15))

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, mouseDragPosition):post()
    hs.eventtap.event.newKeyEvent({'ctrl'}, direction, true):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, mouseDragPosition):post()

    hs.mouse.setAbsolutePosition(startMousePos)
end

return export
