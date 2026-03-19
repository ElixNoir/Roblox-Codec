--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: Color3

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local buffer_readu8 = buffer.readu8
local buffer_writeu8 = buffer.writeu8

local color3_new = Color3.new


-- -- Functions

--[[
	Color3
	- Reads 3 bytes
]] 
function Module.readColor3(b: buffer, offset: number): (Color3, number)
	return color3_new(buffer_readu8(b, offset), buffer_readu8(b, offset), buffer_readu8(b, offset)), 3
end

--[[
	Color3
	- Writes 3 bytes
]] 
function Module.writeColor3(b: buffer, offset: number, color3: Color3): number
	buffer_writeu8(b, offset, color3.R)
	buffer_writeu8(b, offset + 1, color3.G)
	buffer_writeu8(b, offset + 2, color3.B)
	return 3
end


-- -- End

return Module
