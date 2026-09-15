local level_id = Global.level_data and Global.level_data.level_id or ""

Hooks:PostHook(PlayerMaskOff, "_check_action_duck", "CheckDuckAndJump", function(self, t, input)
    -- Manejar la acción de agacharse
    if input.btn_duck_release or input.btn_duck_press then
        PlayerStandard._check_action_duck(self, t, input)
    end

    -- Manejar la acción de saltar
    if input.btn_jump_press then
        PlayerStandard._check_action_jump(self, t, input)
    end
end)

Hooks:OverrideFunction(PlayerMaskOff, "_check_action_run", function(self, t, input)
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

Hooks:PostHook(PlayerMaskOff, "_check_action_interact", "CheckInteract", function(self)
    return not self._start_intimidate
end)

Hooks:OverrideFunction(PlayerMaskOff, "_upd_attention", function(self)
    if self:_get_detection_status() == "hostile" or self._is_suspicious then
        PlayerStandard._upd_attention(self)
    else
        self._ext_movement:set_attention_settings(self._mask_off_attention_settings)
    end
end)

Hooks:OverrideFunction(PlayerMaskOff, "_play_equip_animation", function(self) end)
Hooks:OverrideFunction(PlayerMaskOff, "_play_unequip_animation", function(self) end)

Hooks:OverrideFunction(PlayerMaskOff, "_start_action_running", function(self, t)
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

Hooks:OverrideFunction(PlayerMaskOff, "_end_action_running", function(self, t)
    if not self._end_running_expire_t then
        self._end_running_expire_t = t + 0.4
    end
end)

Hooks:PostHook(PlayerMaskOff, "enter", "fix_detection", function(self)
    self:_upd_attention()
end)

-- Casing mode's update loop never checks the throwable slot, so "ability" items
-- (e.g. Pocket ECM, and any other equipment flagged as an ability rather than a real
-- grenade) can't be used while unmasked. Piggyback on the existing per-frame update to
-- allow those specifically, while leaving actual grenades (weapons) untouched/blocked.
Hooks:PostHook(PlayerMaskOff, "_update_check_actions", "CheckAbilityItem", function(self, t, dt)
    local projectile_entry = managers.blackmarket:equipped_projectile()
    local projectile_tweak = projectile_entry and tweak_data.blackmarket.projectiles[projectile_entry]

    if projectile_tweak and projectile_tweak.ability then
        self:_check_action_use_ability(t, self:_get_input(t, dt))
    end
end)
