-- Shared helpers for casing attention while interacting.
local level_id = Global.level_data and Global.level_data.level_id or ""

-- Maps marked hostile in tweak_data use standard (masked) detection rules.
function PlayerStandard:_get_detection_status()
	local level_data = tweak_data.levels[level_id]

	if level_data and level_data.is_map_hostile then
		return "hostile"
	end

	return "none"
end

-- Flag suspicious while holding an interact; cleared when the hold ends or is cancelled.
-- Used by PlayerMaskOff:_upd_attention to temporarily use standard detection.
Hooks:PostHook(PlayerStandard, "_start_action_interact", "_on_interact", function(self)
	if not self._is_suspicious then
		self._is_suspicious = true
	end
end)

Hooks:PostHook(PlayerStandard, "_interupt_action_interact", "_on_interact_interrupt", function(self)
	if self._is_suspicious then
		self._is_suspicious = nil
	end
end)

Hooks:PostHook(PlayerStandard, "_end_action_interact", "_on_interact_ended", function(self)
	if self._is_suspicious then
		self._is_suspicious = nil
	end
end)
