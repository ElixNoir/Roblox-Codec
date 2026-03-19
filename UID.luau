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
function Module.write(b: buffer, offset: number, uuid: string): number
	uuid = uuid:gsub('-', '')
  
	buffer_writeu32(b, offset, tonumber(uuid:sub(1, 8), 16))
	buffer_writeu32(b, offset + 4, tonumber(uuid:sub(9, 16), 16))
	buffer_writeu32(b, offset + 8, tonumber(uuid:sub(17, 24), 16))
	buffer_writeu32(b, offset + 12, tonumber(uuid:sub(25, 32), 16))
	
	return 16
end


-- -- End

return Module
