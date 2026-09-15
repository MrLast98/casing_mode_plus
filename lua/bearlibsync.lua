-- BeardLib / HUD bridge loaded by lua/menumanager.lua and lua/hudmanager.lua.
-- Kept behind nil-guards: current BeardLib has no NetworkRegisterMod, and the
-- HUD hint helpers used here are not guaranteed on every install.

PD25.BearLibSync = PD25.BearLibSync or {}

function PD25.BearLibSync.setup_menu()
	if PD25.BearLibSync._menu then
		return
	end
	PD25.BearLibSync._menu = true

	Hooks:Add("MenuManagerInitialize", "cmp_bearlibsync_menu", function()
		MenuCallbackHandler.update_hud_settings = function(self, item)
			if managers and managers.hud then
				managers.hud:show_hint({
					time = 3,
					text = item:value()
				})
			end
		end

		if not LuaNetworking or not LuaNetworking:IsMultiplayer() then
			return
		end
		if not managers or not managers.hud or not managers.hud.get_settings then
			return
		end
		if not BeardLib or not BeardLib.NetworkRegisterMod then
			return
		end

		BeardLib:NetworkRegisterMod("player_mask_hud", {
			hud_settings = managers.hud:get_settings()
		})
	end)
end

function PD25.BearLibSync.setup_hud()
	if PD25.BearLibSync._hud then
		return
	end
	PD25.BearLibSync._hud = true

	if not HUDManager then
		return
	end

	Hooks:PostHook(HUDManager, "show_hint", "cmp_bearlibsync_hud_hint", function(self, params)
		if not params or not alive(self._hud_hint) then
			return
		end

		local duration = params.time or 3
		local text = params.text or ""

		self._hud_hint:show()
		self._hud_hint:set_text(text)
		self._hud_hint_shown = true

		if self._hud_hint_timer and self._hud_hint_timer.stop then
			self._hud_hint_timer:stop()
		end

		local script = self.script and self:script()
		if script and script.start_timer and self._hide_hint then
			self._hud_hint_timer = script.start_timer(duration, callback(self, self, "_hide_hint"))
		end
	end)
end
