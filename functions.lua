
-- https://stackoverflow.com/a/25594410
function otp.bitXOR(a,b)--Bitwise xor
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

function otp.write_uint64(v)
	local b1 = bitand(v, 0xFF)
	local b2 = bitand( rshift(v, 8), 0xFF )
	local b3 = bitand( rshift(v, 16), 0xFF )
	local b4 = bitand( rshift(v, 24), 0xFF )
	local b5 = bitand( rshift(v, 32), 0xFF )
	local b6 = bitand( rshift(v, 40), 0xFF )
	local b7 = bitand( rshift(v, 48), 0xFF )
	local b8 = bitand( rshift(v, 56), 0xFF )
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
        i_key_pad = i_key_pad .. string.char(otp.bitXOR(string.byte(key, i) or 0x00, string.byte(i_pad, i)))
    end

    local o_key_pad = ""
    for i=1,64 do
        o_key_pad = o_key_pad .. string.char(otp.bitXOR(string.byte(key, i) or 0x00, string.byte(o_pad, i)))
    end

    -- concat message
    local first_msg = i_key_pad
    for i=1,#message do
        first_msg = first_msg .. string.byte(message, i)
    end

    -- hash first message
    local hash_sum_1 = minetest.sha1(first_msg, true)

    -- concat first message to secons
    local second_msg = o_key_pad
    for i=1,#hash_sum_1 do
        second_msg = second_msg .. string.byte(hash_sum_1, i)
    end

    -- hash final message
    return minetest.sha1(second_msg, true)
end