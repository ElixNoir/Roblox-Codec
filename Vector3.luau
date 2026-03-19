--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: Vector3

]]

--!native
--!optimize 2
--!strict


-- -- State

local Codec_Float16 = require(script.Parent.Float16)

local Module = {}


-- -- Helpers

local buffer_readf32 = buffer.readf32
local buffer_readi8 = buffer.readi8
local buffer_writef32 = buffer.writef32
local buffer_writei8 = buffer.writei8

local vector_create = vector.create

local readf16 = Codec_Float16.read
local writef16 = Codec_Float16.write


-- -- Functions

--[[
	Read a Vector3.
	- Reads 12 bytes
]] 
function Module.read(b: buffer, offset: number, vector3: Vector3): (vector, number)
	return vector_create(buffer_readf32(b, offset), buffer_readf32(b, offset + 4), buffer_readf32(b, offset + 8)), 12
end

--[[
	Write a Vector3.
	- Writes 12 bytes
]] 
function Module.write(b: buffer, offset: number, vector3: Vector3): number
	buffer_writef32(b, offset, vector3.X)
	buffer_writef32(b, offset + 4, vector3.Y)
	buffer_writef32(b, offset + 8, vector3.Z)
	return 12
end

--[[
	Read a fixed-precision Vector3.
	- Reads 3 bytes
]] 
function Module.readFixedPrecision(b: buffer, offset: number, vector3: Vector3): (vector, number)
	local x, y, z = buffer_readi8(b, offset), buffer_readi8(b, offset + 1), buffer_readi8(b, offset + 2)
	return vector_create(x, y, z), 3
end

--[[
	Write a fixed-precision Vector3.
	- Writes 3 bytes
]] 
function Module.writeFixedPrecision(b: buffer, offset: number, vector3: Vector3): number
	buffer_writei8(b, offset, vector3.X)
	buffer_writei8(b, offset + 1, vector3.Y)
	buffer_writei8(b, offset + 2, vector3.Z)
	return 3
end

--[[
	Read a half-precision Vector3.
	- Reads 6 bytes
]] 
function Module.readHalfPrecision(b: buffer, offset: number, vector3: Vector3): (vector, number)
	local x, y, z = readf16(b, offset), readf16(b, offset + 2), readf16(b, offset + 4)
	return vector_create(x, y, z), 6
end

--[[
	Write a half-precision Vector3.
	- Writes 6 bytes
]] 
function Module.writeHalfPrecision(b: buffer, offset: number, vector3: Vector3): number
	writef16(b, offset, vector3.X)
	writef16(b, offset + 2, vector3.Y)
	writef16(b, offset + 4, vector3.Z)
	return 6
end


-- -- End

return Module
