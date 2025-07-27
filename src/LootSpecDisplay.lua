OnPlayerLogin(function()
	-----------------------
	-- Loot Spec Display --
	-----------------------
	if EUIDB.lootSpecDisplay then
		local lootSpecId = nil

		local PlayerLootSpecFrame = CreateFrame("Frame", nil, PlayerFrame)

		PlayerLootSpecFrame:SetPoint("BOTTOMRIGHT", PlayerFrame.portrait, "BOTTOMRIGHT", 0, 0)
		PlayerLootSpecFrame:SetHeight(20)
		PlayerLootSpecFrame:SetWidth(46)
		PlayerLootSpecFrame.specname = PlayerLootSpecFrame:CreateFontString(nil)
		SetDefaultFont(PlayerLootSpecFrame.specname, 11)
		PlayerLootSpecFrame.specname:SetPoint("LEFT", PlayerLootSpecFrame, "LEFT", 0, 0)

		local LootDisplaySetupFrame = CreateFrame("FRAME")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		LootDisplaySetupFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
		LootDisplaySetupFrame:SetScript("OnEvent", function(self, event)
			-- Loot Spec
			local newLootSpecId = GetLootSpecialization()
			local lootIcon = ''

			if (lootSpecId ~= newLootSpecId or (not LootSpecId and event == "PLAYER_TALENT_UPDATE")) then
				lootSpecId = newLootSpecId

				if lootSpecId ~= 0 then
					_,_,_,lootIcon = GetSpecializationInfoByID(lootSpecId)
				else
					_,_,_,lootIcon = GetSpecializationInfo(GetSpecialization())
				end

				if not lootIcon then return end

				local lootIconText = format('|T%s:16:16:0:0:64:64:4:60:4:60|t', lootIcon)
				PlayerLootSpecFrame.specname:SetFormattedText("%s", lootIconText)
			end
		end)
	end
end)
