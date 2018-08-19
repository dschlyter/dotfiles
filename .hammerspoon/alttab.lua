local export = {}
local l = {}

switcher_space = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{},
{showTitles = false, showSelectedThumbnail = false})

export.next = function() 
    switcher_space:next()
end

export.prev = function() 
    switcher_space:previous()
end

return export
