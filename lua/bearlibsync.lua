Hooks:Add("MenuManagerInitialize", "InitHUDManager", function(menu_manager)
    -- Initialize BeardLib menu
    MenuCallbackHandler.update_hud_settings = function(self, item)
        if managers and managers.hud then
            -- Handle HUD updates
            local text = item:value()
            managers.hud:show_hint({
                time = 3,
                text = text
            })
        end
    end

    -- Register with BeardLib's sync system
    if LuaNetworking:IsMultiplayer() then
        local sync_data = {
            hud_settings = managers.hud:get_settings()
        }
        BeardLib:NetworkRegisterMod("player_mask_hud", sync_data)
    end
end)

-- Hook into HUD manager for custom hint display
Hooks:PostHook(HUDManager, "show_hint", "CustomHUDHint", function(self, params)
    if not params then return end
    
    -- Process hint parameters
    local duration = params.time or 3
    local text = params.text or ""
    
    -- Update HUD elements
    if alive(self._hud_hint) then
        self._hud_hint:show()
        self._hud_hint:set_text(text)
        self._hud_hint_shown = true
        
        -- Reset timer
        if self._hud_hint_timer then
            self._hud_hint_timer:stop()
        end
        self._hud_hint_timer = self:script().start_timer(duration, callback(self, self, "_hide_hint"))
    end
end)