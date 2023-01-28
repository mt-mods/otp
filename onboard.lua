local FORMNAME = "otp-enable"

local secret = otp.generate_secret()
local secret_b32 = otp.basexx.to_base32(secret)

minetest.register_chatcommand("otp_enable", {
    func = function(name)
        local issuer = "Minetest"
        if minetest.settings:get("server_name") ~= "" then
            issuer = minetest.settings:get("server_name")
        elseif minetest.settings:get("server_address") ~= "" then
            issuer = minetest.settings:get("server_address")
        end

        local url = "otpauth://totp/" .. issuer .. ":" .. name .. "?algorithm=SHA1&" ..
            "digits=6&issuer=" .. issuer .. "&period=30&" ..
            "secret=" .. secret_b32

        local ok, code = otp.qrcode(url)
        assert(ok)

        local png = otp.create_qr_png(code)
        local formspec = "size[10,10]" ..
            "image[1,0.6;5,5;^[png:" .. minetest.encode_base64(png) .. "]" ..
            "field[1,9;5,1;code;Code;]"

        minetest.show_formspec(name, FORMNAME, formspec)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then
        return
    end

    if fields.code then
        print("Validating code for " .. player:get_player_name())
        local expected_code = otp.generate_totp(secret)
        if expected_code == fields.code then
            print("Valid")
        else
            print("Invalid")
        end

    end
end)