

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

mtt.register("otp.generate_code", function(callback)
    local expected_code = 699847
    local secret_b32 = "N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"
    local secret = otp.basexx.from_base32(secret_b32)
    local unix_time = 1640995200

    local tx = 30
    local ct = math.floor(unix_time / tx)
    local counter = otp.write_uint64_be(ct)

    local code = otp.generate_code(secret, counter)
    assert(code == expected_code)
    callback()
end)