--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: CFrame

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Functions

--[[
  Helper method for extracting a quaternion from a CFrame.
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
	local qX = buffer_readf32(b, offset + 12)
	local qY = buffer_readf32(b, offset + 16)
	local qZ = buffer_readf32(b, offset + 20)
	local qW = buffer_readf32(b, offset + 24)
  
	return cframe_new(x, y, z, qX, qY, qZ, qW), 28
end

--[[
	Write a CFrame.
	- Writes 28 bytes
]] 
function Module.write(b: buffer, offset: number, cframe: CFrame): number
	local x, y, z, m00, m01, m02, m10, m11, m12, m20, m21, m22 = quaternionXYZFromCFrame(

	buffer_writef32(b, offset, x)
	buffer_writef32(b, offset + 4, y)
	buffer_writef32(b, offset + 8, z)
	buffer_writef32(b, offset + 12, qX)
	buffer_writef32(b, offset + 16, qY)
	buffer_writef32(b, offset + 20, qZ)
	buffer_writef32(b, offset + 24, qW)
	
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
	local qX = readf16(b, offset + 6)
	local qY = readf16(b, offset + 8)
	local qZ = readf16(b, offset + 10)
	local qW = readf16(b, offset + 12)
  
	return cframe_new(x, y, z, qX, qY, qZ, qW), 14
end

--[[
	Write a half-precision CFrame.
	- Writes 14 bytes
]] 
function Module.writeHalfPrecision(b: buffer, offset: number, cframe: CFrame): number
	local x, y, z, m00, m01, m02, m10, m11, m12, m20, m21, m22 = quaternionXYZFromCFrame(cframe)

	writef16(b, offset, x)
	writef16(b, offset + 2, y)
	writef16(b, offset + 4, z)
	writef16(b, offset + 6, qX)
	writef16(b, offset + 8, qY)
	writef16(b, offset + 10, qZ)
	writef16(b, offset + 12, qW)

	return 14
end


-- -- End

return Module
