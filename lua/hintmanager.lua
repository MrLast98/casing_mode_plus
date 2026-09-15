-- Blocks the "NO SUSPICIOUS ACTIONS ALLOWED" hint spam from Casing Mode
-- (merged from the separate "No More Casing Mode Warnings" patch)
-- "mask_off_block_interact" is shown while unmasked (casing/mask-off state),
-- "clean_block_interact" is the equivalent shown while in the civilian-disguise state.
local blocked_hints = {
    mask_off_block_interact = true,
    clean_block_interact = true,
}

local orig_show_hint = HintManager.show_hint

function HintManager:show_hint(id, ...)
    if blocked_hints[id] then
        return -- Block the hint completely
    end
    return orig_show_hint(self, id, ...) -- Allow all other hints
end
