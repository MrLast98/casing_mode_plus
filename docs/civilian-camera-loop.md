# Civilian mode: camera loop (Nimble)

## Intent
While in `PlayerCivilian` (disguise), skill interactions that do not need weapons, deployables, or throwable gadgets should work the same as in casing/`PlayerMaskOff`. Camera loop (`sc_tape_loop`, Nimble) is one of those.

Still blocked in civilian: weapons, grenades, deployables (ammo/medic/ECM bags), ability gadgets (Pocket ECM, etc.). Those unlock only after transitioning to casing.

## Vanilla gating
`BaseInteractionExt:_is_in_required_state` allows civilian/clean/mask_off interactions only when `can_interact_in_civilian` is true (unless `requires_mask_off_upgrade` and state is `mask_off`).

`sc_tape_loop` has `requires_upgrade` (tape loop duration) but **not** `can_interact_in_civilian` by default, so vanilla blocks loops in both casing and civilian. This mod sets `can_interact_in_civilian` on all interaction tweak entries, which is what enables loops in casing.

## Bug
Loops work in casing but not in civilian despite the shared tweak flag. Root cause is on the player-state side, not the tweak flag:

- `PlayerMaskOff` starts timed interacts by interrupting running, and ends them via an explicit `_end_action_interact` that calls `managers.interaction:end_action_interact`.
- `PlayerCivilian` uses its own thinner `_start_action_interact` (does not interrupt running) and inherits `PlayerStandard:_end_action_interact`, while also using a separate `_interupt_action_interact` / `_update_interaction_timers` pair. Combined with civilian’s equipment-agnostic run overrides, starting a hold-interact while moving/running can desync or abort the 4s tape-loop hold so the loop never applies.

## Fix
1. Keep blanket `can_interact_in_civilian = true` (already required for casing loops).
2. Explicitly keep `sc_tape_loop.can_interact_in_civilian = true` as a documented guarantee.
3. Give `PlayerCivilian` MaskOff-equivalent `_start_action_interact` / `_end_action_interact` (interrupt running on start; complete via `managers.interaction:end_action_interact`).
4. Keep equipment/ability deployment blocked in civilian (do not port MaskOff’s ability throwable hook).

## Non-goals
- Do not weaken `pl_civilian` attention / detection immunity.
- Do not enable weapons or deployable/ability gadgets in civilian.
