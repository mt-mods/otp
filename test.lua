local secret_b32 = "N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"
local expected_code = 699847

minetest.register_chatcommand("otp_test", {
    description = "",
    params = "[]",
	func = function(name, param)
        local secret = otp.basexx.from_base32(secret_b32)
        local unix_time = 1640995200
        local tx = 30
        local ct = math.floor(unix_time / tx)

        local hmac = otp.hmac(secret, otp.write_uint64(ct))



        print(dump({
            expected_code = expected_code,
            unix_time = unix_time,
            ct = ct,
            hmac = otp.basexx.to_base64(hmac)
        }))
	end
})