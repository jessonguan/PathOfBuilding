-- Path of Building
--
-- Module: Trade Item Name Map
-- Maps English item names to Simplified Chinese names using the vendored
-- Awakened PoE Trade data at renderer/public/data/zh_CN/items.ndjson.
--
local dkjson = require "dkjson"

local ITEMS_RELATIVE = "vendor/awakened-poe-trade/renderer/public/data/zh_CN/items.ndjson"

local M = { }

local cachedMap

local function openItemsFile()
	local scriptPath = GetScriptPath()
	local candidates = { }
	if scriptPath and scriptPath ~= "" then
		candidates[#candidates + 1] = scriptPath .. "/../" .. ITEMS_RELATIVE
		candidates[#candidates + 1] = scriptPath .. "/" .. ITEMS_RELATIVE
	end
	candidates[#candidates + 1] = ITEMS_RELATIVE
	candidates[#candidates + 1] = "./src/../" .. ITEMS_RELATIVE
	for _, path in ipairs(candidates) do
		local file = io.open(path, "r")
		if file then
			return file
		end
	end
end

function M.getMap()
	if cachedMap then
		return cachedMap
	end
	local map = { }
	local file = openItemsFile()
	if not file then
		ConPrintf("Trade item name map: could not open " .. ITEMS_RELATIVE)
		cachedMap = map
		return cachedMap
	end
	for line in file:lines() do
		line = line:gsub("^%s+", ""):gsub("%s+$", "")
		if line ~= "" then
			local ok, entry = pcall(dkjson.decode, line)
			if ok and type(entry) == "table" and entry.refName and entry.name and entry.refName ~= entry.name then
				map[entry.refName] = entry.name
			end
		end
	end
	file:close()
	cachedMap = map
	return cachedMap
end

local function translateTable(tbl, map)
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			translateTable(value, map)
		elseif type(value) == "string" and (key == "name" or key == "type") and map[value] then
			tbl[key] = map[value]
		end
	end
	return tbl
end

--- Translate English item names found in a trade query in place.
--- Only fields named "name" or "type" are considered, so stat group types such
--- as "count" / "and" are left untouched.
function M.translateQuery(query)
	return translateTable(query, M.getMap())
end

--- Return the localized name for an English item name, or nil.
function M.translateName(name)
	return M.getMap()[name]
end

return M
