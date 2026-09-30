--!strict

local JestGlobals = require("@game/ReplicatedStorage/packages/JestGlobals")

local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local Util = require("@game/ReplicatedStorage/shared/util")

describe("Util.clamp", function()
    it("clamps values into the given range", function()
        expect(Util.clamp(15, 0, 10)).toBe(10)
        expect(Util.clamp(-5, 0, 10)).toBe(0)
        expect(Util.clamp(5, 0, 10)).toBe(5)
    end)
end)

describe("Util.round", function()
    it("rounds to the requested number of decimals", function()
        expect(Util.round(1.2345, 2)).toBe(1.23)
        expect(Util.round(1.5)).toBe(2)
    end)
end)
