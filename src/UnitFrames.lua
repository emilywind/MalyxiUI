OnPlayerLogin(function()
  -------------------
  -- Class Colours --
  -------------------
  TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
  FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()

  local function setUnitColour(healthbar)
    local unit = healthbar.unit
    local _, _, _, isPlayer, reaction = GetUnitCharacteristics(unit)
    local isConnected = UnitIsConnected(unit)

    healthbar:SetStatusBarDesaturated(1)
    if isPlayer and isConnected and UnitClass(unit) then
      local color = GetUnitClassColor(unit)
      healthbar:SetStatusBarColor(color.r, color.g, color.b)
    elseif isPlayer and not isConnected then
      healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
    else
      if UnitExists(unit) then
        local unitIsTapDenied = UnitIsTapDenied(unit)
        if unitIsTapDenied and not UnitPlayerControlled(unit) then
          healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
        elseif not unitIsTapDenied then
          local reactionColor = FACTION_BAR_COLORS[reaction]
          if reactionColor then
            healthbar:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)
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
      DarkenTexture(self.TargetFrameContent.TargetFrameContentMain.ReputationColor)
    end
  end

  for i = 1, 5 do
    _G['Boss'..i..'TargetFrame']:HookScript('OnEvent', skinBossFrames)
  end
end)
