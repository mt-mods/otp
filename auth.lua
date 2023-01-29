-- builtin auth handler
local auth_handler = minetest.get_auth_handler()
local old_get_auth = auth_handler.get_auth

-- time for otp to be enabled until properly logged in
local otp_time = 300

-- playername => start_time
local otp_sessions = {}

minetest.register_on_joinplayer(function(player)
    -- reset otp session upon login
    local playername = player:get_player_name()
    otp_sessions[player:get_player_name()] = nil
    print("minetest.register_on_joinplayer(" .. playername .. ")")
end)

-- override "get_auth" from builtin auth handler
auth_handler.get_auth = function(name)
    local auth = old_get_auth(name)

    print("auth_handler.get_auth(" .. name .. ")")
    if name == "singleplayer" or not auth.privileges.otp_enabled then
        -- singleplayer or otp not set up
        return auth
    end

    -- minetest.disconnect_player(name, "something, something")

    local now = os.time()
    local otp_session = otp_sessions[name]
    if not otp_session or (now - otp_session) > otp_time then
        -- otp session expired or not set up
        otp_sessions[name] = now
    end

    -- replace runtime password with legacy password hash
    --auth.password = minetest.get_password_hash(name, "enter")

    return auth
end

minetest.register_on_prejoinplayer(function(name)
    print("minetest.register_on_prejoinplayer(" .. name .. ")")

end)