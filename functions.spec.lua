

mtt.register("otp.hmac", function(callback)
    local secret_b32 = "N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"
    local secret = otp.basexx.from_base32(secret_b32)
    local unix_time = 1640995200

    local expected_hmac = otp.basexx.from_base64("m04YheEb7i+ThPMUJEfVXVybZFo=")
    assert(#expected_hmac == 20)

    local tx = 30
    local ct = math.floor(unix_time / tx)
    local counter = otp.write_uint64_be(ct)

    assert( #secret == 20 )
    assert( otp.basexx.to_base64(secret) == "b5JlMIqmiePBi1tYlQYxNWGsqr8=" )
    assert( #counter == 8 )
    assert( otp.basexx.to_base64(counter) == "AAAAAANCp0A=" )

    local hmac = otp.hmac(secret, counter)
    assert(#hmac == 20)

    for i=1,20 do
        assert( string.byte(expected_hmac,i) == string.byte(hmac, i) )
    end

    callback()
end)

mtt.register("otp.generate_totp", function(callback)
    local expected_code = "699847"
    local secret_b32 = "N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"
    local unix_time = 1640995200

    local code, valid_seconds = otp.generate_totp(secret_b32, unix_time)
    assert(code == expected_code)
    assert(valid_seconds > 0)

    code, valid_seconds = otp.generate_totp(secret_b32)
    print("Current code: " .. code .. " valid for " .. valid_seconds .. " seconds")
    callback()
end)

mtt.register("otp.check_code", function(callback)
    local expected_code = "699847"
    local secret_b32 = "N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"
    local unix_time = 1640995200

    assert(otp.check_code(secret_b32, expected_code, unix_time))
    assert(otp.check_code(secret_b32, expected_code, unix_time+30))
    assert(otp.check_code(secret_b32, expected_code, unix_time-30))
    assert(not otp.check_code(secret_b32, expected_code, unix_time-60))
    assert(not otp.check_code(secret_b32, expected_code, unix_time+60))
    assert(not otp.check_code(secret_b32, expected_code))

    callback()
end)

mtt.register("otp.create_qr_png", function(callback)
    local url = "otpauth://totp/abc:myaccount?algorithm=SHA1&digits=6&issuer=abc&period=30&"
        .. "secret=N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"

    local ok, code = otp.qrcode(url)
    assert(ok)
    assert(code)

    local png = otp.create_qr_png(code)
    assert(png)

    local f = io.open(minetest.get_worldpath() .. "/qr.png", "w")
    f:write(png)
    f:close()
    callback()
end)

mtt.register("otp.generate_secret", function(callback)
    local s = otp.generate_secret()
    assert(#s == 20)
    callback()
end)