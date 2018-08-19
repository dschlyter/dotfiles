-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Reload config on write
-- (put this first to make sure it works even on errors when loading
function reloadConfig(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- global logger for dev debugging
log = hs.logger.new('logger','debug')

-- settings
hs.window.animationDuration = 0

-- Organization, only have hotkey definitions here, all code in required modules

require "base"
local focus = require "focus"
local move = require "move"
local spaces = require "spaces"
local hotkeys = require "hotkeys"
local keyentry = require "keyentry"
local alttab = require "alttab"

local pin = require "pin"
local positions = require "positions"
local saveapps = require "saveapps"
local chain = require "chain"
local chooser = require "chooser"
require "startup"

local modifierFocus = {"alt"}
local modifierPrimary = {"alt", "ctrl"}
local modifierSecondary = {"alt", "shift"}
local modifierComplicated = {"alt", "ctrl", "cmd"}

-- hotkeys on focus (alt)
hs.hotkey.bind(modifierFocus, 'k', focus.up)
hs.hotkey.bind(modifierFocus, 'j', focus.down)
hs.hotkey.bind(modifierFocus, 'l', focus.left)
hs.hotkey.bind(modifierFocus, 'h', focus.right)

hs.hotkey.bind(modifierFocus, 'space', focus.focusTerminal)
hs.hotkey.bind(modifierFocus, 'c', focus.focusChrome)
hs.hotkey.bind(modifierFocus, 'd', focus.focusIntellij)
hs.hotkey.bind(modifierFocus, 's', focus.focusSpotify)

hs.hotkey.bind(modifierFocus, 'g', chooser.finderSearch)
hs.hotkey.bind(modifierFocus, 'q', chooser.quickCommands)

hs.hotkey.bind(modifierFocus, 'm', hotkeys.focusFirstChromeTab)

hs.hotkey.bind(modifierFocus, 'u', chain.focusNextInChain)
hs.hotkey.bind(modifierFocus, 'i', chain.switchChain)

hs.hotkey.bind({'alt'}, 'tab', alttab.next)
hs.hotkey.bind({'alt', 'shift'}, 'tab', alttab.prev)

hs.hotkey.bind({'alt'}, 'f', keyentry.pressRight)
hs.hotkey.bind({'alt'}, 'b', keyentry.pressLeft)
hs.hotkey.bind({'alt'}, 'p', keyentry.pressUp)
hs.hotkey.bind({'alt'}, 'n', keyentry.pressDown)

-- hotkeys on primary
hs.hotkey.bind(modifierPrimary, 'k', move.fullscreen)
hs.hotkey.bind(modifierPrimary, 'h', move.left)
hs.hotkey.bind(modifierPrimary, 'l', move.right)

hs.hotkey.bind(modifierPrimary, '1', move.screen1)
hs.hotkey.bind(modifierPrimary, '2', move.screen2)
hs.hotkey.bind(modifierPrimary, '3', move.screen3)
hs.hotkey.bind(modifierPrimary, '7', move.screen1)
hs.hotkey.bind(modifierPrimary, '8', move.screen2)
hs.hotkey.bind(modifierPrimary, '9', move.screen3)

hs.hotkey.bind(modifierPrimary, 'left', spaces.left)
hs.hotkey.bind(modifierPrimary, 'right', spaces.right)

hs.hotkey.bind(modifierPrimary, 's', hotkeys.screensaver)

hs.hotkey.bind(modifierPrimary, 'o', positions.restoreWindowPos)
hs.hotkey.bind(modifierPrimary, 'p', positions.positionWindowsByPreset)

hs.hotkey.bind(modifierPrimary, 'u', chain.includeInChain)
hs.hotkey.bind(modifierPrimary, 'i', chain.createChain)

hs.hotkey.bind(modifierPrimary, 'c', chooser.harpoList)
hs.hotkey.bind(modifierPrimary, 'v', chooser.harpoPaste)
hs.hotkey.bind(modifierPrimary, 'b', chooser.harpoPasteUser)

hs.hotkey.bind(modifierPrimary, 'a', saveapps.restore)
hs.hotkey.bind(modifierPrimary, 'z', saveapps.save)
hs.hotkey.bind(modifierPrimary, 'x', hs.caffeinate.systemSleep)

-- hotkeys on secondary
hs.hotkey.bind(modifierSecondary, 'p', pin.pinFocused)

hs.hotkey.bind(modifierSecondary, 'h', move.moveWindowOneScreenWest)
hs.hotkey.bind(modifierSecondary, 'l', move.moveWindowOneScreenEast)

-- hotkeys for ,.- keys (sort of related)
hs.hotkey.bind(modifierPrimary, ',', hs.spotify.previous)
hs.hotkey.bind(modifierPrimary, '.', hs.spotify.playpause)
hs.hotkey.bind(modifierPrimary, '-', hs.spotify.next)
hs.hotkey.bind(modifierSecondary, ',', hs.spotify.rw)
hs.hotkey.bind(modifierSecondary, '-', hs.spotify.ff)

hs.hotkey.bind({"alt", "shift", 'cmd'}, ',', hotkeys.spotifyBack)
hs.hotkey.bind({"alt", "shift", 'cmd'}, '-', hotkeys.spotifyForward)

hs.hotkey.bind(modifierComplicated, ',', hotkeys.volumeDown)
hs.hotkey.bind(modifierComplicated, '.', hotkeys.toggleMute)
hs.hotkey.bind(modifierComplicated, '-', hotkeys.volumeUp)

-- hotkeys on complicated
hs.hotkey.bind(modifierComplicated, 'r', hs.reload)

hs.alert.show("Hammerspoon config loaded")
