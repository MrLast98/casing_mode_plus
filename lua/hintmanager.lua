-- Suppress casing/civilian "no suspicious actions" hint spam.
local blocked_hints = {
	mask_off_block_interact = true, -- casing / mask-off
	clean_block_interact = true, -- civilian disguise
}

local orig_show_hint = HintManager.show_hint

function HintManager:show_hint(id, ...)
	if blocked_hints[id] then
		return
	end

	return orig_show_hint(self, id, ...)
end
