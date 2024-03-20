-- LuaWatcher.lua
-- Created by github.com/Lolikarbuzik
-- github.com/Lolikarbuzik/luawatcher
--! For roblox use rbxwatcher.lua

local function lprint(...)
    print("[LuaWatcher]",...)
end

local function lerror(msg)
    error("[LuaWatcher] " .. msg, 1)
end

-- TODO: maybe add more types?
local HistoryType = {
    INIT = 0,
    SET = 1,
    GET = 2,
    CALL = 3,
}

--! Watchers contain have a same history across all instances
local Watcher = {
    history = {}
}
setmetatable(Watcher, { __index = Watcher})

function Watcher.new()
    return setmetatable({}, { __index = Watcher })
end

function Watcher:view_watch(index)
    local history = self.history[index]
    if history == nil then
        lerror("Index out of range")
    end
    if history.type == HistoryType.SET then
        lprint("[" .. index .. "] Action SET", history.object, "property `"..history.property.."` to value", history.value)
    elseif history.type == HistoryType.CALL then
        lprint("[" .. index .. "] Action CALL function", history.func, "with arguments", history.args)
    elseif history.type == HistoryType.GET then
        lprint("[" .. index .. "] Action GET", history.object, "property `" .. history.property .. "`")
    elseif history.type == HistoryType.INIT then
        lprint("["..index.."] Action INIT", history.object,"->", history.value)
    else
        lerror("["..index.."] Action UNKNOWN")
    end

end

function Watcher:view_all()
    for i = 1, #self.history do
        self:view_watch(i)
    end
end

function Watcher:roll_back()
    for i = #self.history, 1, -1 do
        local history = self.history[i];
        -- Todo: Thats it lol
        if history.type == HistoryType.SET then
            history.object[history.property] = history.prev_value
        end
    end
end

-- Just a wrapper for Watcher:watch_unsafe but logs the error
-- If you want to watch a value and handle errors yourself use Watcher:watch_unsafe
-- Or if you dont care about the errors ;)
function Watcher:watch(value, id)
    local watched_val, success = self:watch_unsafe(value, id)
    if success == false then
        lerror("Watching only works for functions and tables got ".. type(value))
        return value
    end
    self.history[#self.history+1] = {
        type = HistoryType.INIT,
        value = value,
        object = watched_val
    }
    return watched_val
end

-- Watches the value
-- If value is function calls :watch_call
-- Else calls watch_obj
-- Use this for automatic watching values
function Watcher:watch_unsafe(value, id)
    if type(value) == "function" then
        return self:watch_call(value), true
    elseif type(value) == "table" then
        return self:watch_obj(value, id), true
    else
        return value, false
    end
end

function Watcher:watch_obj(object, id)
    local metatable = getmetatable(object) or {}

    metatable.__index = function (t, k)
        self.history[#self.history+1] = {
            type = HistoryType.GET,
            object = t,
            property = k,
        }
        return self:watch_unsafe(object[k])
    end
    metatable.__newindex = function (t, k, v)
        self.history[#self.history+1] = {
            type = HistoryType.SET,
            object = t,
            property = k,
            value = v,
            prev_value = object[k]
        }
        object[k] = v
    end

    metatable.__tostring = function (t)
        if id then
            return string.format("%s { ... }", id)
        end
        return tostring(object)
    end

    return setmetatable({}, metatable);
end

function Watcher:watch_call(func)
    return function (...)
        self.history[#self.history+1] = {
            type = HistoryType.CALL,
            func = func,
            args = {...}
        }

        return func(...);
    end
end

return Watcher