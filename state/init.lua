local lfs = require"lfs" -- luarocks install luafilesystem

-- Localization - for speed and awesome!
local tostring,assert,loadfile,pairs,type,error = tostring,assert,loadfile,pairs,type,error
-- Libraries:
local ioOpen = io.open
local osGetenv = os.getenv
local stringFormat,stringDump,stringChar = string.format,string.dump,string.char
local tableInsert,tableConcat = table.insert,table.concat

--- Solid state for Lua.
-- @license Public Domain
-- @author Linus Sjögren <thelinx@unreliablepollution.net>
-- @version 1.2.0-PREVIEW
module("state")
local stateDir = stateDir or ""
if stateDir == "" then
    if osGetenv("HOME") then
        stateDir = osGetenv("HOME").."/.luastates/"
    elseif osGetenv("appdata") then
        stateDir = osGetenv("appdata").."\\LuaStates\\"
    else
        error("Cannot determine OS, please submit a bug report to http://github.com/TheLinx/luaSolidState/issues")
    end
end
if not lfs.attributes(stateDir) then
    lfs.mkdir(stateDir)
end

local function serializevalue(v, d)
    local d = d or {}
    local t = type(v)
    if t == "string" then
        v:gsub("\\\n", "\\n"):gsub("\r", "\\r"):gsub(stringChar(26), "\"..string.char(26)..\"")
        return stringFormat("%q", v)
    elseif t == "number" then
        return stringFormat("%d", v)
    elseif t == "boolean" then
        return stringFormat("%s", tostring(v))
    elseif t == "table" then
        if d[v] then
            return "{...}"
        end
        d[v] = true
        return stringFormat("%s", serializetable(v, d))
    elseif t == "function" then
        return "loadstring([[\n"..stringDump(v).."\n]])"
    elseif t == "nil" then
        return stringFormat("nil", i)
    else
        error("can't serialize variable of type '"..t.."'", 4)
    end
end
function serializetable(table, d)
    local s = {}
    tableInsert(s, "{")
    for k,v in pairs(table) do
        tableInsert(s, "["..serializevalue(k, d).."]=")
        tableInsert(s, serializevalue(v, d))
        tableInsert(s, ",")
    end
    if s[#s] == "," then
        s[#s] = nil
    end
    tableInsert(s, "}")
    return tableConcat(s)
end

--- Store a table.
-- @param id Identifier - used for loading the state later.
-- @param table The table to store.
function store(id, table)
    local fhand = ioOpen(stateDir..id, "w")
    local fcont = "return "..serializetable(table)
    fhand:write(fcont)
    fhand:close()
end

--- Load a table.
-- If the load is unsuccessful, the first return value will be nil and
-- the second value will be an error message.
-- @param id Identifier - the one you used when saving the table.
function load(id)
    local f,e = loadfile(stateDir..id)
    if f then
        return f()
    else
        return nil,e
    end
end
