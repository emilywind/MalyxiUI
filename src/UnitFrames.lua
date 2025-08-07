OnPlayerLogin(function()
	-------------------------
	-- Hide Alt Power bars --
	-------------------------
	if (EUIDB.hideAltPower) then
		local altPowerBars = {
			PaladinPowerBarFrame,
			PlayerFrameAlternateManaBar,
			MageArcaneChargesFrame,
			MonkHarmonyBarFrame,
			MonkStaggerBar,
			RuneFrame,
			ComboPointPlayerFrame,
			WarlockPowerFrame,
			TotemFrame,
      EssencePlayerFrame,
		}

		for _, altPowerBar in pairs(altPowerBars) do
			altPowerBar:SetAlpha(0)
			RegisterStateDriver(altPowerBar, "visibility", "hide")
		end
	end

  -------------------
  -- Class Colours --
  -------------------
  TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
  FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()

  local function setUnitColour(healthbar)
    local unit = healthbar.unit
    healthbar:SetStatusBarDesaturated(1)
    if UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitClass(unit) then
      local _, class = UnitClass(unit)
      local color = RAID_CLASS_COLORS[class]
      healthbar:SetStatusBarColor(color.r, color.g, color.b)
    elseif UnitIsPlayer(unit) and (not UnitIsConnected(unit)) then
      healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
    else
      if UnitExists(unit) then
        if (UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
          healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
        elseif (not UnitIsTapDenied(unit)) then
          local reaction = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
          if reaction then
            healthbar:SetStatusBarColor(reaction.r, reaction.g, reaction.b)
          end
        end
      end
    end
  end

  hooksecurefunc("UnitFrameHealthBar_Update", setUnitColour)
  hooksecurefunc("HealthBar_OnValueChanged", setUnitColour)

  hooksecurefunc(TargetFrame, "OnEvent", function(self)
    -- Style Buffs & Debuffs
    for aura, _ in self.auraPools:EnumerateActive() do
      ApplyAuraSkin(aura)
    end
  end)

  hooksecurefunc(FocusFrame, "OnEvent", function(self)
    -- Style Buffs & Debuffs
    for aura, _ in self.auraPools:EnumerateActive() do
      ApplyAuraSkin(aura)
    end
  end)

  hooksecurefunc("PlayerFrame_UpdateStatus", function(self)
    if IsResting() then
      PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Hide()
    end
  end)

  -----------------
  -- Boss Frames --
  -----------------
  local function skinBossFrames(self)
    if not self then return end

    if self.healthbar then
      self.healthbar:SetStatusBarTexture(EUIDB.healthBarTex)
    end

    if self.TargetFrameContent.TargetFrameContentMain.ReputationColor then
      self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(GetFrameColour())
    end
  end

  for i = 1, 5 do
    _G['Boss'..i..'TargetFrame']:HookScript('OnEvent', skinBossFrames)
  end
end)
