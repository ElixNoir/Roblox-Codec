--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: UID

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local bit32_band = bit32.band
local bit32_rshift = bit32.rshift

local buffer_readu32 = buffer.readu32
local buffer_writeu32 = buffer.writeu32

local string_format = string.format
local string_gsub = string.gsub
local string_sub = string.sub


-- -- Functions

--[[
	Read a unique identity.
	- Reads 16 bytes
]] 
function Module.read(b: buffer, offset: number): (string, number)
	local raw1 = buffer_readu32(b, offset + 4)
	local raw2 = buffer_readu32(b, offset + 8)

	return string_format("%s-%s-%s-%s-%s%s",
		string_format("%08x", buffer_readu32(b, offset)),
		string_format("%04x", bit32_rshift(raw1, 16)),
		string_format("%04x", bit32_band(raw1, 0xFFFF)),
		string_format("%04x", bit32_rshift(raw2, 16)),
		string_format("%04x", bit32_band(raw2, 0xFFFF)),
		string_format("%08x", buffer_readu32(b, offset + 12))
	), 16
end

--[[
	Write a unique identity.
	- Writes 16 bytes
]] 
function Module.write(b: buffer, offset: number, uid: string): number
	uid = string_gsub(uid, '-', '')
  
	buffer_writeu32(b, offset, tonumber(string_sub(uid, 1, 8), 16))
	buffer_writeu32(b, offset + 4, tonumber(string_sub(uid, 9, 16), 16))
	buffer_writeu32(b, offset + 8, tonumber(string_sub(uid, 17, 24), 16))
	buffer_writeu32(b, offset + 12, tonumber(string_sub(uid, 25, 32), 16))
	
	return 16
end


-- -- End

return Module
