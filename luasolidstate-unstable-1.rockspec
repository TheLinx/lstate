package = "luaSolidState"
version = "unstable-1"
description = {
    summary = "Library for storing and loading data",
    detailed = [[
        luaSolidState is a Lua library that allows easy and painless
        storing of tables in Lua.
    ]],
    license = "Public Domain",
    homepage = "http://github.com/TheLinx/luaSolidState",
    maintainer = "Linus Sjögren <thelinx@unreliablepollution.net>"
}
dependencies = {
    "lua >= 5.1",
    "luafilesystem >= 1.5.0"
}
source = {
    url = "git://github.com/thelinx/luasolidstate.git"
}
build = {
    type = "builtin",
    modules = {
        state = "state/init.lua"
    }
}
