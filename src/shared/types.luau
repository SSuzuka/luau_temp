--!strict

-- Shared data shapes used across the client/server boundary.
-- Keep this file free of runtime code so it is cheap to require anywhere.

export type PlayerData = {
    coins: number,
    level: number,
    experience: number,
}

-- Payload contracts for each RemoteEvent declared in src/net/remotes.luau.
export type RemoteEvents = {
    CoinsChanged: (coins: number) -> (),
}

-- Payload contracts for each RemoteFunction declared in src/net/remotes.luau.
export type RemoteFunctions = {
    GetServerTime: () -> number,
}

return {}
