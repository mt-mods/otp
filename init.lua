local MP = minetest.get_modpath("otp")

otp = {
    -- mod storage
    storage = minetest.get_mod_storage(),

    -- baseXX functions
    basexx = loadfile(MP.."/basexx.lua")(),

    -- qr code
    qrcode = loadfile(MP.."/qrencode.lua")().qrcode
}

dofile(MP.."/functions.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
    dofile(MP.."/functions.spec.lua")
end