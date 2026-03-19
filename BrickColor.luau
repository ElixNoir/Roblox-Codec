--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: BrickColor

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local brickcolor_new = BrickColor.new

local buffer_readu16 = buffer.readu16
local buffer_writeu16 = buffer.writeu16


-- -- Functions

--[[
	Read a BrickColor.
	- Reads 2 bytes
]] 
function Module.read(b: buffer, offset: number): (BrickColor, number)
	return brickcolor_new(buffer_readu16(b, offset)), 2
end

--[[
	Write a BrickColor.
	- Writes 2 bytes
]] 
function Module.write(b: buffer, offset: number, brickColor: BrickColor): number
	buffer_writeu16(b, offset, brickColor.Number)
	return 2
end


-- -- End

return Module
