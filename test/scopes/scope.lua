-- Scope "test"
local function test()
    -- "test/x" = null
    local x = 5
    -- X should only exist in scope "test"
    print("x is in scope test", x)
    -- "test/?" = { "z" = null }
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

-- Example tree in test/scope_tree.json