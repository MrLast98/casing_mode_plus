# Mod loader configuration (SuperBLT)

Cross-checked against:

- [SuperBLT mod.txt basics](https://superblt.znix.xyz/doc/mod_definition/basics/)
- [SuperBLT XML / attribute inheritance](https://superblt.znix.xyz/doc/mod_definition/xml/)
- [SuperBLT updates (incl. ModWorkshop `mws`)](https://superblt.znix.xyz/doc/mod_definition/updates/)
- [SuperBLT variables (`RequiredScript`, `ModPath`)](https://superblt.znix.xyz/doc/mod_definition/variables/)

## Verdict

SuperBLT-only mod. No BeardLib dependency — gameplay is pure Lua hooks (`Hooks:PostHook` / `Hooks:OverrideFunction`). An unused BeardLib HUD-sync stub was removed.

---

## `supermod.xml` hook pattern

```xml
<hooks script_path="mod.lua">
  <group hook_id="lib/">
    <group :hook_id="…/">
      <post :hook_id="filename"/>
```

| Rule | Our usage |
|------|-----------|
| Child tags inherit parent attributes | `script_path="mod.lua"` on `<hooks>` applies to every `<post>` |
| `:attr` **appends** to inherited value | `:hook_id="managers/"` → `lib/managers/` |
| No `:` **replaces** | First `hook_id="lib/"` correctly seeds the path |
| Trailing slashes are our responsibility | Present on path prefixes |

Resolved post-hooks:

| `hook_id` | Dispatched file via `mod.lua` |
|-----------|-------------------------------|
| `lib/tweak_data/interactiontweakdata` | `lua/interactiontweakdata.lua` |
| `lib/managers/hintmanager` | `lua/hintmanager.lua` |
| `lib/units/beings/player/states/playermaskoff` | `lua/playermaskoff.lua` |
| `lib/units/beings/player/states/playerstandard` | `lua/playerstandard.lua` |
| `lib/units/beings/player/states/playercivilian` | `lua/playercivilian.lua` |

## `mod.lua` dispatcher

```lua
RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
```

Matches SuperBLT’s `RequiredScript` variable. `ModPath` / `ModInstance` are cached on first load.

## `mod.txt`

- `blt_version`: `2`
- `color`: space-separated **0–255** RGB
- Updates: `"provider": "mws"`, `"identifier": "58885"` (ModWorkshop mod id)

`mod.txt` `version` is the source of truth for MWS updates (not `PD25.version` in `mod.lua`).

## Checklist for future changes

1. Every `<post :hook_id="…"/>` must have a matching `lua/<last-segment>.lua` (or change the dispatcher).
2. Prefer one `script_path` (`mod.lua`) **or** per-file `script_path`s — don’t mix without documenting why.
3. Keep `color` as `R G B` in 0–255.
4. Keep MWS `identifier` equal to the ModWorkshop mod id in the URL.
5. Peer messaging (if added later) → SuperBLT `NetworkHelper`, not BeardLib, unless shipping BeardLib custom content.
