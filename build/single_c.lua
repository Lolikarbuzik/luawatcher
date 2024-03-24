-- LuaWatcher build file
local ____LW_RT = require("runtime/luawatcher")
local ____LUAWATCHER = ____LW_RT.new()
local a = 1
a = 2
a = a + 4
assert(#____LUAWATCHER.history.a >= 2, "Doesnt contain INIT and SET events")
____LUAWATCHER:print_history()