local export = {}
local l = {}

local shared = require "shared"

function export.pressLeft()
    hs.eventtap.event.newKeyEvent({'alt'}, 'right', true):post()
end

function export.pressRight()
    hs.eventtap.event.newKeyEvent({'alt'}, 'left', true):post()
end

function export.pressUp()
    hs.eventtap.event.newKeyEvent({}, 'up', true):post()
end

function export.pressDown()
    hs.eventtap.event.newKeyEvent({}, 'down', true):post()
end

return export
