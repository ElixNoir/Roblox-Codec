--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: Mask

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local bit32_band = bit32.band
local bit32_bor = bit32.bor

local buffer_readu8 = buffer.readu8
local buffer_writeu8 = buffer.writeu8


-- -- Functions

function Module.read(b: buffer, offset: number): (boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean)
	local mask = buffer_readu8(b, offset)
	return bit32_band(mask, 1) == 1, bit32_band(mask, 2) == 2, bit32_band(mask, 4) == 4, bit32_band(mask, 8) == 8, bit32_band(mask, 16) == 16, bit32_band(mask, 32) == 32, bit32_band(mask, 64) == 64, bit32_band(mask, 128) == 128
end

function Module.write(b: buffer, offset: number, bit1: any, bit2: any, bit3: any, bit4: any, bit5: any, bit6: any, bit7: any, bit8: any): number
	buffer_writeu8(b, offset, bit32_bor((bit1 and 1 or 0), (bit2 and 2 or 0), (bit3 and 4 or 0), (bit4 and 8 or 0), (bit5 and 16 or 0), (bit6 and 32 or 0), (bit7 and 64 or 0), (bit8 and 128 or 0)))
	return 1
end


-- -- End

return Module
