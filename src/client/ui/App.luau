--!strict

local React = require("@game/ReplicatedStorage/packages/React")
local ReactCharm = require("@game/ReplicatedStorage/packages/ReactCharm")

local AppState = require("../state/app_state")

local e = React.createElement

local function App()
    local coins = ReactCharm.useAtom(AppState.coins)
    local serverTime = ReactCharm.useAtom(AppState.serverTime)

    return e("ScreenGui", {
        Name = "App",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    }, {
        Frame = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0.05),
            Size = UDim2.fromOffset(240, 72),
            BackgroundColor3 = Color3.fromRGB(24, 24, 32),
            BorderSizePixel = 0,
        }, {
            Corner = e("UICorner", { CornerRadius = UDim.new(0, 10) }),
            Padding = e("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
            }),
            Coins = e("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.5, 0),
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                TextColor3 = Color3.fromRGB(255, 214, 92),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = `Coins: {coins}`,
            }),
            Time = e("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0.5, 0),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(170, 170, 190),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = `Server time: {math.floor(serverTime)}`,
            }),
        }),
    })
end

return App
