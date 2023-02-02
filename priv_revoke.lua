
-- privs to revoke until the verification code is validated
local temp_revoke_privs = {}

-- mark player health-related privs as "otp_keep" (they don't get removed while entering the otp code)
for _, name in ipairs({"fly", "noclip"}) do
    local priv_def = minetest.registered_privileges[name]
    if priv_def then
        priv_def.otp_keep = true
    end
end

minetest.register_on_mods_loaded(function()
    -- collect all privs to revoke while entering the otp code
    for name, priv_def in pairs(minetest.registered_privileges) do
        if not priv_def.otp_keep then
            -- not marked explicitly as "keep"
            table.insert(temp_revoke_privs, name)
        end
    end
end)

-- moves all "temp_revoke_privs" to mod-storage
function otp.revoke_privs(playername)
    local privs = minetest.get_player_privs(playername)
    if otp.storage:get_string(playername .. "_privs") == "" then
        local moved_privs = {}

        for _, priv_name in ipairs(temp_revoke_privs) do
            if privs[priv_name] then
                privs[priv_name] = nil
                moved_privs[priv_name] = true
            end
        end

        minetest.log("action", "[otp] revoking privs of '" .. playername .. "' list: " .. dump(moved_privs))
        minetest.set_player_privs(playername, privs)
        otp.storage:set_string(playername .. "_privs", minetest.serialize(moved_privs))
    end
end

-- moves all privs from mod-storage into the live privs
function otp.regrant_privs(playername)
    local stored_priv_str = otp.storage:get_string(playername .. "_privs")
    if stored_priv_str ~= "" then
        local privs = minetest.get_player_privs(playername)
        local stored_privs = minetest.deserialize(stored_priv_str)

        -- merge stored privs into existing table
        for priv_name in pairs(stored_privs) do
            privs[priv_name] = true
        end

        minetest.log("action", "[otp] regranting privs of '" .. playername .. "' list: " .. dump(stored_privs))
        minetest.set_player_privs(playername, privs)
        otp.storage:set_string(playername .. "_privs", "")
    end
end