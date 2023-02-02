globals = {
	"otp",
	"minetest"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "dump2",
	"VoxelArea",

	-- testing
	"mtt"
}

files["qrencode.lua"] = {
	ignore = {"631"}
}