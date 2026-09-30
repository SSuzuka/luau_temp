--!strict

-- Server entry point.
-- Modules under src/server/services are loaded and their `start()` method is
-- spawned by the RbxUtil Loader, so load order does not matter.

local Loader = require("@game/ReplicatedStorage/packages/Loader")

local servicesFolder = script.Parent:WaitForChild("services")

local services = Loader.LoadDescendants(servicesFolder)
Loader.SpawnAll(services, "start")

print("[server] booted")
