-- Entry point for every SuperBLT post-hook. supermod.xml always runs this file;
-- we then load lua/<scriptname>.lua matching the hooked game script (RequiredScript).
if not PD25 then
	PD25 = {}
	PD25.required = {}
	PD25.mod_path = ModPath
	PD25.mod_instance = ModInstance
	PD25.version = "19"
	PD25.settings = {}
end

-- Load each hooked script once (e.g. lib/.../playermaskoff -> lua/playermaskoff.lua).
if RequiredScript and not PD25.required[RequiredScript] then
	local fname = PD25.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")

	if io.file_is_readable(fname) then
		dofile(fname)
	end

	PD25.required[RequiredScript] = true
end
