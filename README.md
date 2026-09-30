# luau_temp — Luau/Roblox game template

**English** · [Русский](README.ru.md)

A Roblox game template written in Luau: strict typing, reactive UI, player data
persistence, networking and tests. All tooling is installed and verified —
`pesde install`, `rojo sourcemap`, `selene`, `stylua` and `luau-lsp analyze` pass
with zero errors.

## Stack

| Layer | Tool | Version |
| --- | --- | --- |
| Toolchain manager | [Rokit](https://github.com/rojo-rbx/rokit) | `1.2.0` |
| Package manager | [pesde](https://pesde.dev) | `0.7.4` |
| Sync | [Rojo](https://rojo.space) | `7.7.0` |
| Linter | [Selene](https://github.com/Kampfkarren/selene) | `0.31.0` |
| Formatter | [StyLua](https://github.com/JohnnyMorganz/StyLua) | `2.5.2` |
| Standalone scripts | [Lune](https://lune-org.github.io/docs) | `0.10.5` |
| Language server | [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | `1.70.1` |
| UI | [React Lua](https://github.com/jsdotlua/react-lua) | `17.2.1` |
| State | [Charm](https://github.com/littensy/charm) | `0.10.0` |
| React ↔ Charm | [react-charm](https://github.com/littensy/react-charm) | `0.3.0` |
| Module loader | [RbxUtil Loader](https://github.com/Sleitnick/RbxUtil) | `2.0.0` |
| Networking | [RbxUtil Net](https://github.com/Sleitnick/RbxUtil) | `0.2.0` |
| Signals | [RbxUtil Signal](https://github.com/Sleitnick/RbxUtil) | `2.0.3` |
| Cleanup | [Janitor](https://github.com/howmanysmall/Janitor) | `1.18.3` |
| Immutable data | [Sift](https://github.com/csqrl/sift) | `0.0.11` |
| Player data | [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) | vendored |
| Tests | [Jest Lua](https://github.com/jsdotlua/jest-lua) | `3.10.0` |

## Requirements

- [Rokit](https://github.com/rojo-rbx/rokit#installation) — manages the toolchain.
- [pesde](https://pesde.dev/docs/guides/installing) — package manager.
- Roblox Studio + the Rojo plugin.

## Quick start

```powershell
rokit install          # installs rojo/selene/stylua/lune/luau-lsp/wally-package-types
pesde install          # installs dependencies into roblox_packages/ and refreshes types
rojo serve             # starts live sync; connect with the Rojo Studio plugin
```

Then edit files under `src/` — Rojo syncs them into Studio live.

## Structure

```
default.project.json     Rojo tree (DataModel layout)
pesde.toml               dependencies
rokit.toml               tool versions
selene.toml              linter
selene_definitions.yaml  custom std (require-by-string)
stylua.toml              formatter
.luaurc                  languageMode = strict
globalTypes.d.luau       Roblox API types for CLI analysis (generated, gitignored)
sourcemap.json           Rojo sourcemap (generated, gitignored)
src/
  shared/                -> ReplicatedStorage.shared   (types, constants, utils)
  net/                   -> ReplicatedStorage.net      (remote definitions)
  server/                -> ServerScriptService
    main.server.luau     entry point (Loader boots services)
    services/            services, each with a start() method
    vendor/ProfileStore.luau
  client/                -> StarterPlayer.StarterPlayerScripts
    main.client.luau     entry point (Loader boots controllers)
    controllers/         controllers, each with a start() method
    state/               Charm atoms
    ui/                  React components
  tests/                 -> ServerScriptService.tests (Jest Lua)
roblox_packages/         generated dependencies (gitignored)
```

## Commands

| Task | Command |
| --- | --- |
| Install / refresh dependencies | `pesde install` |
| Add a package | `pesde add wally#scope/name` |
| Update dependencies | `pesde update` |
| Update pesde itself | `pesde self-upgrade` |
| Format | `stylua src .pesde` |
| Lint | `selene src` |
| Type-check (CLI) | `rojo sourcemap default.project.json --output sourcemap.json; luau-lsp analyze --sourcemap=sourcemap.json --definitions=@roblox=globalTypes.d.luau --platform=roblox --ignore="roblox_packages/**" src` |
| Build a place | `rojo build default.project.json -o build/game.rbxlx` |

The same commands are available in VS Code: `Ctrl+Shift+P` → **Run Task**.

## Requires

Roblox supports require-by-string only with the `./`, `../`, `@self/` and
`@game/` prefixes; custom `.luaurc` aliases do not work at Studio runtime. The
code therefore uses only those prefixes:

```lua
require("@game/ReplicatedStorage/packages/Charm")   -- packages and shared
require("@game/ReplicatedStorage/shared/util")
require("../state/app_state")                       -- local siblings
```

`luau-lsp` resolves them through `sourcemap.json` (configured in `.vscode/settings.json`).

## Packages

Dependencies are declared in `pesde.toml` and pulled from the Wally registry via
the `wally#` prefix. pesde installs them into `roblox_packages/` and creates
alias files (`React.luau`, `Charm.luau`, …), so the in-code path is
`@game/ReplicatedStorage/packages/<Alias>`.

## ProfileStore

ProfileStore is not published on Wally/pesde, so it is vendored at
`src/server/vendor/ProfileStore.luau` with a `--!nocheck` header. To update it:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/ProfileStore.luau -OutFile src/server/vendor/ProfileStore.luau
```

and add `--!nocheck` as the first line. Usage example:
`src/server/services/player_data.luau`.

## Tests (Jest Lua)

- Specs: `src/tests/**/*.spec.luau`, config: `src/tests/jest.config.luau`.
- Runner: `src/tests/run-tests.server.luau` — runs tests on Play inside Studio,
  and is a no-op in a live server (`RunService:IsStudio()` guard).
- Requires the **`EnableLoadModule`** fast flag
  ([Roblox Studio Mod Manager](https://github.com/MaximumADHD/Roblox-Studio-Mod-Manager)).
- In CI — `run-in-roblox` against a built place.

## VS Code

`extensions.json` suggests these automatically:

| Extension | ID | Purpose |
| --- | --- | --- |
| Luau Language Server | `JohnnyMorganz.luau-lsp` | autocomplete, types, diagnostics |
| StyLua | `JohnnyMorganz.stylua` | format on save |
| Selene | `Kampfkarren.selene-vscode` | inline lint |
| Rojo | `rojo-rbx.rojo` | sync/build from the command palette |
| EditorConfig | `EditorConfig.EditorConfig` | consistent indentation/EOL |
| GitLens | `eamodio.gitlens` | history (optional) |

CLI analysis needs `globalTypes.d.luau` (gitignored). Refresh it with:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau -OutFile globalTypes.d.luau
```

## Roblox Studio

| Plugin | Purpose |
| --- | --- |
| **Rojo** | connects to `rojo serve` and syncs `src/` into the DataModel (Creator Store or Rojo releases) |
| **Luau Language Server Companion** (`Luau.rbxm`) | feeds luau-lsp live DataModel info (ships with luau-lsp releases) |
| [Azul](https://github.com/VectorPrivacy/Azul) | optional: Studio-first sync |
| [Verde](https://github.com/Verde-Dev/Verde) | optional: Explorer/Properties inside VS Code |

Also enable the built-in **Script Analysis**; `--!strict` is already set globally
via `.luaurc` plus a directive in every file.

## Known issue: Windows Defender vs luau-lsp

Defender sometimes flags `luau-lsp.exe` as `Trojan:Win32/Malgent` — a false
positive:

- luau-lsp author, issue [#1520](https://github.com/JohnnyMorganz/luau-lsp/issues/1520):
  *“This is a false positive from Microsoft. I've reported it… Try using a newer version.”*
- Matching report: issue [#1515](https://github.com/JohnnyMorganz/luau-lsp/issues/1515).
- SHA-256 of the `1.67.0` and `1.70.1` win64 archives match the official GitHub
  release digests.
- ReversingLabs: *“No evidence of software tampering.”*

The FP was seen on `1.67.0`; this template pins `1.70.1`, which installs and runs
without being blocked. If it still triggers, add an exclusion from an elevated
PowerShell:

```powershell
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.rokit\tool-storage\johnnymorganz\luau-lsp"
Add-MpPreference -ExclusionPath "$env:APPDATA\Code\User\globalStorage\johnnymorganz.luau-lsp"
```

## License

MIT — see [LICENSE](LICENSE). The vendored ProfileStore is MIT (Mad Studio / loleris).
