-- create customized focus chains

local export = {}
local l = {}

local chains = {}

function export.focusNextInChain()
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

function export.switchChain()
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

function export.createChain()
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

function export.includeInChain()
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

return export
