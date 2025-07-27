local function getUnitHealthColor(unit)
	local r, g, b

	if (UnitIsPlayer(unit)) then
		r, g, b = GetClassColor(select(2,UnitClass(unit)))
	else
		r, g, b = GameTooltip_UnitColor(unit)
		if (g == 0.6) then g = 0.9 end
		if (r==1 and g==1 and b==1) then r, g, b = 0, 0.9, 0.1 end
	end

	return r, g, b
end

local function skinGameTooltip()
  GameTooltip.NineSlice:SetBorderColor(getFrameColour())
  GameTooltip.NineSlice:SetCenterColor(0.08, 0.08, 0.08)
end

local colours = {
  guildName = 'f232e7',
  guildRank = 'bd8cf2',
}

OnPlayerLogin(function()
	if C_AddOns.IsAddOnLoaded('TinyTooltip') or C_AddOns.IsAddOnLoaded('TipTac') then
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
	setDefaultFont(bar.TextString, 11)

	-- Gametooltip statusbar
  bar:SetStatusBarTexture(EUIDB.healthBarTex)
	bar:ClearAllPoints()
	bar:SetPoint("LEFT", 7, 0)
	bar:SetPoint("RIGHT", -7, 0)
	bar:SetPoint("BOTTOM", 0, 7)
	bar:SetHeight(10)

  skinGameTooltip()

	-- Class colours
	local function onTooltipSetUnit(self)
    if self ~= GameTooltip then return end

    skinGameTooltip()

    local tooltip = GameTooltip
		local unit = select(2, tooltip:GetUnit())
		if not unit then return end

		local level = UnitEffectiveLevel(unit)
    if (level < 0) then
      level = "??"
    end

		local r, g, b = getUnitHealthColor(unit)

		if UnitIsPlayer(unit) then
			local race = UnitRace(unit)

      -- Class coloured name
			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text:match("|cff%x%x%x%x%x%x(.+)|r") or text)

      local playerInfoLine = GameTooltipTextLeft2
			local guildName, guildRank = GetGuildInfo(unit)
			if (guildName) then
        playerInfoLine = GameTooltipTextLeft3
				local guildLine = GameTooltipTextLeft2
				guildLine:SetText('|cff' .. colours.guildName .. guildName .. '|r' .. '|cff' .. colours.guildRank .. ' (' .. guildRank .. ')|r')
			end

      playerInfoLine:SetText('Level ' .. level .. ' ' .. race)
		end

		local family = UnitCreatureFamily(unit)
		if (family) then -- UnitIsBattlePetCompanion(unit);
			GameTooltipTextLeft2:SetText(level .. " " .. family)
		end

    -- Add room for the health bar
    GameTooltip:AddLine(' ')
	end

  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)

	GameTooltipStatusBar:HookScript("OnValueChanged", function(self, hp)
		local unit = select(2, GameTooltip:GetUnit())
    if not unit then
      unit = "mouseover"
	    local focus = GetMouseFoci()
	    if (focus and focus.unit) then
        unit = focus.unit
	    end
    end

	  self:SetStatusBarColor(getUnitHealthColor(unit))

		local value = UnitHealth(unit)
		local maxValue = UnitHealthMax(unit)

    if value == 0 and maxValue == 0 then return end
    local percent = math.floor(value / maxValue * 100)

    local textString = self.TextString
		textString:SetText('(' .. percent .. '%) ' .. AbbreviateLargeNumbers(value) .. ' / ' .. AbbreviateLargeNumbers(maxValue))
	end)
end)
