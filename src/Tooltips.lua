--------------------------------------------------------------------
---                     EmsUI Tooltips Module                    ---
--- Thanks to TipTac Reborn for mount code and LibFroznFunctions ---
--------------------------------------------------------------------
local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0")

function GetTooltipUnit()
	local unit = select(2, GameTooltip:GetUnit())

	if not unit then
		unit = "mouseover"
		local focus = GetMouseFoci()
		if (focus and focus.unit) then
			unit = focus.unit
		end
	end

	return unit
end

local function skinGameTooltip()
	local ns = GameTooltip.NineSlice

	local nsPoints = {
    "TopLeftCorner",
    "TopRightCorner",
    "BottomLeftCorner",
    "BottomRightCorner",
    "TopEdge",
    "BottomEdge",
    "LeftEdge",
    "RightEdge",
    "Center"
  }

  for _, nsPoint in pairs(nsPoints) do
    ns[nsPoint]:SetTexture(SQUARE_TEXTURE)
  end

	ns:SetCenterColor(0.08, 0.08, 0.08, 0.8)
	ns:SetBorderColor(0, 0, 0, 0)

	local border = GameTooltip.border
	if not border then
		border = CreateFrame('Frame', 'GameTooltipBorder', GameTooltip, "BackdropTemplate")
		border:SetPoint("TOPLEFT", GameTooltip, "TOPLEFT")
		border:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT")
		border:SetBackdrop(EUI_BACKDROP)
		border:SetBackdropBorderColor(0.08, 0.08, 0.08, 0.8)
		GameTooltip.border = border
	end
end

local function getUnitHealthColor(unit)
	local r, g, b

	if (UnitIsPlayer(unit)) then
		r, g, b = GetClassColor(select(2, UnitClass(unit)))
	else
		r, g, b = GameTooltip_UnitColor(unit)
		if (g == 0.6) then g = 0.9 end
		if (r == 1 and g == 1 and b == 1) then r, g, b = 0, 0.9, 0.1 end
	end

	return CreateColor(r, g, b)
end

local function cleanupTooltip(tip)
	local unit = GetTooltipUnit()
	local unitRecord = GetUnitRecord(unit)
	if not unitRecord then return end
	local creatureFamily = UnitCreatureFamily(unitRecord.id)
	local creatureType = UnitCreatureType(unitRecord.id)

	local hideCreatureTypeIfNoCreatureFamily = ((not unitRecord.isPlayer) or (unitRecord.isWildBattlePet)) and (not creatureFamily) and (creatureType)
	local hideSpecializationAndClassText = (unitRecord.isPlayer) and (LibFroznFunctions.hasWoWFlavor.specializationAndClassTextInPlayerUnitTip) and (unitRecord.className)

	local specNames = LibFroznFunctions:CreatePushArray()

	if (hideSpecializationAndClassText) then
		local specCount = C_SpecializationInfo.GetNumSpecializationsForClassID(unitRecord.classID)

		for i = 1, specCount do
			local _, specName = GetSpecializationInfoForClassID(unitRecord.classID, i, unitRecord.sex)

			specNames:Push(specName)
		end
	end

	for i = 2, tip:NumLines() do
		local gttLine = _G["GameTooltipTextLeft" .. i]
		local gttLineText = gttLine:GetText()

		if (type(gttLineText) == "string") then
			local isGttLineTextUnitPopupRightClick = (gttLineText == UNIT_POPUP_RIGHT_CLICK)
			local isSpecLine = unitRecord.className and (specNames:Contains(gttLineText:match("^(.+) " .. unitRecord.className .. "$")))

			if (isGttLineTextUnitPopupRightClick) or
					((gttLineText == FACTION_ALLIANCE) or (gttLineText == FACTION_HORDE) or (gttLineText == FACTION_NEUTRAL)) or
					(gttLineText == PVP_ENABLED) or
					(hideCreatureTypeIfNoCreatureFamily) and (gttLineText == creatureType) or
					(hideSpecializationAndClassText) and ((gttLineText == unitRecord.className) or isSpecLine) then

				if isSpecLine then
					tip.spec = gttLineText
				else
					gttLine:SetText(nil)
				end

				if (isGttLineTextUnitPopupRightClick) and (i > 1) then
					_G["GameTooltipTextLeft" .. (i - 1)]:SetText(nil)
				end
			end
		end
	end
end

local function addMount(unitID)
	local index = 0

	LibFroznFunctions:ForEachAura(unitID, LFF_AURA_FILTERS.Helpful, nil, function(unitAuraInfo)
		index = index + 1

		local spellID = unitAuraInfo.spellId

		if (spellID) then
			local mountID = LibFroznFunctions:GetMountFromSpell(spellID)

			if (mountID) then
				local mountText = LibFroznFunctions:CreatePushArray()
				local spacer

				local isCollected = LibFroznFunctions:IsMountCollected(mountID)

				if (isCollected) then
					mountText:Push(CreateAtlasMarkup("common-icon-checkmark"))
				else
					mountText:Push(CreateAtlasMarkup("common-icon-redx"))
				end

				mountText:Push(CreateTextureMarkup(unitAuraInfo.icon, 64, 64, 0, 0, 0.07, 0.93, 0.07, 0.93))

				if (unitAuraInfo.name) then
					spacer = (mountText:GetCount() > 0) and " " or ""

					mountText:Push(spacer .. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(unitAuraInfo.name))
				end

				GameTooltip:AddLine(("Mount: %s"):format(mountText:Concat()))

				return true
			end
		end
	end, true)
end

local function addMythicPlusScore(unitRecord)
	if (C_PlayerInfo.GetPlayerMythicPlusRatingSummary) then
		local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitRecord.id)
		if (ratingSummary) then
			local mythicPlusDungeonScore = ratingSummary.currentSeasonScore
			local mythicPlusBestRunLevel
			if (ratingSummary.runs) then
				for _, ratingMapSummary in ipairs(ratingSummary.runs or {}) do
					if (ratingMapSummary.finishedSuccess) and ((not mythicPlusBestRunLevel) or (mythicPlusBestRunLevel < ratingMapSummary.bestRunLevel)) then
						mythicPlusBestRunLevel = ratingMapSummary.bestRunLevel
					end
				end
			end

			local mythicPlusText = LibFroznFunctions:CreatePushArray()
			if (mythicPlusDungeonScore > 0) then
				local mythicPlusDungeonScoreColor = (C_ChallengeMode.GetDungeonScoreRarityColor(mythicPlusDungeonScore) or HIGHLIGHT_FONT_COLOR)
				mythicPlusText:Push(mythicPlusDungeonScoreColor:WrapTextInColorCode(mythicPlusDungeonScore))
			end
			if mythicPlusText:GetCount() > 0 then
				local lineInfo = LibFroznFunctions:CreatePushArray()
				lineInfo:Push("|cffffd100")
				lineInfo:Push(CHALLENGE_COMPLETE_DUNGEON_SCORE:format(mythicPlusText:Concat()))

				if mythicPlusBestRunLevel then
					lineInfo:Push(" |cffffff99(+" .. mythicPlusBestRunLevel .. ")|r")
				end

				GameTooltip:AddLine(lineInfo:Concat())
			end
		end
	end
end

local colors = {
  guildName = 'f232e7',
  guildRank = 'bd8cf2',
}

OnPlayerLogin(function()
	if
		C_AddOns.IsAddOnLoaded('TinyTooltip')
		or C_AddOns.IsAddOnLoaded('TipTac')
		or not EUIDB.enhanceTooltips
	then
		return
	end

	-- Tooltips anchored on mouse
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		if (InCombatLockdown() or EUIDB.tooltipAnchor == 'DEFAULT') then
	    self:SetOwner(parent, "ANCHOR_NONE")
		else
			self:SetOwner(parent, EUIDB.tooltipAnchor)
		end
	end)

	local bar = GameTooltipStatusBar
	bar.bg = bar:CreateTexture('GameTooltipStatusBarBackground', "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture(SQUARE_TEXTURE)
	bar.bg:SetVertexColor(0.2, 0.2, 0.2)

	bar.TextString = bar:CreateFontString('GameToolTipTextStatus', "OVERLAY")
	bar.TextString:SetPoint("CENTER")
	SetDefaultFont(bar.TextString, 11)

	-- Gametooltip statusbar
  bar:SetStatusBarTexture(EUIDB.healthBarTex)
	bar:ClearAllPoints()
	bar:SetPoint("LEFT", 7, 0)
	bar:SetPoint("RIGHT", -7, 0)
	bar:SetPoint("BOTTOM", 0, 7)
	bar:SetHeight(10)

  skinGameTooltip()

	-- Class colors
	local function onTooltipSetUnit(self)
    if self ~= GameTooltip then return end

		local unit = GetTooltipUnit()
		local unitRecord = GetUnitRecord(unit)

    skinGameTooltip()
		cleanupTooltip(self)

		local level = unitRecord.level
    if (level < 0) then
      level = "??"
    end

		local unitClassColor = getUnitHealthColor(unit)

		if UnitIsPlayer(unit) then
			local race = UnitRace(unit)

      -- Class coloured name
			if (EUIDB.tooltipClassColoredName) then
				local text = GameTooltipTextLeft1:GetText()
				GameTooltipTextLeft1:SetText(unitClassColor:WrapTextInColorCode(text))
			end

      local playerInfoLine = GameTooltipTextLeft2
			local guildName, guildRank, _, realm = GetGuildInfo(unit)
			local playerGuildName, _, _, playerRealm = GetGuildInfo("player")
			if (guildName == playerGuildName and realm == playerRealm) then
        playerInfoLine = GameTooltipTextLeft3
				local guildLine = GameTooltipTextLeft2
				guildLine:SetText('|cff' .. colors.guildName .. guildName .. '|r' .. '|cff' .. colors.guildRank .. ' (' .. guildRank .. ')|r')
			elseif guildName then
				playerInfoLine = GameTooltipTextLeft3
				local guildLine = GameTooltipTextLeft2
				guildLine:SetText(guildName .. ' (' .. guildRank .. ')')
			end

      playerInfoLine:SetText(level .. ' ' .. race .. ' ' .. unitClassColor:WrapTextInColorCode(unitRecord.className))

			-- Mount
			if EUIDB.tooltipShowMount then
				addMount(unit)
			end

			if EUIDB.tooltipShowMythicPlus then
				addMythicPlusScore(unitRecord)
			end

			-- recalculate size of tip to ensure that it has the correct dimensions
			LibFroznFunctions:RecalculateSizeOfGameTooltip(GameTooltip)
		end

		local family = UnitCreatureFamily(unit)
		if (family) then
			GameTooltipTextLeft2:SetText(level .. " " .. family)
		end

    -- Add room for the health bar
		if not EUIDB.tooltipHideHealthBar then
			GameTooltip:AddLine(' ')
		end
	end

  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
	GameTooltip:HookScript("OnUpdate", cleanupTooltip)

	GameTooltipStatusBar:HookScript("OnValueChanged", function(self)
		if EUIDB.tooltipHideHealthBar then
			self:Hide()
			return
		else
			self:Show()
		end

		local unit = GetTooltipUnit()
		local unitClassColor = getUnitHealthColor(unit)

	  self:SetStatusBarColor(unitClassColor:GetRGB())

		local value = UnitHealth(unit)
		local maxValue = UnitHealthMax(unit)

    if value == 0 and maxValue == 0 then return end
    local percent = math.floor(value / maxValue * 100)

    local textString = self.TextString
		textString:SetText('(' .. percent .. '%) ' .. AbbreviateLargeNumbers(value) .. ' / ' .. AbbreviateLargeNumbers(maxValue))
	end)
end)
