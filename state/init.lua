local lfs = require"lfs" -- luarocks install luafilesystem
local table,string = table,string
local sf,env,ts,at,lf = string.format,os.getenv,tostring,assert,loadfile

--- Solid state for Lua.
module("state")
local stateDir = ""
if not stateDir then
	if env"HOME" then
		stateDir = env("HOME").."/.luastates/"
	elseif env"appdata" then
		stateDir = env("appdata").."\\LuaStates\\"
	else
		error("Cannot determine OS, please submit a bug report to http://github.com/TheLinx/luaSolidState/issues")
	end
end
if not lfs.attributes(stateDir) then
	lfs.mkdir(stateDir)
end

local function newStack()
	return {""} -- starts with an empty string
end
local function addString(stack, s)
	table.insert(stack, s) -- push 's' into the the stack
	for i=table.getn(stack)-1, 1, -1 do
		if string.len(stack[i]) > string.len(stack[i+1]) then
			break
		end
	stack[i] = stack[i]..table.remove(stack)
	end
end
local function popString(stack)
	stack[#stack] = nil
end

function serialize(i, v)
	local t = type(v)
	if t == "string" then
		v:gsub("\\\n", "\\n"):gsub("\r", "\\r"):gsub(string.char(26), "\"..string.char(26)..\"")
		return sf("[%q]=%q", i, v)
	elseif t == "number" then
		return sf("[%q]=%d", i, v)
	elseif t == "boolean" then
		return sf("[%q]=%s", i, ts(v))
	elseif t == "table" then
		return sf("[%q]=%s", i, serializeTable(v))
	elseif t == "nil" then
		return sf("[%q]=nil", i)
	end
end

function serializeTable(t)
	local s = newStack()
	addString(s, "{")
	for k,v in pairs(t) do
		addString(s, serialize(k,v))
		addString(s, ",")
	end
	popString(s)
	addString(s, "}")
	return table.concat(s)
end

function store(n, t)
	local fhand = io.open(stateDir..n, "w")
	local fcont = "return "..serializeTable(t)
	fhand:write(fcont)
	fhand:close()
end

function load(n)
	return at(lf(stateDir..n))()
end
