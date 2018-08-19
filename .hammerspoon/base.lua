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

-- functional helpers

function orChain(f1ret, f2)
    if not f1ret then
        f2()
    end
end
