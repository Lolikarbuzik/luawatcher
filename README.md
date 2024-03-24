# LuaWatcher

## Library for watching lua changes / roblox game changes!

## What should i use?
Use LuaWatcher for ___**tables**___, functions calls
### LuaWatcher only supports tables and functions 
Use RbxWatcher for ___**roblox instances**___
## Lua

```lua
local LuaWatcher = require("luawatcher")
local watcher = LuaWatcher.new()
local players = watcher:watch({
    "p1",
    "p2"
}, "players") -- Display name for the watched value

players[1] = "rbxwatcher"
watcher:view_all()
print(players[1]) -- "rbxwatcher"
watcher:roll_back()
print(players[1]) -- "p1"
```

## Roblox

```lua
local RbxWatcher = require(Path.To.RbxWatcher)
local watcher = RbxWatcher.new()
local target = Path.To.Instance
watcher:watch(target) -- In studio try moving the object and wait 5 secs to see it roll back
task.wait(5)
watcher:stop_watch(target)
watcher:roll_back(target)
```
