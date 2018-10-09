-- quickly close and restore open apps (useful before user switching)

local export = {}
local l = {}

local user = os.getenv('USER')
local savedApps = {}

local startup = require "startup"

function export.restore()
    l.restoreApps()
end

function export.save()
    if not l.savedAppsExist() then
        hs.timer.doWhile(l.savedAppsExist, l.checkForAutoRestore, 15)
    else
        log.d("Not starting timer, there should already be one running")
    end
    l.saveApps()
    l.saveTimestamp()
end

local lastWifi = "none"
local lastSave = 0
local lastScreenCount = nil
local saveFile = "/opt/data/hammerspoon-save"

function l.saveTimestamp()
    lastSave = os.time()
    lastWifi = l.getWifi()
    lastScreenCount = #hs.screen.allScreens()

    local f = io.open(saveFile, "w")
    if f then
        f:write(lastSave)
        f:close()
    else
        hs.alert.show("Error saving timestamp, write permission error?")
    end
end

function l.savedAppsExist()
    return #savedApps > 0
end

function l.checkForAutoRestore()
    if l.shouldAutorestore() then
        l.runAutorestore()
    end
end

function l.getWifi()
    return hs.wifi.currentNetwork("en0")
end

function l.shouldAutorestore()
    log.d("Checking for automatic restore of apps")
    if not l.savedAppsExist() then
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

    if l.getWifi() ~= lastWifi then
        log.d("Restore: Not on wifi " .. lastWifi)
        return false
    end

    local screenCount = #hs.screen.allScreens()
    if screenCount ~= lastScreenCount then
        log.d("Restore: Screen count is " .. screenCount .. ", waiting for " .. lastScreenCount)
        return false
    end
    log.d("Restore: Screen count is " .. screenCount .. ", matching " .. lastScreenCount)

    return true
end

function l.runAutorestore()
    log.d("Initiating automatic restore")
    l.restoreApps()
end


function l.saveApps()
    local appsWithoutWindowsToKill = Set{"Docker"}
    local savedAppsBlacklist = Set{"Hammerspoon", "Finder"}

    for i,app in pairs(hs.application.runningApplications()) do
        if (#app:visibleWindows() > 0 or appsWithoutWindowsToKill[app:name()]) and not savedAppsBlacklist[app:name()] then
            table.insert(savedApps, app:name())
        end
    end

    log.d("Saving " .. #savedApps .. " apps " .. dumpList(savedApps))
    l.killAll(savedApps)
    -- l.killDocker()
    l.killSessions()
end

function l.restoreApps()
    if #savedApps > 0 then
        log.d("Restoring " .. #savedApps .. " saved apps " .. dumpList(savedApps))
        openAll(savedApps)
        savedApps = {}
        startup.restartScrollReverser()
    else
        local defaultApps = {"IntelliJ IDEA", "Google Chrome", "iTerm", "Spotify"}
        log.d("Opening default apps" .. dumpList(defaultApps))
        openAll(defaultApps)
    end
end

function l.mapAppOpenName(appName)
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
        local mappedName = l.mapAppOpenName(appName)
        hs.application.launchOrFocus(mappedName)
    end
end

function l.killAll(appNames)
    for i,appName in pairs(appNames) do
        local app = hs.application.get(appName)
        if app then
            app:kill()
        end
    end
end

-- TODO maybe remove if killing the docker application works well
function l.killDocker()
    log.d("Killing docker")
    os.execute('bash -c "export PATH="$PATH:/usr/local/bin"; /Users/'..user..'/bin/dnuke"')
end

function l.killSessions()
    log.d("Killing marked terminal sessions")
    os.execute('/Users/'..user..'/bin/session -k')
end

return export

