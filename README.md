# Casing Mode: Diesel 3.0 Edition

Brings PAYDAY 3-style casing freedom to PAYDAY 2 — sprint, crouch, jump, and interact
while unmasked or disguised as a civilian, without the constant "no suspicious actions
allowed" warning spam. Updated to work on the Diesel 3.0 (64-bit) engine.

## What it does

### Mask-off / casing mode (`PlayerMaskOff`)
- Duck, jump, and sprint work normally instead of being hard-blocked.
- Interactions (doors, computers, drills, etc.) are allowed instead of triggering an
  intimidate/mark action.
- Detection stays civilian-like unless you're actually hostile or acting suspicious,
  in which case normal detection rules apply.
- No equip/unequip animation pop when going in and out of this state.
- The "NO SUSPICIOUS ACTIONS ALLOWED" hint is suppressed.
- Ability-type throwables (e.g. Pocket ECM) can be used; real grenades stay blocked,
  since those are still weapons.

### Civilian disguise (`PlayerCivilian`)
- Duck, jump, and sprint work the same as casing mode (vanilla only ever showed a
  warning hint for these and never actually performed the action).
- Its "clean_block_interact" warning hint is suppressed.
- No equip/unequip animation pop, so no hand model appears.
- Weapons, reload/melee/throwables, and equipment/gadget deployment (ammo bags, ECM,
  etc.) stay disabled — those only come back once you actually reach mask-off/casing
  mode. Detection immunity is untouched (kept stronger than mask-off's).

### Interactions in general
- Every interaction is flagged as usable while unmasked or disguised as a civilian
  (`can_interact_in_civilian`), instead of only in the base game's limited set.

### Misc
- Streamlined Heisting-style HUD hint sync tweaks for menu/HUD managers (for players
  without Streamlined Heisting installed).

## Requirements
- [SuperBLT](https://superblt.znix.xyz/) (64-bit build, for Diesel 3.0).
- BeardLib, only needed for the multiplayer HUD-settings sync in `bearlibsync.lua`.

## File layout
```
mod.txt                   BLT mod definition
mod.lua                   Generic RequiredScript -> lua/<name>.lua dispatcher
supermod.xml              Hook declarations (XML tweaker syntax)
lua/interactiontweakdata.lua  Allows all interactions while unmasked/civilian
lua/hintmanager.lua        Suppresses the casing/civilian warning hints
lua/playermaskoff.lua      Casing mode (mask-off) movement/interaction/ability tweaks
lua/playercivilian.lua     Civilian-disguise movement tweaks + hidden hands
lua/playerstandard.lua     Shared helper (`_get_detection_status`) + suspicion tracking
lua/bearlibsync.lua        HUD hint sync helpers (Streamlined Heisting parity)
```

## Known issues
None.

## Credits
- https://modworkshop.net/mod/46025 — Original mod that ported the mechanics — aplayer-1
- https://modworkshop.net/mod/50586 — Original mod that extracted the specific features
- No More Casing Mode Warnings — MightyPotato (merged in)
