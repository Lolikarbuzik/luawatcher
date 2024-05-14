-- LuaWatcher build file
local ____LW_RT = require("runtime/luawatcher")
local ____LUAWATCHER = ____LW_RT.new()

local function foo(x, y)
    return x + y
end

local foo2 = ____LUAWATCHER:watch(function(x,, "foo2") y, z)
    return x + y + z
end
____LUAWATCHER:print_history()