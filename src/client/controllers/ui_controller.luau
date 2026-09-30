--!strict

local Players = game:GetService("Players")

local React = require("@game/ReplicatedStorage/packages/React")
local ReactRoblox = require("@game/ReplicatedStorage/packages/ReactRoblox")
local Remotes = require("@game/ReplicatedStorage/net/remotes")

local App = require("../ui/App")
local AppState = require("../state/app_state")

local UiController = {}

function UiController.start()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RootGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local root = ReactRoblox.createRoot(Instance.new("Folder"))
    root:render(ReactRoblox.createPortal(React.createElement(App), screenGui))

    Remotes.CoinsChanged.OnClientEvent:Connect(function(coins: number)
        AppState.coins(coins)
    end)

    task.spawn(function()
        while true do
            AppState.serverTime(Remotes.GetServerTime:InvokeServer())
            task.wait(5)
        end
    end)
end

return UiController
