--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: Signed

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local buffer_readi8 = buffer.readi8
local buffer_readi16 = buffer.readi16
local buffer_readi32 = buffer.readi32
local buffer_readu8 = buffer.readu8
local buffer_readu16 = buffer.readu16
local buffer_readu32 = buffer.readu32
local buffer_writei8 = buffer.writei8
local buffer_writei16 = buffer.writei16
local buffer_writei32 = buffer.writei32
local buffer_writeu8 = buffer.writeu8
local buffer_writeu16 = buffer.writeu16
local buffer_writeu32 = buffer.writeu32


-- -- Functions

function Module.readi8(b: buffer, offset: number): (number, number)
	return buffer_readi8(b, offset), 1
end

function Module.writei8(b: buffer, offset: number, value: number): number
	buffer_writei8(b, offset, value)
	return 1
end

function Module.readi16(b: buffer, offset: number): (number, number)
	return buffer_readi16(b, offset), 2
end

function Module.writei16(b: buffer, offset: number, value: number): number
	buffer_writei16(b, offset, value)
	return 2
end

function Module.readi24(b: buffer, offset: number): (number, number)
	local value = buffer_readu16(b, offset) + buffer_readu8(b, offset + 2) * 0x10000
	if value >= 0x800000 then
    return value - 0x1000000, 3
  end
	return value, 3
end

function Module.writei24(b: buffer, offset: number, value: number): number
	buffer_writeu16(b, offset, value)
	buffer_writeu8(b, offset + 2, value // 0x10000)
	return 3
end

function Module.readi32(b: buffer, offset: number, value: number): number
	return buffer_readi32(b, offset), 4
end

function Module.writei32(b: buffer, offset: number, value: number): number
	buffer_writei32(b, offset, value)
	return 4
end

function Module.readi40(b: buffer, offset: number): (number, number)
	local value = buffer_readu32(b, offset) + buffer_readu8(b, offset + 4) * 0x100000000
	if value >= 0x8000000000 then
    return value - 0x10000000000, 5
  end
	return value, 5
end

function Module.writei40(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu8(b, offset + 4, value // 0x100000000)
	return 5
end

function Module.readi48(b: buffer, offset: number): (number, number)
	local value = buffer_readu32(b, offset) + buffer_readu16(b, offset + 4) * 0x100000000
	if value >= 0x800000000000 then
    return value - 0x1000000000000, 6
  end
	return value, 6
end

function Module.writei48(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu16(b, offset + 4, value // 0x100000000)
	return 6
end


-- -- End

return Module
