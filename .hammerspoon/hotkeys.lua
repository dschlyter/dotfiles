-- custom code for hotkey commands

local export = {}
local l = {}

local shared = require "shared"

function export.screensaver()
    hs.timer.doAfter(1, function()
        hs.caffeinate.startScreensaver()
    end)
end

-- focus chrome with google inbox to quickly add a note
-- allow to quickly add a reminder and keep working on the current task
function export.focusFirstChromeTab()
    local windows = shared.orderedWindows("Google Chrome")

    local smallestWindow = nil
    local smallestWindowSize = 9000 * 9000
    for i,window in pairs(windows) do
        local size = (window:frame().w) * (window:frame().h)
        if size < smallestWindowSize then
            smallestWindowSize = size
            smallestWindow = window
        end
    end

    smallestWindow:focus()

    hs.eventtap.event.newKeyEvent({'cmd'}, '1', true):post()
end

function export.spotifyBack()
    hs.spotify.setPosition(hs.spotify.getPosition() - 30)
end

function export.spotifyForward()
    hs.spotify.setPosition(hs.spotify.getPosition() + 30)
end

function export.volumeDown()
    local device = hs.audiodevice.current().device
    local vol = math.max(0, device:outputVolume() - 5)
    device:setVolume(vol)
end

function export.volumeUp()
    local device = hs.audiodevice.current().device
    local vol = math.min(100, device:outputVolume() + 5)
    device:setVolume(vol)
end

function export.toggleMute()
    local device = hs.audiodevice.current().device
    device:setMuted(not device:muted())
end

return export
