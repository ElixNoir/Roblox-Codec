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


-- -- Helpers

--[[
  Extract a quaternion from a CFrame.
  returns: rx, ry, rz, rw
--]]
local function quaternionFromCFrame(cframe: CFrame): (number, number, number, number)
  local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cframe:Orthonormalize():GetComponents()

	local trace = m00 + m11 + m22
	if trace > 0 then
		local s = math_sqrt(trace + 1) * 2
		return (m21 - m12) / s, y = (m02 - m20) / s, (m10 - m01) / s, 0.25 * s
	elseif m00 > m11 and m00 > m22 then
		local s = math_sqrt(1 + m00 - m11 - m22) * 2
		return 0.25 * s, (m01 + m10) / s, (m02 + m20) / s, (m21 - m12) / s
	elseif m11 > m22 then
		local s = math_sqrt(1 + m11 - m00 - m22) * 2
		return (m01 + m10) / s, 0.25 * s, (m12 + m21) / s, (m02 - m20) / s
	else
		local s = math_sqrt(1 + m22 - m00 - m11) * 2
		return (m02 + m20) / s, (m12 + m21) / s, 0.25 * s, (m10 - m01) / s
	end
end


-- -- Functions

--[[
	Read a quaternion.
	- Reads 16 bytes
]] 
function Module.read(b: buffer, offset: number): (CFrame, number)
	local qX = buffer_readf32(b, offset)
	local qY = buffer_readf32(b, offset + 4)
	local qZ = buffer_readf32(b, offset + 8)
	local qW = buffer_readf32(b, offset + 12)

	return cframe_new(0, 0, 0, qX, qY, qZ, qW), 16
end

--[[
	Write a quaternion.
	- Writes 16 bytes
]] 
function Module.write(b: buffer, offset: number, cframe: CFrame): number
	local rx, ry, rz, rw = quaternionFromCFrame(cframe)
	
	buffer_writef32(b, offset, rx)
	buffer_writef32(b, offset + 4, ry)
	buffer_writef32(b, offset + 8, rz)
	buffer_writef32(b, offset + 12, rw)
	
	return 16
end

--[[
	Read a fixed-precision quaternion.
	- Reads 4 bytes
]] 
function Module.readFixedPrecision(b: buffer, offset: number): (CFrame, number)
	local qX = 2 * (buffer_readu8(b, offset) / 255) - 1
	local qY = 2 * (buffer_readu8(b, offset + 1) / 255) - 1
	local qZ = 2 * (buffer_readu8(b, offset + 2) / 255) - 1
	local qW = 2 * (buffer_readu8(b, offset + 3) / 255) - 1

	return cframe_new(0, 0, 0, qX, qY, qZ, qW), 4
end

--[[
	Write a fixed-precision quaternion.
	- Writes 4 bytes
]] 
function Module.writeFixedPrecision(b: buffer, offset: number, cframe: CFrame): number
	local rx, ry, rz, rw = quaternionFromCFrame(cframe)

	buffer_writeu8(b, offset, math_floor((rx / 2 + .5) * 0xFF + .5))
	buffer_writeu8(b, offset + 1, math_floor((ry / 2 + .5) * 0xFF + .5))
	buffer_writeu8(b, offset + 2, math_floor((rz / 2 + .5) * 0xFF + .5))
	buffer_writeu8(b, offset + 3, math_floor((rw / 2 + .5) * 0xFF + .5))

	return 4
end

--[[
	Read a half-precision quaternion.
	- Reads 8 bytes
]] 
function Module.readHalfPrecision(b: buffer, offset: number): (CFrame, number)
	local qX = readf16(b, offset)
	local qY = readf16(b, offset + 2)
	local qZ = readf16(b, offset + 4)
	local qW = readf16(b, offset + 6)

	return cframe_new(0, 0, 0, qX, qY, qZ, qW), 8
end

--[[
	Write a half-precision quaternion.
	- Writes 8 bytes
]] 
function Module.writeHalfPrecision(b: buffer, offset: number, cframe: CFrame): number
	local rx, ry, rz, rw = quaternionFromCFrame(cframe)

	writef16(b, offset, rx)
	writef16(b, offset + 2, ry)
	writef16(b, offset + 4, rz)
	writef16(b, offset + 6, rw)

	return 8
end


-- -- End

return Module
