-- this gets ignored 12.05.2024
local function foo(x, y)
    return x + y
end
-- this bugs out `foo2 = :watch(function(x, y, z))\n rest of fn body` 12.05.2024
local foo2 = function(x, y, z)
    return x + y + z
end