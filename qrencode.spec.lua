
mtt.register("otp.qrcode", function(callback)
    assert(type(otp.qrcode) == "function")

    local url = "otpauth://totp/abc:myaccount?algorithm=SHA1&digits=6&issuer=abc&period=30&"
        .. "secret=N6JGKMEKU2E6HQMLLNMJKBRRGVQ2ZKV7"

    local ok, code = otp.qrcode(url)
    assert(ok)
    assert(code)

    callback()
end)