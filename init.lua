local MP = minetest.get_modpath("otp")

-- sanity checks
assert(type(minetest.encode_png) == "function")

otp = {
    -- mod storage
    storage = minetest.get_mod_storage(),

    -- baseXX functions
    basexx = loadfile(MP.."/basexx.lua")(),

    -- qr code
    qrcode = loadfile(MP.."/qrencode.lua")().qrcode
}

dofile(MP.."/functions.lua")
dofile(MP.."/onboard.lua")
dofile(MP.."/join.lua")
dofile(MP.."/privs.lua")
dofile(MP.."/priv_revoke.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
    dofile(MP.."/functions.spec.lua")
end
