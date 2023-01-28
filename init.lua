local MP = minetest.get_modpath("otp")

otp = {
    -- mod storage
    storage = minetest.get_mod_storage(),

    -- baseXX functions
    basexx = loadfile(MP.."/basexx.lua")()
}

dofile(MP.."/functions.lua")
dofile(MP.."/test.lua")
