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

minetest.register_chatcommand("test", {
    func = function(name)
        local url = "otpauth://totp/abc:myaccount?algorithm=SHA1&digits=6&issuer=abc&period=30&"
        .. "secret=N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"

        local ok, code = otp.qrcode(url)
        assert(ok)
        local png = otp.create_qr_png(code)
        local formspec = "size[10,10]" ..
            "image[1,0.6;5,5;^[png:" .. minetest.encode_base64(png) .. "]"

        minetest.show_formspec(name, "TEST", formspec)
    end
})