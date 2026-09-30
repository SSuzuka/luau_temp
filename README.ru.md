# luau_temp — шаблон Luau/Roblox проекта

[English](README.md) · **Русский**

Шаблон Roblox-проекта на Luau: строгая типизация, реактивный UI, сохранение
данных игрока, networking и тесты. Тулчейн установлен и проверен —
`pesde install`, `rojo sourcemap`, `selene`, `stylua`, `luau-lsp analyze` проходят
без ошибок.

## Стек

| Слой | Инструмент | Версия |
| --- | --- | --- |
| Toolchain manager | [Rokit](https://github.com/rojo-rbx/rokit) | `1.2.0` |
| Пакетный менеджер | [pesde](https://pesde.dev) | `0.7.4` |
| Синхронизация | [Rojo](https://rojo.space) | `7.7.0` |
| Линтер | [Selene](https://github.com/Kampfkarren/selene) | `0.31.0` |
| Форматтер | [StyLua](https://github.com/JohnnyMorganz/StyLua) | `2.5.2` |
| Рантайм-скрипты | [Lune](https://lune-org.github.io/docs) | `0.10.5` |
| Language server | [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | `1.70.1` |
| UI | [React Lua](https://github.com/jsdotlua/react-lua) | `17.2.1` |
| Состояние | [Charm](https://github.com/littensy/charm) | `0.10.0` |
| React ↔ Charm | [react-charm](https://github.com/littensy/react-charm) | `0.3.0` |
| Загрузчик модулей | [RbxUtil Loader](https://github.com/Sleitnick/RbxUtil) | `2.0.0` |
| Networking | [RbxUtil Net](https://github.com/Sleitnick/RbxUtil) | `0.2.0` |
| Signals | [RbxUtil Signal](https://github.com/Sleitnick/RbxUtil) | `2.0.3` |
| Очистка ресурсов | [Janitor](https://github.com/howmanysmall/Janitor) | `1.18.3` |
| Иммутабельные данные | [Sift](https://github.com/csqrl/sift) | `0.0.11` |
| Данные игрока | [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) | vendored |
| Тесты | [Jest Lua](https://github.com/jsdotlua/jest-lua) | `3.10.0` |

## Требования

- [Rokit](https://github.com/rojo-rbx/rokit#installation) — управляет тулчейном.
- [pesde](https://pesde.dev/docs/guides/installing) — пакетный менеджер.
- Roblox Studio + плагин Rojo.

## Быстрый старт

```powershell
rokit install          # ставит rojo/selene/stylua/lune/luau-lsp/wally-package-types
pesde install          # ставит зависимости в roblox_packages/ и обновляет типы
rojo serve             # поднимает live-sync; подключитесь плагином Rojo в Studio
```

Дальше — правьте файлы в `src/`, Rojo синхронизирует их в Studio на лету.

## Структура

```
default.project.json     Rojo-дерево (раскладка DataModel)
pesde.toml               зависимости
rokit.toml               версии инструментов
selene.toml              линтер
selene_definitions.yaml  кастомный std (require-by-string)
stylua.toml              форматтер
.luaurc                  languageMode = strict
globalTypes.d.luau       Roblox API-типы для CLI-анализа (генерируется, gitignore)
sourcemap.json           Rojo sourcemap (генерируется, gitignore)
src/
  shared/                → ReplicatedStorage.shared   (типы, константы, утилиты)
  net/                   → ReplicatedStorage.net      (определения remote-ов)
  server/                → ServerScriptService
    main.server.luau     точка входа (Loader поднимает services)
    services/            сервисы, у каждого метод start()
    vendor/ProfileStore.luau
  client/                → StarterPlayer.StarterPlayerScripts
    main.client.luau     точка входа (Loader поднимает controllers)
    controllers/         контроллеры, у каждого метод start()
    state/               Charm-атомы
    ui/                  React-компоненты
  tests/                 → ServerScriptService.tests (Jest Lua)
roblox_packages/         сгенерированные зависимости (gitignore)
```

## Команды

| Задача | Команда |
| --- | --- |
| Установить/обновить зависимости | `pesde install` |
| Добавить пакет | `pesde add wally#scope/name` |
| Обновить зависимости | `pesde update` |
| Обновить pesde | `pesde self-upgrade` |
| Формат | `stylua src .pesde` |
| Линт | `selene src` |
| Типы (CLI) | `rojo sourcemap default.project.json --output sourcemap.json; luau-lsp analyze --sourcemap=sourcemap.json --definitions=@roblox=globalTypes.d.luau --platform=roblox --ignore="roblox_packages/**" src` |
| Собрать place | `rojo build default.project.json -o build/game.rbxlx` |

Те же команды есть в VS Code: `Ctrl+Shift+P` → **Run Task**.

## Requires

Roblox поддерживает require-by-string только с префиксами `./`, `../`, `@self/`,
`@game/`; кастомные алиасы из `.luaurc` в рантайме Studio не работают. Поэтому в
коде используются только эти префиксы:

```lua
require("@game/ReplicatedStorage/packages/Charm")   -- пакеты и shared
require("@game/ReplicatedStorage/shared/util")
require("../state/app_state")                       -- локальные соседи
```

`luau-lsp` резолвит их через `sourcemap.json` (настроено в `.vscode/settings.json`).

## Пакеты

Зависимости объявляются в `pesde.toml` и тянутся из Wally-реестра через префикс
`wally#`. pesde кладёт их в `roblox_packages/` и создаёт файлы-алиасы
(`React.luau`, `Charm.luau`, …), поэтому в коде путь — `@game/ReplicatedStorage/packages/<Alias>`.

## ProfileStore

ProfileStore не публикуется в Wally/pesde, поэтому лежит вендорно:
`src/server/vendor/ProfileStore.luau` с шапкой `--!nocheck`. Обновление:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/ProfileStore.luau -OutFile src/server/vendor/ProfileStore.luau
```

и добавьте `--!nocheck` первой строкой. Пример использования — `src/server/services/player_data.luau`.

## Тесты (Jest Lua)

- Спеки: `src/tests/**/*.spec.luau`, конфиг: `src/tests/jest.config.luau`.
- Раннер: `src/tests/run-tests.server.luau` — в Studio прогоняет тесты на Play,
  в live-сервере ничего не делает (`RunService:IsStudio()` guard).
- Требуется fast flag **`EnableLoadModule`**
  ([Roblox Studio Mod Manager](https://github.com/MaximumADHD/Roblox-Studio-Mod-Manager)).
- В CI — `run-in-roblox` по собранному place.

## VS Code

`extensions.json` предложит расширения сам:

| Расширение | ID | Зачем |
| --- | --- | --- |
| Luau Language Server | `JohnnyMorganz.luau-lsp` | автокомплит, типы, диагностика |
| StyLua | `JohnnyMorganz.stylua` | формат на сохранении |
| Selene | `Kampfkarren.selene-vscode` | линт в редакторе |
| Rojo | `rojo-rbx.rojo` | команды sync/build из палитры |
| EditorConfig | `EditorConfig.EditorConfig` | единые отступы/EOL |
| GitLens | `eamodio.gitlens` | история (опционально) |

Для CLI-анализа нужен `globalTypes.d.luau` (в gitignore). Обновить:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau -OutFile globalTypes.d.luau
```

## Roblox Studio

| Плагин | Зачем |
| --- | --- |
| **Rojo** | подключается к `rojo serve`, синхронизирует `src/` в DataModel (Creator Store или релизы Rojo) |
| **Luau Language Server Companion** (`Luau.rbxm`) | отдаёт luau-lsp живую DataModel-инфу (в релизах luau-lsp) |
| [Azul](https://github.com/VectorPrivacy/Azul) | опционально: Studio-first синк |
| [Verde](https://github.com/Verde-Dev/Verde) | опционально: Explorer/Properties в VS Code |

Также включите встроенный **Script Analysis**; `--!strict` уже стоит глобально
через `.luaurc` + директиву в каждом файле.

## Известная проблема: Defender и luau-lsp

Defender периодически помечает `luau-lsp.exe` как `Trojan:Win32/Malgent` — это
ложное срабатывание:

- Автор luau-lsp, issue [#1520](https://github.com/JohnnyMorganz/luau-lsp/issues/1520):
  *«This is a false positive from Microsoft. I've reported it… Try using a newer version»*.
- Аналогичный issue [#1515](https://github.com/JohnnyMorganz/luau-lsp/issues/1515).
- SHA-256 win64-архивов `1.67.0` и `1.70.1` совпадают с digest официальных GitHub-релизов.
- ReversingLabs: *«No evidence of software tampering»*.

FP ловился на `1.67.0`; в шаблоне зафиксирован `1.70.1`, который ставится и
запускается без блокировки. Если всё же сработает — добавьте исключение в
PowerShell от администратора:

```powershell
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.rokit\tool-storage\johnnymorganz\luau-lsp"
Add-MpPreference -ExclusionPath "$env:APPDATA\Code\User\globalStorage\johnnymorganz.luau-lsp"
```

## Лицензия

MIT — см. [LICENSE](LICENSE). Вендоренный ProfileStore — тоже MIT (Mad Studio / loleris).
