--- Author: COMT

--[[

  Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: Axes

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local bit32_band = bit32.band
local bit32_bor = bit32.bor

local buffer_readu8 = buffer.readu8


-- -- Functions

--[[
  Read an Axes.
  - Reads 2 bytes
]]
function Module.read(b: buffer, offset: number): (Axes, number)
  local mask = buffer_readu16(b, offset)
  return Axes.new(
    bit32_band(mask, 1) == 1,
    bit32_band(mask, 2) == 2,
    bit32_band(mask, 4) == 4,
    bit32_band(mask, 8) == 8,
    bit32_band(mask, 16) == 16,
    bit32_band(mask, 32) == 32,
    bit32_band(mask, 64) == 64,
    bit32_band(mask, 128) == 128,
    bit32_band(mask, 256) == 256
  ), 2
end

--[[
  Write an Axes.
  - Writes 2 bytes
]]
function Module.write(b: buffer, offset: number, axes: Axes): number
  buffer_writeu16(
    bit32_bor(
      axes.X and 1 or 0,
      axes.Y and 2 or 0,
      axes.Z and 4 or 0,
      axes.Back and 8 or 0,
      axes.Bottom and 16 or 0,
      axes.Front and 32 or 0,
      axes.Left and 64 or 0,
      axes.Right and 128 or 0,
      axes.Top and 256 or 0
    )
  )
  return 2
end


-- -- End

return Module
