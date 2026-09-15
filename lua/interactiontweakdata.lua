-- Allow interactions while casing or in civilian disguise (doors, lockpicks, camera loop, etc.).
Hooks:PostHook(InteractionTweakData, "init", "civvie_interactables", function(self)
	for _, interaction in pairs(self) do
		if type(interaction) == "table" then
			interaction.can_interact_in_civilian = true
		end
	end

	-- Nimble camera loop (sc_tape_loop) is the skill interaction that most often needs this.
	if self.sc_tape_loop then
		self.sc_tape_loop.can_interact_in_civilian = true
	end
end)
