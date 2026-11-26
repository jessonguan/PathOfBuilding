-- Path of Building
--
-- Module: Trade Item Name Map
-- Maps English item names to Simplified Chinese names using the item data at
-- Data/Trade/zh_CN/items.ndjson. That file is copied from the Awakened PoE
-- Trade submodule (vendor/awakened-poe-trade, MIT) so it is shipped as part of
-- the program files instead of depending on submodule contents at runtime.
--
local dkjson = require "dkjson"

local ITEMS_RELATIVE = "Data/Trade/zh_CN/items.ndjson"

local M = { }

local cachedMap

-- Some entries duplicate an item's refName with a decorated display name, e.g.
-- "★★神圣石" or "危城巷弄[灵投火兽]". Those are not valid trade item names, so
-- they are skipped in favour of the plain name.
-- Note: plain finds are required here because Lua patterns are byte-based and a
-- multi-byte character inside a set would match any character sharing its bytes.
local decorationMarkers = { "◆", "★", "[" }

local function isDecorated(name)
	for _, marker in ipairs(decorationMarkers) do
		if name:find(marker, 1, true) then
			return true
		end
	end
	return false
end

local function cleanName(name)
	local trimmed = name:match("^%s*(.-)%s*$")
	if trimmed == "" or isDecorated(trimmed) then
		return nil
	end
	return trimmed
end

local function openItemsFile()
	local scriptPath
	if type(GetScriptPath) == "function" then
		scriptPath = GetScriptPath()
	end
	local candidates = { }
	if scriptPath and scriptPath ~= "" then
		candidates[#candidates + 1] = scriptPath .. "/" .. ITEMS_RELATIVE
		candidates[#candidates + 1] = scriptPath .. "/../src/" .. ITEMS_RELATIVE
	end
	candidates[#candidates + 1] = ITEMS_RELATIVE
	candidates[#candidates + 1] = "./src/" .. ITEMS_RELATIVE
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
			if ok and type(entry) == "table" and entry.refName and entry.name then
				local name = cleanName(entry.name)
				if name and entry.refName ~= name then
					map[entry.refName] = name
				end
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
