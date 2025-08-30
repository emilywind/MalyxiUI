OnPlayerLogin(function()
  -------------------
  -- Class Colours --
  -------------------
  TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
  FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()

  local function setUnitColour(healthbar)
    local unit = healthbar.unit
    if not unit then return end
    local unitInfo = GetUnitInfo(unit)
    local isConnected = UnitIsConnected(unit)

    healthbar:SetStatusBarDesaturated(1)
    local healthColor = GetUnitHealthColor(unit)
    if isConnected then
      healthbar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b)
    elseif unitInfo.isPlayer and not isConnected then
      healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
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
      DarkenTexture(self.TargetFrameContent.TargetFrameContentMain.ReputationColor, self.unit)
    end
  end

  for i = 1, 5 do
    _G['Boss'..i..'TargetFrame']:HookScript('OnEvent', skinBossFrames)
  end
end)
