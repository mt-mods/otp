
-- https://stackoverflow.com/a/25594410
local function bitxor(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

local function bitor(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

-- https://stackoverflow.com/a/32387452
local function bitand(a, b)
	local result = 0
	local bitval = 1
	while a > 0 and b > 0 do
	  if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
		  result = result + bitval      -- set the current bit
	  end
	  bitval = bitval * 2 -- shift left
	  a = math.floor(a/2) -- shift right
	  b = math.floor(b/2)
	end
	return result
end

-- https://gist.github.com/mebens/938502
local function rshift(x, by)
	return math.floor(x / 2 ^ by)
end

local function lshift(x, by)
    return x * 2 ^ by
end

-- big-endian uint64 of a number
function otp.write_uint64_be(v)
	local b1 = bitand( rshift(v, 56), 0xFF )
	local b2 = bitand( rshift(v, 48), 0xFF )
	local b3 = bitand( rshift(v, 40), 0xFF )
	local b4 = bitand( rshift(v, 32), 0xFF )
	local b5 = bitand( rshift(v, 24), 0xFF )
	local b6 = bitand( rshift(v, 16), 0xFF )
	local b7 = bitand( rshift(v, 8), 0xFF )
	local b8 = bitand( rshift(v, 0), 0xFF )
	return string.char(b1, b2, b3, b4, b5, b6, b7, b8)
end

-- prepare paddings
-- https://en.wikipedia.org/wiki/HMAC
local i_pad = ""
local o_pad = ""
for _=1,64 do
    i_pad = i_pad .. string.char(0x36)
    o_pad = o_pad .. string.char(0x5c)
end

-- hmac generation
function otp.hmac(key, message)
    local i_key_pad = ""
    for i=1,64 do
        i_key_pad = i_key_pad .. string.char(bitxor(string.byte(key, i) or 0x00, string.byte(i_pad, i)))
    end
    assert(#i_key_pad == 64)

    local o_key_pad = ""
    for i=1,64 do
        o_key_pad = o_key_pad .. string.char(bitxor(string.byte(key, i) or 0x00, string.byte(o_pad, i)))
    end
    assert(#o_key_pad == 64)

    -- concat message
    local first_msg = i_key_pad
    for i=1,#message do
        first_msg = first_msg .. string.char(string.byte(message, i))
    end
    assert(#first_msg == 64+8)

    -- hash first message
    local hash_sum_1 = minetest.sha1(first_msg, true)
    assert(#hash_sum_1 == 20)

    -- concat first message to secons
    local second_msg = o_key_pad
    for i=1,#hash_sum_1 do
        second_msg = second_msg .. string.char(string.byte(hash_sum_1, i))
    end
    assert(#second_msg == 64+20)

    local hmac = minetest.sha1(second_msg, true)
    assert(#hmac == 20)

    return hmac
end

function otp.generate_code(key, message)
    local hmac = otp.hmac(key, message)

    -- https://www.rfc-editor.org/rfc/rfc4226#section-5.4
    local offset = bitand(string.byte(hmac, #hmac), 0xF)
    local value = 0
    value = bitor(value, string.byte(hmac, offset+4))
    value = bitor(value, lshift(string.byte(hmac, offset+3), 8))
    value = bitor(value, lshift(string.byte(hmac, offset+2), 16))
    value = bitor(value, lshift(bitand(string.byte(hmac, offset+1), 0x7F), 24))
    return value % 10^6
end