-- RbxWatcher.lua
-- Created by github.com/Lolikarbuzik
-- github.com/Lolikarbuzik/luawatcher
--! This version of the LuaWatcher only watches made changes for Roblox instances
--! If you want to watch for value changes / calls / inits / gets use the luawatcher.lua

-- Util
local function lprint(...)
    print("[LuaWatcher]",...)
end

local function lerror(msg)
    error("[LuaWatcher] " .. msg, 1)
end

-- TODO: maybe add more types?
local ChangeType = {
    PROPERTY = 0,
    ATTRIBUTE = 1,  
    CHILD_ADDED = 2,
    CHILD_REMOVED = 3
}

local Watcher = {
    history = {},
    watches = {}
}
setmetatable(Watcher, { __index = Watcher })

function Watcher.new()
    local self = setmetatable({
        history = {},
        watches = {}
    }, {__index = Watcher})
    return self
end

function msg_create(index: number, instance: Instance,  msg: string)
    return "[" .. index .. "] " .. instance.Name .. " " .. msg
end

function Watcher:view_watch(instance: Instance, index: number)
    local ihistory = self.history[instance]
    if ihistory == nil then
        return lerror("Index out of bounds")
    end
    local change = ihistory[index]
    if change.type == ChangeType.ATTRIBUTE then
        lprint(msg_create(index, instance, "Attribute changed: ".. change.name.. " from ".. tostring(change.prev_value).. " to ".. tostring(change.value)))
    elseif change.type == ChangeType.PROPERTY then
        lprint(msg_create(index, instance, "Property changed: ".. change.name.. " from ".. tostring(change.prev_value).. " to ".. tostring(change.value)))
    elseif change.type == ChangeType.CHILD_ADDED then
        lprint(msg_create(index, instance, "Child added: ".. tostring(change.child)))
    elseif change.type == ChangeType.CHILD_REMOVED then
        lprint(msg_create(index, instance, "Child removed: ".. tostring(change.child)))
    else
        lerror("unknown change type ")
    end
end

function Watcher:view_all(instance: Instance)
    local ihistory = self.history[instance]
    for i = 1, #ihistory do
        self:view_watch(instance, i)
    end
end

function Watcher:watch(instance: Instance)
    print("watching", instance)
    local id = instance
    self.history[id] = {} 
    local ihistory = self.history[id]
    local copy_instance = instance:Clone()
    for child in instance:GetDescendants() do
        self:watch(child)   
    end
    local conn1 = instance.AttributeChanged:Connect(function(attributeName)
        pcall(function()
            ihistory[#ihistory+1] = {
                type = ChangeType.ATTRIBUTE, 
                name = attributeName, 
                prev_value = copy_instance:GetAttribute(attributeName),
                value = instance:GetAttribute(attributeName)
            }
            copy_instance:SetAttribute(attributeName, instance:GetAttribute(attributeName))
        end)
    end)

    local conn2 = instance.Changed:Connect(function(property)
        pcall(function()
            ihistory[#ihistory+1] = {
                type = ChangeType.PROPERTY, 
                name = property, 
                prev_value = copy_instance[property],
                value = instance[property]
            }
            -- print(ihistory[#ihistory])
            copy_instance[property] = instance[property]
        end)
    end)

    local conn3 = instance.ChildAdded:Connect(function(child)
        -- print("added child")
        ihistory[#ihistory+1] = {
            type = ChangeType.CHILD_ADDED,
            value = child
        }
        self:watch(child)
    end)

    local conn4 = instance.ChildRemoved:Connect(function(child)
        ihistory[#ihistory+1] = {
            type = ChangeType.CHILD_REMOVED,
            value = child:Clone()
        }
        self:stop_watch(child)
    end)

    self.watches[id] = {conn1, conn2, conn3, conn4} 
end

function Watcher:stop_watch(instance: Instance)
    print("stopped watching", instance)
    local watches = self.watches[instance]
    if watches == nil then
        return
    end
    watches[1]:Disconnect()
    watches[2]:Disconnect()
    watches[3]:Disconnect()
    watches[4]:Disconnect()
end

function Watcher:roll_back(instance: Instance)
    local ihistory = self.history[instance]
    -- Goes from bottom to top
    -- Or earliest to latest
    print("ROLLING BACK", instance)
    for i = #ihistory, 1, -1 do
        self:roll_back_step(instance, ihistory[i])
    end
end

function Watcher:roll_back_step(instance: Instance, change)
    pcall(function()
        if change.type == ChangeType.ATTRIBUTE then
            instance:SetAttribute(change.name, change.prev_value)
        elseif change.type == ChangeType.PROPERTY then
            instance[change.name] = change.prev_value
        elseif change.type == ChangeType.CHILD_ADDED then
            change.value:Remove()
        elseif change.type == ChangeType.CHILD_REMOVED then
            change.value.Parent = instance
        end
        game:GetService("RunService").Heartbeat:Wait();
    end)
end

return Watcher