package = "state"
version = "1.0.0-2"
description = {
    summary = "Library for storing and loading data",
    detailed = [[
        lstate is a Lua library that allows easy and painless
        storing of tables in Lua.
    ]],
    license = "Public Domain",
    homepage = "http://github.com/TheLinx/lstate",
    maintainer = "Linus Sjögren <thelinx@unreliablepollution.net>"
}
dependencies = {
    "lua >= 5.1",
    "luafilesystem >= 1.5.0"
}
source = {
    url = "git://github.com/TheLinx/lstate.git",
    branch = "1.0.0"
}
build = {
    type = "builtin",
    modules = {
        state = "state/init.lua"
    }
}
