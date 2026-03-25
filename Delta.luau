--- Author: COMT

--[[

    Mod: Delta

    Note:  At the moment, read and write operations use the same state.  This will be the next thing for me to finalize.
    I may want to see if bit32_bor will be better than addition when I get the chance to test any of these repos.

    Read Pipeline:
        1. Run-length decode
        2. XOR delta decode
        3. Reconstruct bytes from lanes

    Write Pipeline:
        1. Separate bytes into lanes
        2. XOR delta encode
        3. Run-length encode

]]

--!strict
--!native
--!optimize 2


-- -- State

local Module = {}


-- -- Helpers

--local bit32_band = bit32.band
local bit32_bxor = bit32.bxor

local buffer_copy = buffer.copy
local buffer_create = buffer.create
local buffer_readf32 = buffer.readf32
local buffer_readf64 = buffer.readf64
local buffer_readu8 = buffer.readu8
local buffer_readu16 = buffer.readu16
local buffer_writef32 = buffer.writef32
local buffer_writef64 = buffer.writef64
local buffer_writeu8 = buffer.writeu8
local buffer_writeu16 = buffer.writeu16

local Intermediate = buffer_create(8)


-- -- Functions

local Lanes = buffer_create(0x80000)
local Lane1_Previous = 0
local Lane2_Previous = 0
local Lane3_Previous = 0
local Lane4_Previous = 0
local Lane5_Previous = 0
local Lane6_Previous = 0
local Lane7_Previous = 0
local Lane8_Previous = 0
local Lane1_Position = 0
local Lane2_Position = 0x10000
local Lane3_Position = 0x20000
local Lane4_Position = 0x30000
local Lane5_Position = 0x40000
local Lane6_Position = 0x50000
local Lane7_Position = 0x60000
local Lane8_Position = 0x70000

--[[ converting this to bit32 stuff is annoying and i'm too lazy to look at it right now
local function zigzag_encode(n: number): number
    return (n * 2) ~ (n // 0x80000000)
end

local function zigzag_decode(n: number): number
    return (n // 2) ~ -bit32_band(n, 1)
end
]]

function Module.read(b: buffer, offset: number)
	Lanes = b
	Lane1_Position, Lane2_Position, Lane3_Position, Lane4_Position, Lane5_Position, Lane6_Position, Lane7_Position, Lane8_Position = 0, buffer_readu16(b, offset), buffer_readu16(b, offset + 2), buffer_readu16(b, offset + 4), buffer_readu16(b, offset + 6), buffer_readu16(b, offset + 8), buffer_readu16(b, offset + 10), buffer_readu16(b, offset + 12)
	offset += 14
	Lane3_Position += Lane2_Position
	Lane4_Position += Lane3_Position
	Lane5_Position += Lane4_Position
	Lane6_Position += Lane5_Position
	Lane7_Position += Lane6_Position
	Lane8_Position += Lane7_Position
end

local function readu8(): number
	local value = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous)
	Lane1_Previous = value
	Lane1_Position += 1
	return value
end Module.readu8 = readu8

local function readu16(): number
	local low, high = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous)
	Lane1_Previous = low
	Lane2_Previous = high
	Lane1_Position += 1
	Lane2_Position += 1
	return low + high * 0x100
end Module.readu16 = readu16

local function readu24(): number
	local a, b, c = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	return a + b * 0x100 + c * 0x10000
end Module.readu24 = readu24

local function readu32(): number
	local a, b, c, d = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	return a + b * 0x100 + c * 0x10000 + d * 0x1000000
end Module.readu32 = readu32

local function readu40(): number
	local a, b, c, d, e = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous), bit32_bxor(buffer_readu8(Lanes, Lane5_Position), Lane5_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = e
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	return a + b * 0x100 + c * 0x10000 + d * 0x1000000 + e * 0x100000000
end Module.readu40 = readu40

local function readu48(): number
	local a, b, c, d, e, f = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous), bit32_bxor(buffer_readu8(Lanes, Lane5_Position), Lane5_Previous), bit32_bxor(buffer_readu8(Lanes, Lane6_Position), Lane6_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = e
	Lane6_Previous = f
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	Lane6_Position += 1
	return a + b * 0x100 + c * 0x10000 + d * 0x1000000 + e * 0x100000000 + f * 0x10000000000
end Module.readu32 = readu32

local function readf32_Quantized(scale: number): number
	local a, b, c, d = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	return (a + b * 0x100 + c * 0x10000 + d * 0x1000000) / scale
end Module.readf32_Quantized = readf32_Quantized

local function readf32_Raw(): number
	local a, b, c, d = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous)
	buffer_writeu8(Intermediate, 0, a)
	buffer_writeu8(Intermediate, 1, b)
	buffer_writeu8(Intermediate, 2, c)
	buffer_writeu8(Intermediate, 3, d)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane3_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	return buffer_readf32(Intermediate, 0)
end Module.readf32_Raw = readf32_Raw

local function readf64_Quantized(scale: number): number
	local a, b, c, d, e, f, g, h = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous), bit32_bxor(buffer_readu8(Lanes, Lane5_Position), Lane5_Previous), bit32_bxor(buffer_readu8(Lanes, Lane6_Position), Lane6_Previous), bit32_bxor(buffer_readu8(Lanes, Lane7_Position), Lane7_Previous), bit32_bxor(buffer_readu8(Lanes, Lane8_Position), Lane8_Previous)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = a
	Lane6_Previous = b
	Lane7_Previous = c
	Lane8_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	Lane6_Position += 1
	Lane7_Position += 1
	Lane8_Position += 1
	return (a + b * 0x100 + c * 0x10000 + d * 0x1000000 + e * 0x100000000 + f * 0x10000000000 + g * 0x1000000000000 + f * 0x100000000000000) / scale
end Module.readf64_Quantized = readf64_Quantized

local function readf64_Raw(): number
	local a, b, c, d, e, f, g, h = bit32_bxor(buffer_readu8(Lanes, Lane1_Position), Lane1_Previous), bit32_bxor(buffer_readu8(Lanes, Lane2_Position), Lane2_Previous), bit32_bxor(buffer_readu8(Lanes, Lane3_Position), Lane3_Previous), bit32_bxor(buffer_readu8(Lanes, Lane4_Position), Lane4_Previous), bit32_bxor(buffer_readu8(Lanes, Lane5_Position), Lane5_Previous), bit32_bxor(buffer_readu8(Lanes, Lane6_Position), Lane6_Previous), bit32_bxor(buffer_readu8(Lanes, Lane7_Position), Lane7_Previous), bit32_bxor(buffer_readu8(Lanes, Lane8_Position), Lane8_Previous)
	buffer_writeu8(Intermediate, 0, a)
	buffer_writeu8(Intermediate, 1, b)
	buffer_writeu8(Intermediate, 2, c)
	buffer_writeu8(Intermediate, 3, d)
	buffer_writeu8(Intermediate, 4, e)
	buffer_writeu8(Intermediate, 5, f)
	buffer_writeu8(Intermediate, 6, g)
	buffer_writeu8(Intermediate, 7, h)
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane3_Previous = d
	Lane4_Previous = e
	Lane5_Previous = f
	Lane6_Previous = g
	Lane7_Previous = h
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	Lane6_Position += 1
	Lane7_Position += 1
	Lane8_Position += 1
	return buffer_readf64(Intermediate, 0)
end Module.readf64_Raw = readf64_Raw

function Module.size(): number
	return Lane1_Position + Lane2_Position + Lane3_Position + Lane4_Position + 8
end

local function rleCompress(src: buffer, srcOffset: number, length: number, dst: buffer, dstOffset: number): number
	local i = 0

	while i < length do
		local byte = buffer_readu8(src, srcOffset + i)

		-- Zero run
		if byte == 0 then
			local run = 1
			while i + run < length and run < 255 and buffer_readu8(src, srcOffset + i + run) == 0 do
				run += 1
			end

			buffer_writeu8(dst, dstOffset, 0)
			buffer_writeu8(dst, dstOffset + 1, run)
			dstOffset += 2
			i += run

		else
			-- Literal run
			local start = i
			local run = 1

			while i + run < length and run < 255 do
				if buffer_readu8(src, srcOffset + i + run) == 0 then
					break
				end
				run += 1
			end

			buffer_writeu8(dst, dstOffset, run)
			dstOffset += 1

			for j = 0, run - 1 do
				buffer_writeu8(dst, dstOffset + j, buffer_readu8(src, srcOffset + start + j))
			end

			dstOffset += run
			i += run
		end
	end

	return dstOffset
end

function Module.write(b: buffer, offset: number): number
	local headerOffset = offset
	local mask = 0
	
	local previousOffset = offset + 3
	offset = rleCompress(Lanes, 0x00000, Lane1_Position, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		mask += 1
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x10000, Lane2_Position - 0x10000, b, previousOffset)
	if offset ~= previousOffset then
		print(offset, previousOffset)
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 2
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x20000, Lane3_Position - 0x20000, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 4
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x30000, Lane4_Position - 0x30000, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 8
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x40000, Lane5_Position - 0x40000, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 16
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x50000, Lane6_Position - 0x50000, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 32
	end
	
	previousOffset = offset + 2
	offset = rleCompress(Lanes, 0x60000, Lane7_Position - 0x60000, b, previousOffset)
	if offset ~= previousOffset then
		buffer_writeu16(b, previousOffset, offset - previousOffset)
	else
		offset -= 2
		mask += 64
	end
	
	rleCompress(Lanes, 0x70000, Lane8_Position - 0x70000, b, offset)
	
	buffer_writeu8(b, headerOffset, mask)
	
	Lane1_Position = 0x00000
	Lane2_Position = 0x10000
	Lane3_Position = 0x20000
	Lane4_Position = 0x30000
	Lane5_Position = 0x40000
	Lane6_Position = 0x50000
	Lane7_Position = 0x60000
	Lane8_Position = 0x70000
	
	return offset
end

local function writeu8(value: number)
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	Lane1_Previous = value
	Lane1_Position += 1
end Module.writeu8 = writeu8

local function writeu16(value: number)
	local high = (value // 0x100) % 0x100
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(high, Lane2_Previous))
	Lane1_Previous = value
	Lane2_Previous = high
	Lane1_Position += 1
	Lane2_Position += 1
end Module.writeu16 = writeu16

local function writeu24(value: number)
	local b, c = (value // 0x100) % 0x100, (value // 0x10000) % 0x100
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	Lane1_Previous = value
	Lane2_Previous = b
	Lane3_Previous = c
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
end Module.writeu24 = writeu24

local function writeu32(value: number)
	local b, c, d = (value // 0x100) % 0x100, (value // 0x10000) % 0x100, (value // 0x1000000) % 0x100
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	buffer_writeu8(Lanes, Lane4_Position, bit32_bxor(d, Lane4_Previous))
	Lane1_Previous = value
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
end Module.writeu32 = writeu32

local function writeu40(value: number)
	local b, c, d, e = (value // 0x100) % 0x100, (value // 0x10000) % 0x100, (value // 0x1000000) % 0x100, (value // 0x100000000) % 0x100
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	buffer_writeu8(Lanes, Lane4_Position, bit32_bxor(d, Lane4_Previous))
	buffer_writeu8(Lanes, Lane5_Position, bit32_bxor(e, Lane5_Previous))
	Lane1_Previous = value
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = e
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
end Module.writeu40 = writeu40

local function writeu48(value: number)
	local b, c, d, e, f = (value // 0x100) % 0x100, (value // 0x10000) % 0x100, (value // 0x1000000) % 0x100, (value // 0x100000000) % 0x100, (value // 0x10000000000) % 0x100
	value %= 0x100
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	buffer_writeu8(Lanes, Lane4_Position, bit32_bxor(d, Lane4_Previous))
	buffer_writeu8(Lanes, Lane5_Position, bit32_bxor(e, Lane5_Previous))
	buffer_writeu8(Lanes, Lane6_Position, bit32_bxor(f, Lane6_Previous))
	Lane1_Previous = value
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = e
	Lane6_Previous = f
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	Lane6_Position += 1
end Module.writeu48 = writeu48

local function writef32_Quantized(value: number, scale: number)
	writeu32(value * scale + 0.5)
end Module.writef32_Quantized = writef32_Quantized

local function writef32_Raw(value: number)
	buffer_writef32(Intermediate, 0, value)
	local a, b, c, d = buffer_readu8(Intermediate, 0), buffer_readu8(Intermediate, 1), buffer_readu8(Intermediate, 2), buffer_readu8(Intermediate, 3)
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(a, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	buffer_writeu8(Lanes, Lane4_Position, bit32_bxor(d, Lane4_Previous))
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
end Module.writef32_Raw = writef32_Raw

local function writef64_Quantized(value: number, scale: number)
	writeu32(value * scale + 0.5)
end Module.writef64_Quantized = writef64_Quantized

local function writef64_Raw(value: number)
	buffer_writef64(Intermediate, 0, value)
	local a, b, c, d, e, f, g, h = buffer_readu8(Intermediate, 0), buffer_readu8(Intermediate, 1), buffer_readu8(Intermediate, 2), buffer_readu8(Intermediate, 3), buffer_readu8(Intermediate, 4), buffer_readu8(Intermediate, 5), buffer_readu8(Intermediate, 6), buffer_readu8(Intermediate, 7)
	buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(a, Lane1_Previous))
	buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(b, Lane2_Previous))
	buffer_writeu8(Lanes, Lane3_Position, bit32_bxor(c, Lane3_Previous))
	buffer_writeu8(Lanes, Lane4_Position, bit32_bxor(d, Lane4_Previous))
	buffer_writeu8(Lanes, Lane5_Position, bit32_bxor(e, Lane5_Previous))
	buffer_writeu8(Lanes, Lane6_Position, bit32_bxor(f, Lane6_Previous))
	buffer_writeu8(Lanes, Lane7_Position, bit32_bxor(g, Lane7_Previous))
	buffer_writeu8(Lanes, Lane8_Position, bit32_bxor(h, Lane8_Previous))
	Lane1_Previous = a
	Lane2_Previous = b
	Lane3_Previous = c
	Lane4_Previous = d
	Lane5_Previous = e
	Lane6_Previous = f
	Lane7_Previous = g
	Lane8_Previous = h
	Lane1_Position += 1
	Lane2_Position += 1
	Lane3_Position += 1
	Lane4_Position += 1
	Lane5_Position += 1
	Lane6_Position += 1
	Lane7_Position += 1
	Lane8_Position += 1
end Module.writef64_Raw = writef64_Raw


-- -- End

return Module
