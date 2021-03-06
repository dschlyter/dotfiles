local export = {}
local l = {}

-- restart scroll revserser on sleep wakeup, since it stops working
-------------------------------------------------------------------

hs.caffeinate.watcher.new(function(event)
    if (event == hs.caffeinate.watcher.systemDidWake) then
        export.restartScrollReverser()
    end
end):start()

function export.restartScrollReverser()
    log.d("Restarting scroll reverser after sleep wakeup")
    os.execute('pkill "Scroll Reverser" && open "/Applications/Scroll Reverser.app"')
end

return export
