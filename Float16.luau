--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: Float16

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local bit32_band = bit32.band
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift

local buffer_readu16 = buffer.readu16
local buffer_writeu16 = buffer.writeu16

local math_floor = math.floor


-- -- Functions

--[[
  Read a half-precision floating point value.
  - Range is [-65504, 65504]
]]
function Module.read(b: buffer, offset: number): (number, number)
	local bits = buffer_readu16(b, offset)
	if bits == 0 then
		return 0, 2
	end

	local sign = bit32_band(bits, 0x8000) ~= 0 and -1 or 1
	local exp  = bit32_band(bit32_rshift(bits, 10), 0x1F)
	local frac = bit32_band(bits, 0x3FF)

	if exp == 0 then
		return sign * (frac / 2 ^ 10) * 2 ^ -14, 2
	elseif exp == 0x1F then
		return frac == 0 and sign * math_huge or 0 / 0, 2
	else
		return sign * (1 + frac / 2 ^ 10) * 2 ^ (exp - 15), 2
	end
end

--[[
  Read a half-precision floating point value.
  - Range is [-65504, 65504]
]]
function Module.write(b: buffer, offset: number, value: number): number
	if value ~= value then
		buffer_writeu16(b, offset, 0x7E00)
		return 2
	end

	local sign = 0
	if value < 0 or (value == 0 and 1 / value < 0) then
		sign = 0x8000
		value = -value
	end

	if value == math_huge then
		buffer_writeu16(b, offset, sign + 0x7C00)
		return 2
	end

	if value == 0 then
		buffer_writeu16(b, offset, sign)
		return 2
	end

	local exp = math_floor(math_log(value, 2))
	local frac = value / (2 ^ exp)

	if frac < 1 then
		frac = frac * 2
		exp = exp - 1
	end

	local expHalf = exp + 15

	if expHalf <= 0 then
		local sub = math_floor(frac * 2 ^ (expHalf + 10))
		buffer_writeu16(b, offset, sign + sub)
	elseif expHalf >= 31 then
		buffer_writeu16(b, offset, sign + 0x7C00)
	else
		local mantissa = math_floor((frac - 1) * 1024 + 0.5)
		local bits = sign + bit32_lshift(expHalf, 10) + mantissa
		buffer_writeu16(b, offset, bits)
	end
	
	return 2
end


-- -- End

return Module
