globals = {
	"otp",
	"minetest" = {
		"registered_privileges"
	}
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest", "vector", "ItemStack",
	"dump", "dump2",
	"VoxelArea",

	-- testing
	"mtt"
}

files["qrencode.lua"] = {
	ignore = {"631"}
}