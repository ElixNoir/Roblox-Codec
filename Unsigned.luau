--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: Unsigned

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local buffer_readu8 = buffer.readu8
local buffer_readu16 = buffer.readu16
local buffer_readu32 = buffer.readu32
local buffer_writeu8 = buffer.writeu8
local buffer_writeu16 = buffer.writeu16
local buffer_writeu32 = buffer.writeu32


-- -- Functions

function Module.readu8(b: buffer, offset: number): (number, number)
	return buffer_readu8(b, offset), 1
end

function Module.writeu8(b: buffer, offset: number, value: number): number
	buffer_writeu8(b, offset, value)
	return 1
end

function Module.readu16(b: buffer, offset: number): (number, number)
	return buffer_readu16(b, offset), 2
end

function Module.writeu16(b: buffer, offset: number, value: number): number
	buffer_writeu16(b, offset, value)
	return 2
end

function Module.readu24(b: buffer, offset: number): (number, number)
	return buffer_readu8(b, offset + 2) * 0x10000 + buffer_readu16(b, offset), 3
end

function Module.writeu24(b: buffer, offset: number, value: number): number
	buffer_writeu16(b, offset, value)
	buffer_writeu8(b, offset + 2, value // 0x10000)
	return 3
end

function Module.readu32(b: buffer, offset: number): (number, number)
	return buffer_readu32(b, offset), 4
end

function Module.writeu32(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	return 4
end

function Module.readu40(b: buffer, offset: number): (number, number)
	return buffer_readu32(b, offset) + buffer_readu8(b, offset + 4) * 0x100000000, 5
end

function Module.writeu40(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu8(b, offset + 4, value // 0x100000000)
	return 5
end

function Module.readu48(b: buffer, offset: number): (number, number)
	return buffer_readu32(b, offset) + buffer_readu16(b, offset + 4) * 0x100000000, 6
end

function Module.writeu48(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu16(b, offset + 4, value // 0x100000000)
	return 6
end

--[[
  IMPORTANT:  Luau numbers are double-precision floating points (f64), integer-accurate to only 53 bits.  Because of this, readu56 has a chance to be very inaccurate.
]]
function Module.readu56(b: buffer, offset: number): (number, number)
	return buffer_readu32(b, offset) + buffer_readu16(b, offset + 4) * 0x100000000 + buffer_readu8(b, offset + 5) * 0x1000000000000, 7
end

--[[
  IMPORTANT:  Luau numbers are double-precision floating points (f64), integer-accurate to only 53 bits.  Because of this, writeu56 has a chance to be very inaccurate.
]]
function Module.writeu56(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu16(b, offset + 4, value // 0x100000000)
	buffer_writeu8(b, offset + 5, value // 0x1000000000000)
	return 7
end

--[[
  IMPORTANT:  Luau numbers are double-precision floating points (f64), integer-accurate to only 53 bits.  Because of this, readu64 has a chance to be very inaccurate.
]]
function Module.readu64(b: buffer, offset: number): (number, number)
	return buffer_readu32(b, offset) + buffer_readu32(b, offset + 4) * 0x100000000, 8
end

--[[
  IMPORTANT:  Luau numbers are double-precision floating points (f64), integer-accurate to only 53 bits.  Because of this, writeu64 has a chance to be very inaccurate.
]]
function Module.writeu64(b: buffer, offset: number, value: number): number
	buffer_writeu32(b, offset, value)
	buffer_writeu32(b, offset + 4, value // 0x100000000)
	return 8
end


-- -- End

return Module
