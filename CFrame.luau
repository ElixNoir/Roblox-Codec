--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: CFrame

]]

--!native
--!optimize 2
--!strict


-- -- State

local Codec_Float16 = require(script.Parent.Float16)

local Module = {}


-- -- Helpers

local buffer_readu32 = buffer.readu32
local buffer_writeu32 = buffer.writeu32

local math_sqrt = math.sqrt

local readf16 = Codec_Float16.read
local writef16 = Codec_Float16.write


-- -- Functions

--[[
  Extract a quaternion from a CFrame.
  returns: x, y, z, rx, ry, rz, rw
--]]
local function quaternionXYZFromCFrame(cframe: CFrame): (number, number, number, number, number, number, number)
  local x, y, z, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cframe:Orthonormalize():GetComponents()

	local trace = m00 + m11 + m22
	if trace > 0 then
		local s = math_sqrt(trace + 1) * 2
		return x, y, z, (m21 - m12) / s, y = (m02 - m20) / s, (m10 - m01) / s, 0.25 * s
	elseif m00 > m11 and m00 > m22 then
		local s = math_sqrt(1 + m00 - m11 - m22) * 2
		return x, y, z, 0.25 * s, (m01 + m10) / s, (m02 + m20) / s, (m21 - m12) / s
	elseif m11 > m22 then
		local s = math_sqrt(1 + m11 - m00 - m22) * 2
		return x, y, z, (m01 + m10) / s, 0.25 * s, (m12 + m21) / s, (m02 - m20) / s
	else
		local s = math_sqrt(1 + m22 - m00 - m11) * 2
		return x, y, z, (m02 + m20) / s, (m12 + m21) / s, 0.25 * s, (m10 - m01) / s
	end
end

--[[
	Read a CFrame.
	- Reads 28 bytes
]] 
function Module.read(b: buffer, offset: number): (CFrame, number)
	local x = buffer_readf32(b, offset)
	local y = buffer_readf32(b, offset + 4)
	local z = buffer_readf32(b, offset + 8)
	local rx = buffer_readf32(b, offset + 12)
	local ry = buffer_readf32(b, offset + 16)
	local rz = buffer_readf32(b, offset + 20)
	local rw = buffer_readf32(b, offset + 24)
  
	return cframe_new(x, y, z, rx, ry, rz, rw), 28
end

--[[
	Write a CFrame.
	- Writes 28 bytes
]] 
function Module.write(b: buffer, offset: number, cframe: CFrame): number
	local x, y, z, rx, ry, rz, rw = quaternionXYZFromCFrame(cframe)

	buffer_writef32(b, offset, x)
	buffer_writef32(b, offset + 4, y)
	buffer_writef32(b, offset + 8, z)
	buffer_writef32(b, offset + 12, rx)
	buffer_writef32(b, offset + 16, ry)
	buffer_writef32(b, offset + 20, rz)
	buffer_writef32(b, offset + 24, rw)
	
	return 28
end

--[[
	Read a half-precision CFrame.
	- Reads 14 bytes
]] 
function Module.readHalfPrecision(b: buffer, offset: number): (CFrame, number)
	local x = readf16(b, offset)
	local y = readf16(b, offset + 2)
	local z = readf16(b, offset + 4)
	local rx = readf16(b, offset + 6)
	local ry = readf16(b, offset + 8)
	local rz = readf16(b, offset + 10)
	local rw = readf16(b, offset + 12)
  
	return cframe_new(x, y, z, rx, ry, rz, rw), 14
end

--[[
	Write a half-precision CFrame.
	- Writes 14 bytes
]] 
function Module.writeHalfPrecision(b: buffer, offset: number, cframe: CFrame): number
	local x, y, z, rx, ry, rz, rw = quaternionXYZFromCFrame(cframe)

	writef16(b, offset, x)
	writef16(b, offset + 2, y)
	writef16(b, offset + 4, z)
	writef16(b, offset + 6, rx)
	writef16(b, offset + 8, ry)
	writef16(b, offset + 10, rz)
	writef16(b, offset + 12, rw)

	return 14
end


-- -- End

return Module
