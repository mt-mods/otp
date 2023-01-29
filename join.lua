local FORMNAME = "otp-check"

-- time for otp code verification
local otp_time = 300

-- playername => start_time
local otp_sessions = {}

-- privs to revoke until the verification code is validated
local temp_revoke_privs = {"interact", "shout", "privs", "basic_privs", "server", "ban", "kick"}

local function revoke_privs(playername)
    local privs = minetest.get_player_privs(playername)
    if otp.storage:get_string(playername .. "_privs") == "" then
        otp.storage:set_string(playername .. "_privs", minetest.serialize(privs))
        for _, priv in ipairs(temp_revoke_privs) do
            privs[priv] = nil
            minetest.set_player_privs(playername, privs)
        end
    end
end

local function regrant_privs(playername)
    local stored_priv_str = otp.storage:get_string(playername .. "_privs")
    if stored_priv_str ~= "" then
        local privs = minetest.deserialize(stored_priv_str)
        minetest.set_player_privs(playername, privs)
        otp.storage:set_string(playername .. "_privs", "")
    end
end

-- Code formspec on join for otp enabled players
minetest.register_on_joinplayer(function(player)
    local playername = player:get_player_name()
    if minetest.check_player_privs(playername, "otp_enabled") then
        -- start otp session time
        otp_sessions[player:get_player_name()] = os.time()

        -- revoke important privs and re-grant again on code-verification
        revoke_privs(playername)

        -- send verification formspec
        local formspec = "size[10,2]" ..
            "label[1,0;Please enter your OTP code below]" ..
            "field[1,1.3;4,1;code;Code;]" ..
            "button_exit[5,1;3,1;submit;Verify]"

        minetest.show_formspec(playername, FORMNAME, formspec)
    end
end)

-- clear otp session on leave
minetest.register_on_leaveplayer(function(player)
    local playername = player:get_player_name()
    otp_sessions[playername] = nil
end)

-- check sessions periodically and kick if timed out
local function session_check()
    local now = os.time()
    for name, start_time in pairs(otp_sessions) do
        if (now - start_time) > otp_time then
            minetest.kick_player(name, "OTP Code validation timed out")
            otp_sessions[name] = nil
        end
    end
    minetest.after(5, session_check)
end
minetest.after(5, session_check)

-- otp check
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= FORMNAME then
        return
    end

    local playername = player:get_player_name()
    local secret_b32 = otp.get_player_secret_b32(playername)
    local expected_code = otp.generate_totp(secret_b32)
    if expected_code == fields.code then
        minetest.chat_send_player(playername, "OTP Code validation succeeded")
        otp_sessions[playername] = nil
        regrant_privs(playername)
    else
        minetest.kick_player(playername, "OTP Code validation failed")
    end
end)