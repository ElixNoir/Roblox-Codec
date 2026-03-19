--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: String

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Functions

--[[
  Read a string whose size is limited to 255 ASCII characters.
]]
function Module.readString255(b: buffer, offset: number): (string, number)
	local size = buffer_readu8(b, offset)
	return buffer_readstring(b, offset + 1, size), size + 1
end

--[[
  Write a string whose size is limited to 255 ASCII characters.
]]
function Module.writeString255(b: buffer, offset: number, str: string): number
	local size = #str
	if size >= 0x100 then
		error("Expected string size less than or equal to 255, got " .. size)
	end
	buffer_writeu8(b, offset, size)
	buffer_writestring(b, offset + 1, str, size)
	return size + 1
end

--[[
  Read a string whose size is limited to 65535 ASCII characters.
]]
function Module.readString65535(b: buffer, offset: number): (string, number)
	local size = buffer_readu16(b, offset)
	return buffer_readstring(b, offset + 2, size), size + 2
end

--[[
  Write a string whose size is limited to 65535 ASCII characters.
]]
function Module.writeString65535(b: buffer, offset: number, str: string): number
	local size = #str
	if size >= 0x10000 then
		error("Expected string size less than or equal to 65535, got " .. size)
	end
	buffer_writeu16(b, offset, size)
	buffer_writestring(b, offset + 2, str, size)
	return size + 2
end


-- -- End

return Module
