-- PlayerCivilian = civilian disguise (e.g. Golden Grin). Same movement freedom as casing,
-- but weapons/deployables stay locked. Run logic is copied from MaskOff (no _equipped_unit).

-- Jump / crouch / sprint (vanilla only shows clean_block_interact).
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

-- No hand model while disguised.
Hooks:OverrideFunction(PlayerCivilian, "_play_equip_animation", function(self) end)
Hooks:OverrideFunction(PlayerCivilian, "_play_unequip_animation", function(self) end)

-- Hold-interacts (camera loop, etc.): stop running, then complete like casing mode.
Hooks:OverrideFunction(PlayerCivilian, "_start_action_interact", function(self, t, input, timer, interact_object)
	self:_interupt_action_running(t)

	if self._running then
		self:set_running(false)
	end

	self._interact_expire_t = timer
	self._interact_params = {
		object = interact_object,
		timer = timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	managers.hud:show_interaction_bar(0, timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, timer, false)
end)

Hooks:OverrideFunction(PlayerCivilian, "_end_action_interact", function(self)
	self:_interupt_action_interact(nil, nil, true)
	managers.interaction:end_action_interact(self._unit)
end)

-- Avoid PlayerStandard:set_running touching _equipped_unit (nil in civilian).
Hooks:OverrideFunction(PlayerCivilian, "set_running", function(self, running)
	self._running = running
	self._unit:movement():set_running(self._running)
	self._ext_network:send("action_change_run", running)
	self._ext_network:send("set_stance", self._running and 2 or 3, false, false)
end)
