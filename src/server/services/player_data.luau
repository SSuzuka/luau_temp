--!strict

-- Player persistence service backed by ProfileStore.
-- ProfileStore is vendored in src/server/vendor because it is not published on
-- Wally/pesde; see README for how to update it.

local Players = game:GetService("Players")

local Constants = require("@game/ReplicatedStorage/shared/constants")
local ProfileStore = require("../vendor/ProfileStore")
local Remotes = require("@game/ReplicatedStorage/net/remotes")
local Types = require("@game/ReplicatedStorage/shared/types")

type PlayerData = Types.PlayerData

local template: PlayerData = {
    coins = 0,
    level = 1,
    experience = 0,
}

local PlayerDataService = {}

local store = ProfileStore.New(Constants.PROFILE_STORE_NAME, template)
local profiles: { [Player]: any } = {}

local function onPlayerAdded(player: Player)
    local profile = store:StartSessionAsync(`Player_{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })

    if profile == nil then
        player:Kick("Your data could not be loaded. Please rejoin.")
        return
    end

    profile:AddUserId(player.UserId)
    profile:Reconcile()

    profile.OnSessionEnd:Connect(function()
        profiles[player] = nil
        player:Kick("Your data session ended. Please rejoin.")
    end)

    if player.Parent == Players then
        profiles[player] = profile
        Remotes.CoinsChanged:FireClient(player, profile.Data.coins)
    else
        profile:EndSession()
    end
end

local function onPlayerRemoving(player: Player)
    local profile = profiles[player]
    if profile ~= nil then
        profile:EndSession()
        profiles[player] = nil
    end
end

function PlayerDataService.getProfile(player: Player): any
    return profiles[player]
end

function PlayerDataService.addCoins(player: Player, amount: number)
    local profile = profiles[player]
    if profile == nil then
        return
    end

    profile.Data.coins += amount
    Remotes.CoinsChanged:FireClient(player, profile.Data.coins)
end

function PlayerDataService.start()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in Players:GetPlayers() do
        task.spawn(onPlayerAdded, player)
    end

    Remotes.GetServerTime.OnServerInvoke = function()
        return workspace:GetServerTimeNow()
    end

    -- Example: grant coins so the client UI has something to show.
    task.spawn(function()
        while true do
            task.wait(10)
            for player in profiles do
                PlayerDataService.addCoins(player, 1)
            end
        end
    end)
end

return PlayerDataService
