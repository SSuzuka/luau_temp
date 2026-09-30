--!strict

-- Client entry point.
-- Modules under src/client/controllers are loaded and their `start()` method is
-- spawned by the RbxUtil Loader.

local Loader = require("@game/ReplicatedStorage/packages/Loader")

local controllersFolder = script.Parent:WaitForChild("controllers")

local controllers = Loader.LoadDescendants(controllersFolder)
Loader.SpawnAll(controllers, "start")

print("[client] booted")
