describe("TradeItemNameMap", function()
	local nameMap = LoadModule("Classes/TradeItemNameMap")

	it("loads the shipped zh_CN item data", function()
		assert.is_true(next(nameMap.getMap()) ~= nil)
	end)

	it("translates a unique item name", function()
		assert.equal("法师之血", nameMap.translateName("Mageblood"))
	end)

	it("prefers the plain name over decorated duplicates", function()
		assert.equal("神圣石", nameMap.translateName("Divine Orb"))
	end)

	it("returns nil for unknown names", function()
		assert.is_nil(nameMap.translateName("Not A Real Item"))
	end)

	it("translates name and type fields in a trade query", function()
		local query = {
			query = {
				name = "Mageblood",
				type = "Chaos Orb",
				stats = {
					{ type = "count", value = { min = 1 } },
				},
			},
		}
		nameMap.translateQuery(query)
		assert.equal("法师之血", query.query.name)
		assert.equal("混沌石", query.query.type)
		assert.equal("count", query.query.stats[1].type)
	end)
end)
