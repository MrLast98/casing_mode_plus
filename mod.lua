if not PD25 then
	PD25 = {}
	PD25.required = {}
	PD25.mod_path = ModPath
	PD25.mod_instance = ModInstance
	PD25.version = "19"
	
	-- You can change these settings if you want
	-- Most of these currently bring some Streamlined Heisting tweaks to this mod if you didn't had SH installed
	-- In the future, i might add some customization utilizing this.
	PD25.settings = {
		skirmish_tweaks = true,
		so_tweaks = true,
		sniper_tweaks = true,
		shield_tweaks = true,
	}
end

if RequiredScript and not PD25.required[RequiredScript] then

	local fname = PD25.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	PD25.required[RequiredScript] = true

end