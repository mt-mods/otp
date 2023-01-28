-- TODO

local auth_handler = minetest.get_auth_handler()

local old_get_auth = auth_handler.get_auth

auth_handler.get_auth = function(name)
    local auth = old_get_auth(name)

    if name ~= "singleplayer" then
        -- replace runtime password with legacy password hash
        auth.password = minetest.get_password_hash(name, "enter")
    end
    return auth
end