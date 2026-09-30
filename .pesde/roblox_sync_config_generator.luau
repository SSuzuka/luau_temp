-- Self-contained Rojo sync config generator for pesde.
-- pesde calls this as: lune run .pesde/roblox_sync_config_generator.luau <packageDir> <file...>
--
-- If a default.project.json already exists (as it does in this template), this
-- is a no-op: we never want pesde to overwrite the hand-written project tree.
-- It only generates a config when the file is missing, so the project still
-- works if you delete it and re-run `pesde install`.

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local PLATFORM_SEP = if process.os == "windows" then "\\" else "/"

local packageDirectory = process.args[1] or process.cwd
local files = {}
for index = 2, #process.args do
    files[#files + 1] = process.args[index]
end

local syncConfigPath = `{packageDirectory}{PLATFORM_SEP}default.project.json`
if fs.isFile(syncConfigPath) then
    return
end

local tree = {}
for _, file in files do
    local name = string.gsub(file, "%.luau?$", "")
    if name == "init" then
        tree["$path"] = name
        continue
    end
    tree[name] = { ["$path"] = file }
end

if not tree["$path"] then
    tree["$className"] = "Folder"
end

if not tree["roblox_packages"] then
    tree["roblox_packages"] = { ["$path"] = { optional = "roblox_packages" } }
end

if not tree["roblox_server_packages"] then
    tree["roblox_server_packages"] = { ["$path"] = { optional = "roblox_server_packages" } }
end

local name = string.match(packageDirectory, "[^\\/]+$")
fs.writeFile(syncConfigPath, serde.encode("json", { name = name, tree = tree }, true))
