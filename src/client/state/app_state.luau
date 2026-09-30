--!strict

-- Global, client-side reactive state (Charm atoms).
-- Components subscribe with ReactCharm.useAtom(AppState.someAtom).

local Charm = require("@game/ReplicatedStorage/packages/Charm")

local AppState = {
    coins = Charm.atom(0),
    serverTime = Charm.atom(0),
}

return AppState
