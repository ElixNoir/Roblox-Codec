--- Author: COMT

--[[

    Mod: Delta

    Read Pipeline:
        1. Run-length decode
        2. XOR delta decode
        3. Unshuffle bytes

    Write Pipeline:
        1. Shuffle bytes
        2. XOR delta encode
        3. Run-length encode

]]

--!strict
--!native
--!optimize 2


-- -- State

local Module = {}


-- -- Helpers

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

local function zigzag_encode(n: number): number
    return (n << 1) ~ (n >> 31)
end

local function zigzag_decode(n: number): number
    return (n >> 1) ~ -(n & 1)
end

function Module.read(b: buffer, offset: number)
    Lanes = b
    Lane1_Position, Lane2_Position, Lane3_Position, Lane4_Position, Lane5_Position, Lane6_Position, Lane7_Position, Lane8_Position = 0, buffer_readu16(b, offset), buffer_readu16(b, offset + 2), buffer_readu16(b, offset + 4), buffer_readu16(b, offset + 6), buffer_readu16(b, offset + 8), buffer_readu16(b, offset + 10), buffer_readu16(b, offset + 12)
    offset += 14
    Lane2_Position += Lane1_Position
    Lane3_Position += Lane2_Position
    Lane4_Position += Lane3_Position
    Lane5_Position += Lane4_Position
    Lane6_Position += Lane5_Position
    Lane7_Position += Lane6_Position
    Lane8_Position = Lane7_Position
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

function Module.write(b: buffer, offset: number)
    buffer_writeu16(b, offset, Lane1_Position)
    buffer_writeu16(b, offset + 2, Lane2_Position - 0x10000)
    buffer_writeu16(b, offset + 4, Lane3_Position - 0x20000)
    buffer_writeu16(b, offset + 6, Lane4_Position - 0x30000)
    buffer_writeu16(b, offset + 8, Lane5_Position - 0x40000)
    buffer_writeu16(b, offset + 10, Lane6_Position - 0x50000)
    buffer_writeu16(b, offset + 12, Lane7_Position - 0x60000)

    offset += 14

    buffer_copy(b, offset, Lanes, 0, Lane1_Position)
    offset += Lane1_Position

    buffer_copy(b, offset, Lanes, 0, Lane2_Position)
    offset += Lane2_Position

    buffer_copy(b, offset, Lanes, 0, Lane3_Position)
    offset += Lane3_Position

    buffer_copy(b, offset, Lanes, 0, Lane4_Position)
    offset += Lane4_Position

    buffer_copy(b, offset, Lanes, 0, Lane5_Position)
    offset += Lane5_Position

    buffer_copy(b, offset, Lanes, 0, Lane6_Position)
    offset += Lane6_Position

    buffer_copy(b, offset, Lanes, 0, Lane7_Position)
    offset += Lane7_Position

    buffer_copy(b, offset, Lanes, 0, Lane8_Position)
    offset += Lane8_Position
end

local function writeu8(value: number)
    buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
    Lane1_Previous = value
    Lane1_Position += 1
end Module.writeu8 = writeu8

local function writeu16(value: number)
    local high = value // 0x100
    buffer_writeu8(Lanes, Lane1_Position, bit32_bxor(value, Lane1_Previous))
    buffer_writeu8(Lanes, Lane2_Position, bit32_bxor(high, Lane2_Previous))
    Lane1_Previous = value
    Lane2_Previous = high
    Lane1_Position += 1
    Lane2_Position += 1
end Module.writeu16 = writeu16

local function writeu24(value: number)
    local b, c = value // 0x100, value // 0x10000
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
    local b, c, d = value // 0x100, value // 0x10000, value // 0x1000000
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
    local b, c, d, e = value // 0x100, value // 0x10000, value // 0x1000000, value // 0x100000000
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
    local b, c, d, e, f = value // 0x100, value // 0x10000, value // 0x1000000, value // 0x100000000, value // 0x10000000000
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
    writeu32(math_floor(value * scale + 0.5))
end Module.writef32_Quantized = writef32_Quantized

local function writef32_Raw(value: number)
    buffer_writef32(Intermediate, 0, value)
    local a, b, c, d = buffer_readu8(Intermediary, 0), buffer_readu8(Intermediary, 1), buffer_readu8(Intermediary, 2), buffer_readu8(Intermediary, 3)
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
    writeu32(math_floor(value * scale + 0.5))
end Module.writef64_Quantized = writef64_Quantized

local function writef64_Raw(value: number)
    buffer_writef64(Intermediate, 0, value)
    local a, b, c, d, e, f, g, h = buffer_readu8(Intermediary, 0), buffer_readu8(Intermediary, 1), buffer_readu8(Intermediary, 2), buffer_readu8(Intermediary, 3), buffer_readu8(Intermediary, 4), buffer_readu8(Intermediary, 5), buffer_readu8(Intermediary, 6), buffer_readu8(Intermediary, 7)
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
