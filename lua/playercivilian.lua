-- PlayerCivilian (the "civilian disguise" state used by some heists, distinct from
-- PlayerMaskOff/casing mode) hard-blocks jump/duck/run by only ever showing the
-- "clean_block_interact" hint instead of performing the action, and it never equips a
-- weapon at all. Reuse the same equipment-agnostic run/duck/jump logic already used for
-- PlayerMaskOff's casing mode instead of delegating to PlayerStandard's own
-- _start_action_running/_end_action_running: those reference self._equipped_unit
-- (weapon-camera redirects, etc.) which PlayerCivilian has none of, so calling them
-- directly can error out mid-hook and leave "_running" stuck true forever - which is
-- why stamina never regenerated.
--
-- Weapons, reload/melee/throwables and equipment/gadget deployment (ammo bags, ECM,
-- etc.) are intentionally left alone here - those should only come back once the
-- player actually enters casing/mask-off mode, not while still in civilian disguise.

Hooks:OverrideFunction(PlayerCivilian, "_check_action_jump", function(self, t, input)
    if input.btn_jump_press then
        PlayerStandard._check_action_jump(self, t, input)
    end
end)

Hooks:OverrideFunction(PlayerCivilian, "_check_action_duck", function(self, t, input)
    if input.btn_duck_release or input.btn_duck_press then
        PlayerStandard._check_action_duck(self, t, input)
    end
end)

Hooks:OverrideFunction(PlayerCivilian, "_check_action_run", function(self, t, input)
    if self._setting_hold_to_run and input.btn_run_release or self._running and not self._move_dir then
        self._running_wanted = false

        if self._running then
            self:_end_action_running(t)
            self:set_running(false)
        end
    elseif not self._setting_hold_to_run and input.btn_run_release and not self._move_dir then
        self._running_wanted = false

        if self._running then
            self:_end_action_running(t)
            self:set_running(false)
        end
    elseif input.btn_run_press or self._running_wanted then
        if not self._running or self._end_running_expire_t then
            self:_start_action_running(t)
        elseif self._running and not self._setting_hold_to_run then
            self:_end_action_running(t)
            self:set_running(false)
        end
    end
end)

Hooks:OverrideFunction(PlayerCivilian, "_start_action_running", function(self, t)
    if not self._move_dir then
        self._running_wanted = true
        return
    end

    if self:on_ladder() or self:_on_zipline() then
        return
    end

    if self._state_data.ducking and not self:_can_stand() then
        self._running_wanted = true
        return
    end

    if not self:_can_run_directional() then
        return
    end

    self._running_wanted = false

    if managers.player:get_player_rule("no_run") then
        return
    end

    if not self._unit:movement():is_above_stamina_threshold() then
        return
    end

    if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_headbob") then
        self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
    end

    self:set_running(true)

    self._end_running_expire_t = nil
    self._start_running_t = t
    self._play_stop_running_anim = nil

    self:_interupt_action_reload(t)
    self:_interupt_action_steelsight(t)
    self:_interupt_action_ducking(t)
end)

Hooks:OverrideFunction(PlayerCivilian, "_end_action_running", function(self, t)
    if not self._end_running_expire_t then
        self._end_running_expire_t = t + 0.4
    end
end)

-- Hide the bare-hand equip/unequip pose, same as casing mode, so no hand model appears.
Hooks:OverrideFunction(PlayerCivilian, "_play_equip_animation", function(self) end)
Hooks:OverrideFunction(PlayerCivilian, "_play_unequip_animation", function(self) end)
