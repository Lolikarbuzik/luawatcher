-- LuaWatcher build file
local ____LW_RT = require("runtime/luawatcher")
local ____LUAWATCHER = ____LW_RT.new()

local function test()
    
    local x = 5
    
    print("x is in scope test", x)
    
    do
        local z = 10
        print("z is in scope test/?", z)
    end
    print("z is not in scope test", z)
end

test()

print("x is not in scope", x)
do
    local y = 5
    print("y is in this scope", y)
end
print("y is not in glob scope", y)


____LUAWATCHER:print_history()