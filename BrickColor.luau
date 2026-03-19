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


-- -- Functions

--[[
	Read a BrickColor.
	- Reads 2 bytes
]] 
function Module.readBrickColor(b: buffer, offset: number): (BrickColor, number)
	return brickcolor_new(buffer_readu16(b, offset)), 2
end

--[[
	Write a BrickColor.
	- Writes 2 bytes
]] 
function Module.writeBrickColor(b: buffer, offset: number, brickColor: BrickColor): number
	buffer_writeu16(b, offset, brickColor.Number)
	return 2
end


-- -- End

return Module
