--- Author: COMT

--[[

	Codec - A Roblox Luau module for packing bytes into buffers.
	Mod: Array

	Array elements do not need to be the same size as long as the read functions return their respective elements' correct sizes.

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}


-- -- Functions

--[[
	Read an array whose size is limited to 255 elements.
	- Reads [1, unknown] bytes
]]
function Module.read255(b: buffer, offset: number, read: (b: buffer, offset: number) -> (any, number)): (any, number)
	local size = buffer_readu8(b, offset)
	local array = table_create(size, 0)
	local start = offset
	offset += 1
	for index = 1, size do
		local element, offsetOffset = read(b, offset)
		offset += offsetOffset
		array[index] = element
	end
	return offset - start
end

--[[
	Write an array whose size is limited to 255 elements.
	- Writes [1, unknown] bytes
]]
function Module.write255(b: buffer, offset: number, array: {any}, write: (b: buffer, offset: number, value: any) -> number): number
	local size = #array
	if size >= 0x100 then
		error("Expected array size less than or equal to 255, got " .. size)
	end
	buffer_writeu8(b, offset, size)
	local start = offset
	offset += 1
	for index = 1, size do
		offset += write(b, offset, array[index])
	end
	return offset - start
end

--[[
	Read an array whose size is limited to 65535 elements.
	- Reads [2, unknown] bytes
]]
function Module.read65535(b: buffer, offset: number, read: (b: buffer, offset: number) -> (any, number)): (any, number)
	local size = buffer_readu16(b, offset)
	local array = table_create(size, 0)
	local start = offset
	offset += 2
	for index = 1, size do
		local element, offsetOffset = read(b, offset)
		offset += offsetOffset
		array[index] = element
	end
	return offset - start
end

--[[
	Write an array whose size is limited to 65535 elements.
	- Writes [2, unknown] bytes
]]
function Module.write65535(b: buffer, offset: number, array: {any}, write: (b: buffer, offset: number, value: any) -> number): number
	local size = #array
	if size >= 0x10000 then
		error("Expected array size less than or equal to 65535, got " .. size)
	end
	buffer_writeu16(b, offset, size)
	local start = offset
	offset += 2
	for index = 1, size do
		offset += write(b, offset, array[index])
	end
	return offset - start
end

--[[
	Read an array of an arbitrary size.
	- Reads [0, unknown] bytes
]]
function Module.read(b: buffer, offset: number, read: (b: buffer, offset: number) -> (any, number?)): (any, number)
	local array = {}
	local index = 1
	local start = offset
	local element, offsetOffset = read(b, offset)
	while offsetOffset do
		offset += offsetOffset
		array[index] = element
    	index += 1
    	element, offsetOffset = read(b, offset)
	end
	return array, offset - start
end

--[[
	Write an array of an arbitrary size.
	- Writes [0, unknown] bytes
]]
function Module.write(b: buffer, offset: number, array: {any}, write: (b: buffer, offset: number, value: any) -> number): number
	local start = offset
	for _, value in ipairs(array) do
		offset += write(b, offset, value)
	end
	return offset - start
end


-- -- End

return Module
