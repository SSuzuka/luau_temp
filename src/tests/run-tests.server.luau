--!strict

-- Jest Lua entry point.
--
-- In Studio it runs on Play and exits with a status code (useful for
-- run-in-roblox in CI). In a live server it is a no-op, so it is safe to leave
-- the tests folder synced in production.
--
-- Requires the `EnableLoadModule` fast flag; see the README.

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

if not RunService:IsStudio() then
    return
end

-- Studio's Output window does not render ANSI escapes, so Jest's colored
-- reporter would show literal `[0m[7m[1m[32m` garbage. Chalk (used by the
-- reporter) disables styling when `_G.NOCOLOR` is set; it must be set before
-- the Jest package is required. This is the only supported switch — Jest has no
-- `colors` runCLI option — so `_G` is used deliberately here.
-- selene: allow(global_usage)
(_G :: any).NOCOLOR = true

local Jest = require("@game/ReplicatedStorage/packages/Jest")

local tests = ServerScriptService:WaitForChild("tests")

local status, result = Jest.runCLI(tests, {
    verbose = true,
    ci = false,
}, { tests }):awaitStatus()

if status == "Rejected" then
    warn(result)
end

local hasProcessService, ProcessService = pcall(function()
    return (game :: any):GetService("ProcessService")
end)

if hasProcessService then
    local passed = status == "Resolved"
        and result.results.numFailedTestSuites == 0
        and result.results.numFailedTests == 0
    ProcessService:ExitAsync(if passed then 0 else 1)
end
