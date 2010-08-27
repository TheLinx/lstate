local lfs = require"lfs" -- luarocks install luafilesystem
local lbina,luabins = pcall(function() return require"luabins" end)

-- Localization - for speed and awesome!
local tostring,assert,loadstring,pairs,type,error = tostring,assert,loadstring,pairs,type,error
-- Libraries:
local ioOpen = io.open
local osGetenv = os.getenv
local stringFormat,stringDump,stringChar = string.format,string.dump,string.char
local tableInsert,tableConcat = table.insert,table.concat

--- Solid state for Lua.
-- @license Public Domain
-- @author Linus Sjögren <thelinx@unreliablepollution.net>
-- @version 1.3.2
module("state")
_VERSION = "1.3.2"
_AUTHOR = "Linus Sjögren <thelinx@unreliablepollution.net>"

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

local function writefile(fid, contents)
    local fhand = ioOpen(stateDir..fid, "w")
    fhand:write(contents)
    fhand:close()
end
local function readfile(fid)
    local fhand,err = ioOpen(stateDir..fid, "r")
    if not fhand then
		return nil, err
	end
    local s = fhand:read("*all")
    fhand:close()
    return s
end

--- Store a table.
-- @param id Identifier - used for loading the state later.
-- @param table The table to store.
function store(id, table)
    local fcont = "return "..serializetable(table)
    writefile(id, fcont)
end

--- Load a table.
-- If the load is unsuccessful, the first return value will be nil and
-- the second value will be an error message.
-- @param id Identifier - the one you used when saving the table.
function load(id)
    local fcont = readfile(id)
    if not fcont then return nil, "no such save" end
    local func,err = loadstring(fcont)
    if func then
		return func()
	else
		return nil, err
	end
end

luabinsenabled = false
if lbina then
	luabinsenabled = true
	--- Store a table's binary representation.
	-- Requires LuaBins.
	-- @param id Identifier - used for loading the state later.
	-- @param table The table to store.
	function storebinary(id, table)
		local fcont = luabins.save(table)
		writefile(id, fcont)
	end
	--- Load a table's binary representation.
	-- If the load is unsuccessful, the first return value will be nil
	-- and the second value will be an error message.
	-- Requires LuaBins.
	-- @param id Identifier - the one you used when saving the table.
	function loadbinary(id)
		local fcont = readfile(id)
		return luabins.load(fcont)
	end
end
