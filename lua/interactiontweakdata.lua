Hooks:PostHook(InteractionTweakData, "init", "civvie_interactables", function(self)
	for key,interaction in pairs(self) do
		if type(interaction) == "table" then
			interaction.can_interact_in_civilian = true
		end
	end
end)