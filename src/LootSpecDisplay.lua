OnPlayerLogin(function()
	if not EUIDB.lootSpecDisplay then return end

	local lootSpecId = nil

	local PlayerLootSpecFrame = CreateFrame("Frame", nil, PlayerFrame)

	PlayerLootSpecFrame:SetPoint("BOTTOMRIGHT", PlayerFrame.portrait, "BOTTOMRIGHT", 0, 0)
	PlayerLootSpecFrame:SetHeight(20)
	PlayerLootSpecFrame:SetWidth(46)
	PlayerLootSpecFrame.specname = PlayerLootSpecFrame:CreateFontString(nil)
	SetDefaultFont(PlayerLootSpecFrame.specname, 11)
	PlayerLootSpecFrame.specname:SetPoint("LEFT", PlayerLootSpecFrame, "LEFT", 0, 0)

	OnEvents({
		"PLAYER_ENTERING_WORLD",
		"PLAYER_LOOT_SPEC_UPDATED",
		"PLAYER_TALENT_UPDATE"
	}, function(_, event)
		local newLootSpecId = GetLootSpecialization()
		local lootIcon = ''

		if (lootSpecId ~= newLootSpecId or (not LootSpecId and event == "PLAYER_TALENT_UPDATE")) then
			lootSpecId = newLootSpecId

			if lootSpecId == 0 then
				lootSpecId = GetSpecialization()
			end

			lootIcon = select(4, GetSpecializationInfoByID(lootSpecId))

			if not lootIcon then return end

			local lootIconText = format('|T%s:16:16:0:0:64:64:4:60:4:60|t', lootIcon)
			PlayerLootSpecFrame.specname:SetFormattedText("%s", lootIconText)
		end
	end)
end)
