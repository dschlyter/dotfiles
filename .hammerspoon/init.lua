-- Modified version of http://larryhynes.net/2015/04/a-minor-update-to-my-hammerspoon-config.html

-- Set up
---------

local modifierFocus = {"alt"}
local modifierPrimary = {"alt", "ctrl"}
local modifierSecondary = {"alt", "shift"}
local modifierComplicated = {"alt", "ctrl", "cmd"}

local modifierResize = {"alt", "ctrl"}
local modifierMoveScreen = {"alt", "shift"}
local modifierMoveScreenIndex = {"alt", "ctrl"}
local modifierMoveSpace = {"alt", "ctrl"}
local minimumMoveDistance = 10

hs.window.animationDuration = 0

local log = hs.logger.new('logger','debug')
local user = os.getenv('USER')

-- hjkl to switch window focus
------------------------------

hs.hotkey.bind(modifierFocus, 'k', function()
    orChain(focusDirection("North", false), function()
        focusWindowOnSameScreen(-1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'j', function()
    orChain(focusDirection("South", false), function()
        focusWindowOnSameScreen(1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'l', function()
    orChain(focusDirection("East", false), function()
      focusWindowOnSameScreen(1)
    end)
end)

hs.hotkey.bind(modifierFocus, 'h', function()
    orChain(focusDirection("West", false), function()
        focusWindowOnSameScreen(-1)
    end)
end)

-- alt tab between individual windows
-------------------------------------

-- crashes on startup, some kind of hammerspoon bug?
-- switcher_space = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{},
    -- {showTitles = false, showSelectedThumbnail = false})
-- hs.hotkey.bind({'alt'},'tab',nil,function()switcher_space:next()end)
-- hs.hotkey.bind({'alt', 'shift'},'tab',nil,function()switcher_space:previous()end)

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

-- j for fullscreen
-- hl for half screen
-- yinm for quarter window
--------------------------

hs.hotkey.bind(modifierResize, 'k', function()
    scaleFocused(0, 0, 1, 1)
end)

hs.hotkey.bind(modifierResize, 'h', function()
    orChain(scaleFocused(0, 0, 0.5, 1), moveWindowOneScreenWest)
end)

hs.hotkey.bind(modifierResize, 'l', function()
    orChain(scaleFocused(0.5, 0, 0.5, 1), moveWindowOneScreenEast)
end)

function scaleFocused(x, y, w, h)
    return findFocused(function(win)
        return scaleWindow(win, x, y, w, h)
    end)
end

function scaleWindow(win, x, y, w, h)
    local existingFrame = win:frame()
    local f = win:frame()
    local max = win:screen():frame()

    f.x = max.x + max.w * x
    f.y = max.y + max.h * y
    f.w = max.w * w
    f.h = max.h * h

    if not existingFrame:equals(f) then
        win:setFrame(f)
        storeWindowPos()
        return true
    end

    return false
end

function orChain(f1ret, f2)
    if not f1ret then
        f2()
    end
end

-- hl for sending to next/prev monitor
--------------------------------------

hs.hotkey.bind(modifierMoveScreen, 'h', function()
    moveWindowOneScreenWest()
end)


hs.hotkey.bind(modifierMoveScreen, 'l', function()
    moveWindowOneScreenEast()
end)

function moveWindowOneScreenWest()
    findFocused(function(win)
        win:moveOneScreenWest()
        storeWindowPos()
    end)
end

function moveWindowOneScreenEast()
    findFocused(function(win)
        win:moveOneScreenEast()
        storeWindowPos()
    end)
end

-- 123 for move to screen by index (better than above)
------------------------------------------------------

hs.hotkey.bind(modifierMoveScreenIndex, '1', function()
    moveFocusedWindowToScreen(1)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '2', function()
    moveFocusedWindowToScreen(2)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '3', function()
    moveFocusedWindowToScreen(3)
end)

-- duplicate keys for easier two hand access
hs.hotkey.bind(modifierMoveScreenIndex, '7', function()
    moveFocusedWindowToScreen(1)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '8', function()
    moveFocusedWindowToScreen(2)
end)

hs.hotkey.bind(modifierMoveScreenIndex, '9', function()
    moveFocusedWindowToScreen(3)
end)

function moveFocusedWindowToScreen(index)
    findFocused(function(win)
        moveWindowToScreen(win, index)
    end)
end

function orderedScreens()
    return sorted(hs.screen.allScreens(), function(t,a,b)
        return t[a]:position() < t[b]:position()
    end)
end

function moveWindowToScreen(window, index)
    local target = orderedScreens()[index]
    window:moveToScreen(target)
    storeWindowPos()
    return ret
end

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
function reloadConfig(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")

-- automatic reload does not always work - so allow manual reload
hs.hotkey.bind(modifierComplicated, 'r', function()
    hs.reload()
end)


-- hotkeys
----------

-- application focus hotkeys
hs.hotkey.bind(modifierFocus, 'space', function()
    focusNextWindow("iTerm2", "iTerm")
end)

hs.hotkey.bind(modifierFocus, 'c', function()
    focusNextWindow("Google Chrome")
end)

hs.hotkey.bind(modifierFocus, 'd', function()
    focusNextWindow("IntelliJ IDEA")
end)

hs.hotkey.bind(modifierFocus, 's', function()
    focusNextWindow("Spotify")
end)

function focusNextWindow(appName, launchName)
    if not launchName then
        launchName = appName
    end

    local windows = orderedWindows(appName)
    if hs.window.focusedWindow():application():title() == appName then
        if #windows > 1 then
            windows[2]:focus()
        else
            focusNext()
        end
    elseif #windows > 0 then
        windows[1]:focus()
    else
        hs.application.launchOrFocus(launchName)
    end
end

function orderedWindows(appName)
    local ret = {}
    local windows = hs.window.orderedWindows()
    for i,window in pairs(windows) do
        if window:application():title() == appName and window:isStandard() then
            ret[#ret + 1] = window
        end
    end
    return ret
end

function focusNext()
    local ordered = hs.window.orderedWindows()
    if #ordered > 1 then
        ordered[2]:focus()
    end
end

-- focus chrome with google inbox to quickly add a note
-- allow to quickly add a reminder and keep working on the current task
hs.hotkey.bind(modifierFocus, 'm', function()
    local windows = orderedWindows("Google Chrome")

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
end)

-- enable readline style word navigation
hs.hotkey.bind({'alt'}, 'f', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'right', true):post()
end)

hs.hotkey.bind({'alt'}, 'b', function()
    hs.eventtap.event.newKeyEvent({'alt'}, 'left', true):post()
end)

hs.hotkey.bind({'ctrl', 'alt'}, 's', function()
    hs.timer.doAfter(1, function()
        hs.caffeinate.startScreensaver()
    end)
end)

hs.hotkey.bind({'alt'}, 'p', function()
    hs.eventtap.event.newKeyEvent({}, 'up', true):post()
end)

hs.hotkey.bind({'alt'}, 'n', function()
    hs.eventtap.event.newKeyEvent({}, 'down', true):post()
end)

-- spotify and audio hotkeys
hs.hotkey.bind(modifierPrimary, ',', function()
    hs.spotify.previous()
end)

hs.hotkey.bind(modifierPrimary, '.', function()
    hs.spotify.playpause()
end)

hs.hotkey.bind(modifierPrimary, '-', function()
    hs.spotify.next()
end)

hs.hotkey.bind(modifierSecondary, ',', function()
    hs.spotify.rw()
end)

hs.hotkey.bind(modifierSecondary, '-', function()
    hs.spotify.ff()
end)

hs.hotkey.bind({"alt", "shift", 'cmd'}, ',', function()
    hs.spotify.setPosition(hs.spotify.getPosition() - 30)
end)

hs.hotkey.bind({"alt", "shift", 'cmd'}, '-', function()
    hs.spotify.setPosition(hs.spotify.getPosition() + 30)
end)

hs.hotkey.bind(modifierComplicated, ',', function()
    local device = hs.audiodevice.current().device
    local vol = math.max(0, device:outputVolume() - 5)
    device:setVolume(vol)
end)

hs.hotkey.bind(modifierComplicated, '.', function()
    local device = hs.audiodevice.current().device
    device:setMuted(not device:muted())
end)

hs.hotkey.bind(modifierComplicated, '-', function()
    local device = hs.audiodevice.current().device
    local vol = math.min(100, device:outputVolume() + 5)
    device:setVolume(vol)
end)

-- save and restore window positions when switching monitors
------------------------------------------------------------
local windowPositions = {}

function storeWindowPos()
    local screenCount = #hs.screen.allScreens()

    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local id = window:id()
        if id then -- finder bugs out in el capitan
            local key = screenCount .. "--" .. id
            windowPositions[key] = window:frame()
        end
    end
end

function restoreWindowPos()
    local screenCount = #hs.screen.allScreens()

    local windows = hs.window.visibleWindows()
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

-- pro tip: use listWindows from console to find correct names
local windowPresetTable = {}
windowPresetTable["iTerm2"] = "internal"
windowPresetTable["Spotify"] = "secondary"
windowPresetTable["IntelliJ IDEA"] = "main"
windowPresetTable["Eclipse"] = "main"
windowPresetTable["Google Chrome"] = "secondary"

function listWindows()
    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local name = window:application():name()
        log.i(name)
    end
end

function positionWindowsByPreset()
    local windows = hs.window.visibleWindows()
    for i,window in pairs(windows) do
        local name = window:application():name()
        local mapping = windowPresetTable[name]
        if mapping then
            -- moveWindowToScreen(window, index)
            local target = getScreenByMapping(mapping)
            window:moveToScreen(target)
            -- maximize
            scaleWindow(window, 0, 0, 1, 1)
        end
    end
    storeWindowPos()
end

function getScreenByMapping(mapping)
    -- the internal screen is currently the primary screen
    local internal = hs.screen.primaryScreen()

    local screens = orderedScreens()

    -- the main is the middlemost screen, but not the internal screen unless there is only one window
    local main = internal
    local closestDistance = #screens
    for k,screen in pairs(screens) do
        local midDistance = math.abs(math.ceil(#screens / 2) - k)
        if screen ~= internal and midDistance < closestDistance then
            closestDistance = midDistance
            main = screen
        end
    end

    -- the secondary is the first screen that is left, or internal if there is no such window
    local secondary = internal
    for k,screen in pairs(screens) do
        if screen ~= internal and screen ~= main then
            secondary = screen
        end
    end

    local ret = {["internal"]=internal, ["main"]=main, ["secondary"]=secondary}
    return ret[mapping]
end

hs.hotkey.bind(modifierResize, 'o', function()
    restoreWindowPos()
end)

hs.hotkey.bind(modifierResize, 'p', function()
    positionWindowsByPreset()
end)

-- quickly close and restore open apps (useful before user switching)
---------------------------------------------------------------------

local savedApps = {}

hs.hotkey.bind(modifierResize, 'a', function()
    restoreApps()
end)

hs.hotkey.bind(modifierResize, 'z', function()
    if not savedAppsExist() then
        hs.timer.doWhile(savedAppsExist, checkForAutoRestore, 15)
    else
        log.d("Not starting timer, there should already be one running")
    end
    saveApps()
    saveTimestamp()
end)

hs.hotkey.bind(modifierResize, 'x', function()
    hs.caffeinate.systemSleep()
end)

local lastWifi = "none"
local lastSave = 0
local lastScreenCount = nil
local saveFile = "/opt/data/hammerspoon-save"

function saveTimestamp()
    lastSave = os.time()
    lastWifi = getWifi()
    lastScreenCount = #hs.screen.allScreens()

    local f = io.open(saveFile, "w")
    if f then
        f:write(lastSave)
        f:close()
    else
        hs.alert.show("Error saving timestamp, write permission error?")
    end
end

function savedAppsExist()
    return #savedApps > 0
end

function checkForAutoRestore()
    if shouldAutorestore() then
        runAutorestore()
    end
end

function getWifi()
    return hs.wifi.currentNetwork("en0")
end

function shouldAutorestore()
    log.d("Checking for automatic restore of apps")
    if not savedAppsExist() then
        log.d("Restore: No saved apps")
        return false
    end

    local f = io.open(saveFile, "r")
    if f then
        local fileTime = f:read("*all")
        f:close()
        if tonumber(fileTime) <= lastSave then
            log.d("Restore: No more recent save")
            return false
        end
    end

    if getWifi() ~= lastWifi then
        log.d("Restore: Not on wifi " .. lastWifi)
        return false
    end

    local screenCount = #hs.screen.allScreens()
    if screenCount ~= lastScreenCount then
        log.d("Restore: Screen count is " .. screenCount .. ", waiting for " .. lastScreenCount)
        return false
    end

    return true
end

function runAutorestore()
    log.d("Initiating automatic restore")
    restoreApps()
end


function saveApps()
    local appsWithoutWindowsToKill = Set{"Docker"}
    local savedAppsBlacklist = Set{"Hammerspoon", "Finder"}

    for i,app in pairs(hs.application.runningApplications()) do
        if (#app:visibleWindows() > 0 or appsWithoutWindowsToKill[app:name()]) and not savedAppsBlacklist[app:name()] then
            table.insert(savedApps, app:name())
        end
    end

    log.d("Saving " .. #savedApps .. " apps " .. dumpList(savedApps))
    killAll(savedApps)
    -- killDocker()
    killSessions()
end

function restoreApps()
    if #savedApps > 0 then
        log.d("Restoring " .. #savedApps .. " saved apps " .. dumpList(savedApps))
        openAll(savedApps)
        savedApps = {}
        restartScrollReverser()
    else
        local defaultApps = {"IntelliJ IDEA", "Google Chrome", "iTerm", "Spotify"}
        log.d("Opening default apps" .. dumpList(defaultApps))
        openAll(defaultApps)
    end
end

function mapAppOpenName(appName)
    local mappedApps = {["iTerm2"]="iTerm"}

    local mappedName = mappedApps[appName]
    if mappedName then
        return mappedName
    else
        return appName
    end
end

function openAll(appsNames)
    for i,appName in pairs(appsNames) do
        local mappedName = mapAppOpenName(appName)
        hs.application.launchOrFocus(mappedName)
    end
end

function killAll(appNames)
    for i,appName in pairs(appNames) do
        local app = hs.application.get(appName)
        if app then
            app:kill()
        end
    end
end

-- TODO maybe remove if killing the docker application works well
function killDocker()
    log.d("Killing docker")
    os.execute('bash -c "export PATH="$PATH:/usr/local/bin"; /Users/'..user..'/bin/dnuke"')
end

function killSessions()
    log.d("Killing marked terminal sessions")
    os.execute('/Users/'..user..'/bin/session -k')
end

-- focus windows on the same screen
-----------------------------------

function focusWindowOnSameScreen(dir)
    local windows = windowsForCurrentScreen()
    if #windows > 1 then
        local newWindowIndex = indexMod(currentWindowIndex(windows) + dir, #windows)
        windows[newWindowIndex]:focus()
        -- focusLayerWithIndex(layers, newLayerIndex)
    end
end

function currentWindowIndex(windows)
    local focusedWindow = hs.window.focusedWindow()
    for i,window in ipairs(windows) do
        if window == focusedWindow then
            return i
        end
    end
    return 1
end

function windowsForCurrentScreen()
    local currScreen = hs.window.frontmostWindow():screen()
    local windows = hs.window.visibleWindows()
    local ret = {}
    for k,v in spairs(windows, windowOrdering) do
        if v:isStandard() and v:screen():id() == currScreen:id() then
            ret[#ret + 1] = v
        end
    end
    return ret
end

function windowOrdering(t, a, b)
    local aTitle = t[a]:application():title()
    local bTitle = t[b]:application():title()
    if aTitle ~= bTitle then
        return bTitle < aTitle
    end

    -- finder windows may have null id
    return default(t[b]:id(), 0) > default(t[a]:id(), 0)
end

-- create customized focus chains
---------------------------------

chains = {}

function focusNextInChain()
    if #chains <= 0 then
        hs.alert.show("No chain")
        return
    end

    local windowId = hs.window.focusedWindow():id()
    local currChain = chains[1]
    local newIndex = 1
    local chainIndex = indexOf(currChain, windowId)
    if chainIndex > 0 then
        newIndex = indexMod(chainIndex + 1, #currChain)
    else
        -- TODO maybe focus all windows?
    end

    local nextWindow = hs.window.get(currChain[newIndex])
    if nextWindow then
        nextWindow:focus()
    else
        if newIndex == 1 then
            table.remove(chains, 1)
        else
            table.remove(currChain, newIndex)
        end
    end
end

function switchChain()
    if (#chains <= 0) then
        hs.alert.show("No chain")
        return
    end

    local currChain = chains[1]
    table.remove(chains, 1)
    push(chains, currChain)

    local nextWindow = hs.window.get(chains[1][1])
    if nextWindow then
        nextWindow:focus()
        hs.alert.show("Next chain")
    else
        table.remove(chains, 1)
    end
end

function createChain()
    local focusedWindow = hs.window.focusedWindow()
    local windowId = focusedWindow:id()

    local currChainIndex = nil
    for i,chain in pairs(chains) do
        if chain[1] == windowId then
            currChainIndex = i
        end
    end

    if not currChainIndex then
        table.insert(chains, 1, {windowId})
        hs.alert.show("Chain created")
    else
        table.remove(chains, currChainIndex)
        hs.alert.show("Chain deleted")
    end
end

function includeInChain()
    if #chains <= 0 then
        createChain()
        return
    end
    local currChain = chains[1]

    local windowId = hs.window.focusedWindow():id()
    local currIndex = indexOf(currChain, windowId)
    if currIndex == -1 then
        push(currChain, windowId)
        hs.alert.show("Added to chain")
    elseif currIndex == 1 then
        hs.alert.show("Can't remove chain root")
    else
        remove(currChain, windowId)
        hs.alert.show("Removed from chain")
    end
end

hs.hotkey.bind(modifierFocus, 'u', focusNextInChain)
hs.hotkey.bind(modifierFocus, 'i', switchChain)
hs.hotkey.bind(modifierPrimary, 'u', includeInChain)
hs.hotkey.bind(modifierPrimary, 'i', createChain)

-- finder file search
---------------------

hs.hotkey.bind(modifierFocus, 'g', function()
    local output = os.capture(os.getenv("HOME") .. "/.fasd.sh -d -l -R", true)
    local lines = parse_lines(output)

    local choices = {}
    for k in pairs(lines) do
        local line = lines[k]
        choices[#choices + 1] = {
            ["text"] = line,
            ["subText"] = line:gsub(".*/",""),
            ["uuid"] = k
        }
    end

    local chooser = hs.chooser.new(function(res)
        if res == nil then
            return
        end

        local dir = res["text"]

        hs.window.frontmostWindow():focus()
        -- assume any modal dialog is finder, and open its dialog
        if not hs.window.focusedWindow():isStandard() then
            hs.eventtap.event.newKeyEvent({'cmd', 'shift'}, 'g', true):post()
        end
        hs.eventtap.keyStrokes(dir)

    end)
    chooser:choices(choices)
    chooser:show()
end)

--- harpo integration
---------------------

hs.hotkey.bind(modifierPrimary, 'c', function()
    local output = trim(os.capture("~/.esh harpo list", true))
    local lines = parse_lines(output)

    showChooser(lines, function(text, cmd)
        -- local output = trim(os.capture("~/.esh harpo unlock "..text, true))
        -- log.d(output)
        hs.alert.show(text)
    end)
end)

hs.hotkey.bind(modifierPrimary, 'v', function()
    local output = trim(os.capture("~/.esh harpo last password", true))
    enterText(output)
end)

hs.hotkey.bind(modifierPrimary, 'b', function()
    local output = trim(os.capture("~/.esh harpo last username", true))
    enterText(output)
end)

function enterText(text)
    if text and #text > 0 then
        hs.eventtap.keyStrokes(text)
    else
        hs.alert.show("nothing to enter")
    end
end


-- quick searchable commands
----------------------------

hs.hotkey.bind(modifierFocus, 'q', function()
    local home = os.getenv("HOME")
    local freqcmd = home.."/bin/freqlist " ..home.."/.config/quickcommands"
    local output = os.capture(freqcmd, true)
    local lines = parse_lines(output)

    showChooser(lines, function(text, cmd)
        log.d("execute " .. cmd)

        os.capture(freqcmd .. " " .. text .. " " .. cmd)
        local output = os.capture(cmd, true)
        log.d(output)
    end)
end)

function showChooser(lines, callback)
    local choices = {}
    for k in pairs(lines) do
        local line = lines[k]
        choices[#choices + 1] = {
            ["text"] = line:gsub(" .*$", ""),
            ["subText"] = line:gsub("^[^ ]+ ",""),
            ["uuid"] = k
        }
    end

    local chooser = hs.chooser.new(function(res)
        if res == nil then
            return
        end

        local text = res["text"]
        local subtext = res["subText"]

        callback(text, subtext)
    end)
    chooser:choices(choices)
    chooser:show()
end

-- base functionality that should really be in the language
-----------------------------------------------------------

--- list utils

function default(value, defaultValue)
    if value == nil then
        return defaultValue
    end

    return value
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

function sorted(t, order)
    local ret = {}
    for k,v in spairs(t,order) do ret[#ret+1] = v end
    return ret
end

function dumpList(list)
    return "[" .. table.concat(list, ", ") .. "]"
end

-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- http://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
function Set (list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

function keys(table)
    local ret = {}
    for k,v in pairs(table) do
        ret[#ret+1] = k
    end
    return ret
end

function indexOf(list, item)
    for i,listItem in pairs(list) do
        if listItem == item then
            return i
        end
    end
    return -1
end

function remove(list, item)
    local index = indexOf(list, item)
    if index > -1 then
        table.remove(list, index)
    end
end

function push(list, item)
    list[#list+1] = item
end

---

function indexMod(index, mod)
    if mod <= 1 then
        return 1
    end
    return ((index-1) % mod) + 1
end

-- https://stackoverflow.com/questions/132397/get-back-the-output-of-os-execute-in-lua
function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then
        return s
    end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

-- https://codea.io/talk/discussion/2118/split-a-string-by-return-newline
function parse_lines(str)
    local t = {}
    local function helper(line) table.insert(t, line) return "" end
    helper((str:gsub("(.-)\r?\n", helper)))
    return t
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- restart scroll revserser on sleep wakeup, since it stops working
-------------------------------------------------------------------

hs.caffeinate.watcher.new(function(event)
    if (event == hs.caffeinate.watcher.systemDidWake) then
        restartScrollReverser()
    end
end):start()

function restartScrollReverser()
    log.d("Restarting scroll reverser after sleep wakeup")
    os.execute('pkill "Scroll Reverser" && open "/Applications/Scroll Reverser.app"')
end
