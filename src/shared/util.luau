--!strict

local Util = {}

function Util.clamp(value: number, min: number, max: number): number
    return math.clamp(value, min, max)
end

function Util.round(value: number, decimals: number?): number
    local factor = 10 ^ (decimals or 0)
    return math.round(value * factor) / factor
end

function Util.deepFreeze<T>(value: T): T
    if typeof(value) == "table" then
        local tbl = value :: { [any]: any }
        for _, child in tbl do
            Util.deepFreeze(child)
        end
        table.freeze(tbl)
    end
    return value
end

return Util
