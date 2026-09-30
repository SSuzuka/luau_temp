-- Self-contained sourcemap generator for pesde.
-- pesde calls this as: lune run .pesde/sourcemap_generator.luau <packageDir>
--
-- It prints a Rojo sourcemap for the project to stdout, which pesde captures to
-- resolve Wally package types. Requires `rojo` on PATH (installed via rokit).

local fs = require("@lune/fs")
local process = require("@lune/process")

local PLATFORM_SEP = if process.os == "windows" then "\\" else "/"

local packageDirectory = process.args[1] or process.cwd
local projectFile = `{packageDirectory}{PLATFORM_SEP}default.project.json`

if not fs.isFile(projectFile) then
    return
end

process.exec("rojo", { "sourcemap", packageDirectory }, {
    cwd = process.cwd,
    env = process.env,
    stdio = "forward",
})
