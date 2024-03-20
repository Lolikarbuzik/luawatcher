# LuaWatcher

## Library for watching lua changes / roblox game changes!

## Lua

```lua
local watcher = Watcher.new()
local players = watcher:watch({
    "me",
    "you"
}, "players") -- Identifier for the watched value

players[1] = "0 people"
watcher:view_all()
watcher:roll_back()
print(players[1])
```

## Roblox

```lua
local RbxWatcher = require(Path.To.RbxWatcher)
local watcher = RbxWatcher.new()
local target = Path.To.Instance
watcher:watch(target)
task.wait(5)
watcher:stop_watch(target)
watcher:roll_back(target)
```
