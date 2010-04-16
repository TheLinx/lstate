local lfs = require"lfs" -- luarocks install luafilesystem
local io = io
local sf,env,ts,at,lf,ps,te,err = string.format,os.getenv,tostring,assert,loadfile,pairs,type,error
local ti,tn,sl,tr,sc,tc = table.insert,table.getn,string.len,table.remove,string.char,table.concat

--- Solid state for Lua.
module("state")
local stateDir = stateDir or ""
if stateDir == "" then
    if env"HOME" then
        stateDir = env("HOME").."/.luastates/"
    elseif env"appdata" then
        stateDir = env("appdata").."\\LuaStates\\"
    else
        err("Cannot determine OS, please submit a bug report to http://github.com/TheLinx/luaSolidState/issues")
    end
end
if not lfs.attributes(stateDir) then
    lfs.mkdir(stateDir)
end

local function newStack()
    return {""} -- starts with an empty string
end
local function addString(stack, s)
    ti(stack, s) -- push 's' into the the stack
    for i=tn(stack)-1, 1, -1 do
        if sl(stack[i]) > sl(stack[i+1]) then
            break
        end
    stack[i] = stack[i]..tr(stack)
    end
end
local function popString(stack)
    stack[#stack] = nil
end

function serializeValue(v)
    local t = te(v)
    if t == "string" then
        v:gsub("\\\n", "\\n"):gsub("\r", "\\r"):gsub(sc(26), "\"..string.char(26)..\"")
        return sf("%q", v)
    elseif t == "number" then
        return sf("%d", v)
    elseif t == "boolean" then
        return sf("%s", ts(v))
    elseif t == "table" then
        return sf("%s", i, serializeTable(v))
    elseif t == "nil" then
        return sf("nil", i)
    end
end
function serializeTable(t)
    local s,sv = newStack(),serializeValue
    addString(s, "{")
    for k,v in ps(t) do
        addString(s, "["..sv(k).."]=")
        addString(s, sv(v))
        addString(s, ",")
    end
    popString(s)
    addString(s, "}")
    return tc(s)
end

--- Store a table.
-- @param n Identifier - used for loading the state later.
-- @param t The table to store.
function store(n, t)
    local fhand = io.open(stateDir..n, "w")
    local fcont = "return "..serializeTable(t)
    fhand:write(fcont)
    fhand:close()
end

--- Load a table.
-- If the load is unsuccessful, the first return value will be nil and
-- the second value will be an error message.
-- @param n Identifier - the one you used when saving the table.
function load(n)
    local f,e = lf(stateDir..n)
    if f then
        return f()
    else
        return nil,e
    end
end
