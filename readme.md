
# (T)OTP mod for minetest

* State: **Stable**

# Overview

Lets security-aware players use the `/otp_enable` command to protect their account with a second factor.

Players that have the OTP enabled have to enter a verification code upon joining the game.

# OTP Authenticator apps

* https://freeotp.github.io/
* https://github.com/helloworld1/FreeOTPPlus

# Screenshots

OTP verification form
![](./screenshot1.png)

OTP Setup form
![](./screenshot2.png)

# Temporary privilege revocation

All of the privileges get revoked when logging in with the otp enabled (until the proper code is entered).
Some exceptions:
* `fly` (otherwise the player would literally fall from the sky)
* `noclip`

To disable revokation on custom privs the field `otp_keep` can be set to true on the definition:
```lua
minetest.register_privilege("my_super_important_priv", {
    description = "something something",
    otp_keep = true
})
```

# Settings

* `otp.authenticator_image` The image to use in the QR code for the otp app (defaults to "https://raw.githubusercontent.com/minetest/minetest/master/misc/minetest-xorg-icon-128.png")
* `otp.issuer` The issuer name, defaults to server name, address or just "Minetest"

# Links / References

* https://en.wikipedia.org/wiki/Time-based_one-time_password
* https://en.wikipedia.org/wiki/HMAC-based_one-time_password
* https://en.wikipedia.org/wiki/HMAC
* https://github.com/google/google-authenticator/wiki/Key-Uri-Format

# Chatcommands

* `/otp_enable` Starts the OTP onboarding process
* `/otp_disable` Disables the OTP Login

# Privileges

* `otp_enabled` Players with this privilege have to verify the OTP Code upon login (automatically granted on successful `/otp_enable`)

# License

* Code: `MIT`
* Textures: `CC-BY-SA 3.0`
* "basexx.lua" `MIT` https://github.com/aiq/basexx/blob/master/lib/basexx.lua
* "qrencode.lua" `BSD` https://github.com/speedata/luaqrcode/blob/master/qrencode.lua
