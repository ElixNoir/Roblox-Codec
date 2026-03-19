--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
  Mod: HumanoidDescription

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Helpers

local bit32_band = bit32.band
local bit32_bor = bit32.bor

local buffer_readf64 = buffer.readf64
local buffer_readu8 = buffer.readu8
local buffer_writef64 = buffer.writef64
local buffer_writeu8 = buffer.writeu8

local table_concat = table.concat


-- -- Functions

--[[
  Read a HumanoidDescription from accessories.
  - Reads [1, 16393] bytes
]]
function Module.readAccessories(b: buffer, offset: number, humanoidDescription: HumanoidDescription?): (HumanoidDescription, number)
	humanoidDescription = humanoidDescription or Instance.new("HumanoidDescription")
	local mask = buffer_readu8(b, offset)
	local start = offset
	offset += 1
	if bit32_band(mask, 1) == 1 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.BackAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 2) == 2 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.FaceAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 4) == 4 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.FrontAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 8) == 8 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.HairAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 16) == 16 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.HatAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 32) == 32 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.NeckAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 64) == 64 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.ShouldersAccessory = table_concat(t, ',')
	end
	if bit32_band(mask, 128) == 128 then
		local size = buffer_readu8(b, offset)
		offset += 1
		local t = table_create(size, 0)
		for index = 1, size do
			t[index] = buffer_readf64(b, offset)
			offset += 8
		end
		humanoidDescription.WaistAccessory = table_concat(t, ',')
	end
	return humanoidDescription, offset - start
end

--[[
  Write a HumanoidDescription from accessories.
  - Writes [1, 16393] bytes
]]
function Module.writeAccessories(b: buffer, offset: number, backAccessories: {number}?, faceAccessories: {number}?, frontAccessories: {number}?, hairAccessories: {number}?, hatAccessories: {number}?, neckAccessories: {number}?, shouldersAccessories: {number}?, waistAccessories: {number}?): number
	local bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8 = 0, 0, 0, 0, 0, 0, 0, 0
	local start = offset
	offset += 1
	if backAccessories then
		bit1 = 1
		local size = #backAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, backAccessories[index])
			offset += 8
		end
	end
	if faceAccessories then
		bit2 = 2
		local size = #faceAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, faceAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if frontAccessories then
		bit3 = 4
		local size = #frontAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, frontAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if hairAccessories then
		bit4 = 8
		local size = #hairAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, hairAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if hatAccessories then
		bit5 = 16
		local size = #hatAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, hatAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if neckAccessories then
		bit6 = 32
		local size = #neckAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, neckAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if shouldersAccessories then
		bit7 = 64
		local size = #shouldersAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, shouldersAccessories[index])
			offset += 8
		end
		offset += 8
	end
	if waistAccessories then
		bit8 = 128
		local size = #waistAccessories
		buffer_writeu8(b, offset, size)
		offset += 1
		for index = 1, size do
			buffer_writef64(b, offset, waistAccessories[index])
			offset += 8
		end
		offset += 8
	end
	buffer_writeu8(b, start, bit32_bor(bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8))
	return offset - start
end

--[[
  Read a HumanoidDescription from body.
  - Reads [1, 130] bytes
]]
function Module.readBody(b: buffer, offset: number, humanoidDescription: HumanoidDescription?): (HumanoidDescription, number)
	humanoidDescription = humanoidDescription or Instance.new("HumanoidDescription")
	local mask = buffer_readu16(b, offset)
	local start = offset
	offset += 2
	if bit32_band(mask, 1) == 1 then
		humanoidDescription.Face = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 2) == 2 then
		humanoidDescription.Head = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 4) == 4 then
		humanoidDescription.GraphicTShirt = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 8) == 8 then
		humanoidDescription.LeftArm = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 16) == 16 then
		humanoidDescription.LeftLeg = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 32) == 32 then
		humanoidDescription.Pants = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 64) == 64 then
		humanoidDescription.RightArm = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 128) == 128 then
		humanoidDescription.RightLeg = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 256) == 256 then
		humanoidDescription.Shirt = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 512) == 512 then
		humanoidDescription.Torso = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 1024) == 1024 then
		humanoidDescription.BodyTypeScale = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 2048) == 2048 then
		humanoidDescription.DepthScale = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 4096) == 4096 then
		humanoidDescription.HeadScale = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 8192) == 8192 then
		humanoidDescription.HeightScale = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 16384) == 16384 then
		humanoidDescription.ProportionScale = buffer_readf64(b, offset)
		offset += 8
	end
	if bit32_band(mask, 32768) == 32768 then
		humanoidDescription.WidthScale = buffer_readf64(b, offset)
		offset += 8
	end
	return humanoidDescription, offset - start
end

--[[
  Write a HumanoidDescription from body.
  - Writes [1, 130] bytes
]]
function Module.writeBody(b: buffer, offset: number, face: number?, head: number?, graphicTShirt: number?,  leftArm: number?, leftLeg: number?, pants: number?, rightArm: number?, rightLeg: number?, shirt: number?, torso: number?, bodyTypeScale: number?, depthScale: number?, headScale: number?, heightScale: number?, proportionScale: number?, widthScale: number?): number
	local bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8, bit9, bit10, bit11, bit12, bit13, bit14, bit15, bit16 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local start = offset
	offset += 2
	if face then
		bit1 = 1
		buffer_writef64(b, offset, face)
		offset += 8
	end
	if head then
		bit2 = 2
		buffer_writef64(b, offset, head)
		offset += 8
	end
	if graphicTShirt then
		bit3 = 4
		buffer_writef64(b, offset, graphicTShirt)
		offset += 8
	end
	if leftArm then
		bit4 = 8
		buffer_writef64(b, offset, leftArm)
		offset += 8
	end
	if leftLeg then
		bit5 = 16
		buffer_writef64(b, offset, leftLeg)
		offset += 8
	end
	if pants then
		bit6 = 32
		buffer_writef64(b, offset, pants)
		offset += 8
	end
	if rightArm then
		bit7 = 64
		buffer_writef64(b, offset, rightArm)
		offset += 8
	end
	if rightLeg then
		bit8 = 128
		buffer_writef64(b, offset, rightLeg)
		offset += 8
	end
	if shirt then
		bit9 = 256
		buffer_writef64(b, offset, shirt)
		offset += 8
	end
	if torso then
		bit10 = 512
		buffer_writef64(b, offset, torso)
		offset += 8
	end
	if bodyTypeScale then
		bit11 = 1024
		buffer_writef64(b, offset, bodyTypeScale)
		offset += 8
	end
	if depthScale then
		bit12 = 2048
		buffer_writef64(b, offset, depthScale)
		offset += 8
	end
	if headScale then
		bit13 = 4096
		buffer_writef64(b, offset, headScale)
		offset += 8
	end
	if heightScale then
		bit14 = 8192
		buffer_writef64(b, offset, heightScale)
		offset += 8
	end
	if proportionScale then
		bit15 = 16384
		buffer_writef64(b, offset, proportionScale)
		offset += 8
	end
	if widthScale then
		bit16 = 32768
		buffer_writef64(b, offset, widthScale)
		offset += 8
	end
	buffer_writeu16(b, start, bit32_bor(bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8, bit9, bit10, bit11, bit12, bit13, bit14, bit15, bit16))
	return offset - start
end


-- -- End

return Module
