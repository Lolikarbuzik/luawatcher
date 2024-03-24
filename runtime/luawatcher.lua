---@diagnostic disable: need-check-nil
-- LuaWatcher.lua
-- Created by github.com/Lolikarbuzik
-- github.com/Lolikarbuzik/luawatcher
--! For roblox use rbxwatcher.lua

local function get_len(tbl)
    local len = 0
   
    for _, _ in pairs(tbl) do
        len = len + 1 
    end

    return len
end

local function key_to_index(t, key)
    local keys = {}
    for k, _ in pairs(t) do
        keys[k] = get_len(keys) + 1 
    end
    return keys[key]
end

local function pretty(value, indenting)
    local type = type(value)
    if type ~= "table" then
        return tostring(value)
    else
        indenting = indenting or 1
        local str = "{"
        local has_keys = get_len(value) ~= #value
        for key, v in pairs(value) do
            str = str .. (has_keys and " " .. key .. " = " or " ") 
                .. pretty(v, indenting + 1) 
                .. (
                    key_to_index(value, key) == get_len(value) 
                    and "" or ","
                )
        end 
        return str .. " }"
    end
end

-- local function get_key_by_value(tbl, value)
--     for key, v in pairs(tbl) do
--         if v == value then
--             return key
--         end 
--     end 
-- end

local function lprint(...)
    local msg = pretty({...})
    print("[LuaWatcher] ".. msg:sub(3, msg:len() - 2))
end

-- local function lerror(...)
--     lprint(...)
--     error("[LuaWatcher] Runtime termination", 1)
-- end

local HISTORY_TYPES = {
    INIT = 0,
    GET = 1,
    SET = 2,
    PAIRS = 3,
    CALL = 4
}

local Watcher = {
    history = {}
}
Watcher.__index = Watcher

function Watcher.new()
    local self = setmetatable({}, Watcher);
    return self;
end

function Watcher:get_history(name)
    return self.history[name]
end

function Watcher:print_history()
    for k, history in pairs(self.history) do
        lprint("obj \"".. k.."\": "..pretty(history))
    end
end

function Watcher:watch(object, name)
    self:__INIT(name, object)
    return self:invi_watch(object, name)
end

--- Doesnt call self:__INIT
function Watcher:invi_watch(object, name)
    if type(object) == "table" then
        return self:__watch_table(object, name)
    elseif type(object) == "function" then
        return self:__watch_function(object, name)
    else
        -- im too lazy to check for watched value types in rs
        return object
    end
end

function Watcher:__watch_function(func, name)
    return function(...)
        self:__CALL(name, ...)
        return Watcher:watch(func(...), "return_"..name)
    end
end

function Watcher:__watch_table(table, name)
    return setmetatable({}, {
        __pairs = function (t)
            self:__PAIRS(name, table)
            local index = 1;
            return function ()
                if index < #table then
                    index = index + 1
                    self:__GET(name, index, table)
                    return index - 1, self:invi_watch(table[index], index)
                end
            end
        end,
        __index = function (_, k)
            self:__GET(name, k, table)
            return self:invi_watch(table[k], k)
        end,
        __newindex = function (_, k, v)
            self:__SET(name, k, v, table)
            table[k] = self:invi_watch(v, k)
        end,
        __len = function (t)
            return #table
        end
    })
end

function Watcher:__INIT(name, v)
    self.history[name] = self.history[name] or {}
    self.history[name][#self.history[name]+1] = {
        type = HISTORY_TYPES.INIT,
        value = v,
    }
end

function Watcher:__CALL(name, ...)
    self.history[name][#self.history+1] = {
        type = HISTORY_TYPES.CALL,
        args = {...},
    }
end


function Watcher:__GET(name, k, v)
    self.history[name][#self.history+1] = {
        type = HISTORY_TYPES.GET,
        key = k,
        value = v,
    }
end

function Watcher:__SET(name, k, nv, v)
    self.history[name][#self.history+1] = {
        type = HISTORY_TYPES.SET,
        key = k,
        new_value = nv,
        value = v
    }
    return nv
end

function Watcher:__PAIRS(name, v)
    self.history[name][#self.history+1] = {
        type = HISTORY_TYPES.PAIRS,
        value = v
    }
end

return {
    new = Watcher.new,
    pretty_print = function (...)
        local s = ""
        for _, v in pairs({...}) do
            s = s .. pretty(v) .. "\t" 
        end
        print(s) 
    end
}