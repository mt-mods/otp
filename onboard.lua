local FORMNAME = "otp-onboard"

minetest.register_chatcommand("otp_disable", {
    description = "Disable the otp verification",
    privs = { otp_enabled = true, interact = true },
    func = function(name)
        -- clear priv
        local privs = minetest.get_player_privs(name)
        privs.otp_enabled = nil
        minetest.set_player_privs(name, privs)
        return true, "OTP login disabled"
    end
})

minetest.register_chatcommand("otp_enable", {
    description = "Enable the otp verification",
    func = function(name)
        -- issuer name
        local issuer = minetest.settings:get("otp.issuer") or "Minetest"
        local server_name = minetest.settings:get("server_name")
        local server_address = minetest.settings:get("server_address")
        if server_name and server_name ~= "" then
            issuer = server_name
        elseif server_address and server_address ~= "" then
            issuer = server_address
        end

        -- authenticator image
        local image = minetest.settings:get("otp.authenticator_image") or
            "https://raw.githubusercontent.com/minetest/minetest/master/misc/minetest-xorg-icon-128.png"

        local secret_b32 = otp.get_player_secret_b32(name)

        -- url for the qr code
        local url = "otpauth://totp/" .. issuer .. ":" .. name .. "?algorithm=SHA1" ..
            "&digits=6" ..
            "&issuer=" .. issuer ..
            "&period=30" ..
            "&secret=" .. secret_b32 ..
            "&image=" .. image

        local ok, code = otp.qrcode(url)
        if not ok then
            return false, "qr code generation failed"
        end

        local png = otp.create_qr_png(code)
        local formspec = "size[9,10]" ..
            "image[1.5,0.6;7,7;^[png:" .. minetest.encode_base64(png) .. "]" ..
            "label[1,7;Use the above QR code in your OTP-App to obtain a verification code]" ..
            "field[1,9;4,1;code;Code;]" ..
            "button_exit[5,8.7;3,1;submit;Verify]"

        minetest.show_formspec(name, FORMNAME, formspec)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then
        return
    end

    if fields.code then
        local playername = player:get_player_name()
        local secret_b32 = otp.get_player_secret_b32(playername)
        if otp.check_code(secret_b32, fields.code) then
            -- set priv
            local privs = minetest.get_player_privs(playername)
            privs.otp_enabled = true
            minetest.set_player_privs(playername, privs)

            minetest.chat_send_player(playername, "Code validation succeeded, OTP login enabled")
        else
            minetest.chat_send_player(playername, "Code validation failed!")
        end

    end
end)