--!strict

-- Static remote handles. Required by both sides:
--   * on the server it creates the instances under ReplicatedStorage.packages.Net
--   * on the client it waits (up to 10s) for them to replicate
--
-- Require this module once at the top of your entry points so the instances
-- exist before anything fires them.

local Net = require("@game/ReplicatedStorage/packages/Net")

local Remotes = {
    CoinsChanged = Net:RemoteEvent("CoinsChanged"),
    GetServerTime = Net:RemoteFunction("GetServerTime"),
}

table.freeze(Remotes)

return Remotes
