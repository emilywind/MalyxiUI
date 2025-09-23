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
		if focus and focus.unit then
			unit = focus.unit
		end
	end

	return unit
end

local initTooltips = false
function InitTooltips()
	if initTooltips or not EUIDB.enhanceTooltips then return end

	-- Tooltips anchored on mouse
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
		if (InCombatLockdown() or EUIDB.tooltipAnchor == 'DEFAULT') then
	    self:SetOwner(parent, "ANCHOR_NONE")
		else
			self:SetOwner(parent, EUIDB.tooltipAnchor)
		end
	end)

	local function spellid(self, unit, index, filter)
		if not EUIDB.tooltipShowSpellIds then return end
		local id
		if unit then
			local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
			id = aura and aura.spellId
		else
			id = select(2, self:GetSpell())
		end
		if id then
			self:AddLine(" ")
			self:AddLine("Spell ID: " .. id)
		end
		self:Show()
	end
	hooksecurefunc(GameTooltip, "SetUnitAura", spellid)
	hooksecurefunc(GameTooltip, "SetUnitBuff", spellid)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", spellid)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self)
		spellid(self)
	end)

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

		local bar = GameTooltipStatusBar
		if not bar.bg then
			bar.bg = bar:CreateTexture('GameTooltipStatusBarBackground', "BACKGROUND")
			bar.bg:SetAllPoints(bar)
			bar.bg:SetTexture(SQUARE_TEXTURE)
			bar.bg:SetVertexColor(0.2, 0.2, 0.2)
		end

		if not bar.TextString then
			bar.TextString = bar:CreateFontString('GameToolTipTextStatus', "OVERLAY")
			bar.TextString:SetPoint("CENTER")
			SetDefaultFont(bar.TextString, 11)
		end

		-- Gametooltip statusbar
		bar:SetStatusBarTexture(EUIDB.statusBarTex)
		bar:ClearAllPoints()
		bar:SetPoint("LEFT", 7, 0)
		bar:SetPoint("RIGHT", -7, 0)
		bar:SetPoint("BOTTOM", 0, 7)
		bar:SetHeight(10)
	end
  skinGameTooltip()

	local function cleanupTooltip(tip)
		local unit = GetTooltipUnit()
		local unitInfo = GetUnitInfo(unit)

		if not unitInfo.exists then return end

		local hideCreatureTypeIfNoCreatureFamily = (not unitInfo.isPlayer or unitInfo.isWildBattlePet) and
		not unitInfo.family and unitInfo.type
		local hideSpecializationAndClassText = unitInfo.isPlayer and
		LibFroznFunctions.hasWoWFlavor.specializationAndClassTextInPlayerUnitTip and unitInfo.className

		local specNames = LibFroznFunctions:CreatePushArray()

		if (hideSpecializationAndClassText) then
			local specCount = C_SpecializationInfo.GetNumSpecializationsForClassID(unitInfo.classID)

			for i = 1, specCount do
				local _, specName = GetSpecializationInfoForClassID(unitInfo.classID, i, unitInfo.sex)

				specNames:Push(specName)
			end
		end

		for i = 2, tip:NumLines() do
			local gttLine = _G["GameTooltipTextLeft" .. i]
			local gttLineText = gttLine:GetText()

			if (type(gttLineText) == "string") then
				local isGttLineTextUnitPopupRightClick = (gttLineText == UNIT_POPUP_RIGHT_CLICK)
				local isSpecLine = unitInfo.className and
				(specNames:Contains(gttLineText:match("^(.+) " .. unitInfo.className .. "$")))

				if isGttLineTextUnitPopupRightClick or
						(gttLineText == FACTION_ALLIANCE or gttLineText == FACTION_HORDE or gttLineText == FACTION_NEUTRAL) or
						(gttLineText == PVP_ENABLED) or
						(hideCreatureTypeIfNoCreatureFamily and gttLineText == unitInfo.type) or
						(hideSpecializationAndClassText and (gttLineText == unitInfo.className or isSpecLine)) then
					gttLine:SetText(nil)

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

	local guildColors = {
		name = CreateColorFromHexString('fff232e7'),
		rank = CreateColorFromHexString('ffbd8cf2'),
	}

	local function onTooltipSetUnit(self)
    if self ~= GameTooltip then return end

		local unit = GetTooltipUnit()
		local unitInfo = GetUnitInfo(unit)

    skinGameTooltip()
		cleanupTooltip(self)

		if not unitInfo.exists then return end

		local level = unitInfo.level
    if (level < 0) then
      level = "??"
    end

		local unitClassColor = GetUnitHealthColor(unit)

		if unitInfo.isPlayer then
			local race = unitInfo.race

      -- Class coloured name
			if (EUIDB.tooltipClassColoredName) then
				local text = GameTooltipTextLeft1:GetText()
				GameTooltipTextLeft1:SetText(unitClassColor:WrapTextInColorCode(text))
			end

      local playerInfoLine = GameTooltipTextLeft2
			local guildName, guildRank, _, realm = GetGuildInfo(unit)
			local playerGuildName, _, _, playerRealm = GetGuildInfo("player")
			local trimmedGuild = Trim(guildName)
			local trimmedRank = Trim(guildRank)
			if (guildName and guildName == playerGuildName and realm == playerRealm) then
        playerInfoLine = GameTooltipTextLeft3
				local guildLine = GameTooltipTextLeft2
				guildLine:SetText(guildColors.name:WrapTextInColorCode(trimmedGuild) .. guildColors.rank:WrapTextInColorCode(' (' .. trimmedRank .. ')'))
			elseif guildName then
				playerInfoLine = GameTooltipTextLeft3
				local guildLine = GameTooltipTextLeft2
				guildLine:SetText(trimmedGuild .. ' (' .. trimmedRank .. ')')
			end

      playerInfoLine:SetText(level .. ' ' .. race .. ' ' .. unitClassColor:WrapTextInColorCode(unitInfo.className))

			-- Mount
			if EUIDB.tooltipShowMount then
				addMount(unit)
			end

			if EUIDB.tooltipShowMythicPlus then
				addMythicPlusScore(unitInfo)
			end

			-- recalculate size of tip to ensure that it has the correct dimensions
			LibFroznFunctions:RecalculateSizeOfGameTooltip(self)
		end

		if unitInfo.family then -- Add pet family to assist hunters
			GameTooltipTextLeft2:SetText(level .. " " .. unitInfo.family)
		end

		if EUIDB.tooltipShowNpcID and unitInfo.npcID then
			self:AddLine(" ")
			self:AddLine("NPC ID: " .. unitInfo.npcID)
		end

    -- Add room for the health bar
		if not EUIDB.tooltipHideHealthBar then
			self:AddLine(' ')
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
		local unitClassColor = GetUnitHealthColor(unit)

		SetStatusBarColor(self, unitClassColor)

		local value = UnitHealth(unit)
		local maxValue = UnitHealthMax(unit)

    if value == 0 and maxValue == 0 then return end
    local percent = math.floor(value / maxValue * 100)

    local textString = self.TextString
		textString:SetText('(' .. percent .. '%) ' .. AbbreviateLargeNumbers(value) .. ' / ' .. AbbreviateLargeNumbers(maxValue))
	end)

	initTooltips = true
end

OnPlayerLogin(InitTooltips)
