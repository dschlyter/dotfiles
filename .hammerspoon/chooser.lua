-- funcions that use chooser module

local export = {}
local l = {}

local shared = require "shared"

-- quick searchable commands
function export.quickCommands()
    local home = os.getenv("HOME")
    local freqcmd = home.."/bin/freqlist " ..home.."/.config/quickcommands"
    local output = os.capture(freqcmd, true)
    local lines = parse_lines(output)

    l.showChooser(lines, function(text, cmd)
        log.d("execute " .. cmd)

        os.capture(freqcmd .. " " .. text .. " " .. cmd)
        local output = os.capture(cmd, true)
        log.d(output)
    end)
end

-- finder search
function export.finderSearch()
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
        local fw = hs.window.focusedWindow()
        -- assume any modal dialog is finder, and open its dialog
        if not fw:isStandard() or fw:application():name() == "Finder" then
            hs.eventtap.event.newKeyEvent({'cmd', 'shift'}, 'g', true):post()
        end
        hs.eventtap.keyStrokes(dir)

    end)
    chooser:choices(choices)
    chooser:show()
end

function export.pasteAppClip()
    l.withClipFile(function(clipFile)
        local output = trim(os.capture("tail -r "..clipFile, true))
        local lines = parse_lines(output)

        l.showChooser(lines, function(text, cmd)
            l.enterText(text)
        end)
    end)
end

function export.copyAppClip()
    l.withClipFile(function(clipFile)
        local output = os.capture("echo $(pbpaste) >> " .. clipFile, true)
        hs.alert.show("Clip saved!")
    end)
end

function export.editAppClips()
    l.withClipFile(function(clipFile)
        local output = os.capture("open " .. clipFile, true)
        hs.alert.show(open)
    end)
end

function l.withClipFile(callback)
    shared.findFocused(function(window)
        local app = window:application():name()
        app = app:gsub(" ", "")
        local clipFile = os.getenv("HOME").."/.config/appclips-"..app
        callback(clipFile)
    end)
end

--- harpo integration
function export.harpoList()
    local output = trim(os.capture("~/.esh harpo list", true))
    local lines = parse_lines(output)

    l.showChooser(lines, function(text, cmd)
        -- local output = trim(os.capture("~/.esh harpo unlock "..text, true))
        -- log.d(output)
        hs.alert.show(text)
    end)
end

function export.harpoPaste()
    local output = trim(os.capture("~/.esh harpo last password", true))
    l.enterText(output)
end

function export.harpoPasteUser()
    local output = trim(os.capture("~/.esh harpo last username", true))
    l.enterText(output)
end

function l.enterText(text)
    if text and #text > 0 then
        hs.eventtap.keyStrokes(text)
    else
        hs.alert.show("nothing to enter")
    end
end

-- shared code
function l.showChooser(lines, callback)
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

return export
