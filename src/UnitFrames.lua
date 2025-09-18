-------------------------------
-- Class Colored Health Bars --
-------------------------------
---@param healthbar StatusBar
local function setUnitColor(healthbar)
  local unit = healthbar.unit
  if not unit then return end
  local unitInfo = GetUnitInfo(unit)

  healthbar:SetStatusBarDesaturated(1)
  local healthColor = GetUnitHealthColor(unit)

  if unitInfo.isPlayer and not unitInfo.isConnected then
    healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
  else
    healthbar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b)
  end
end

------------------------------------------
-- Buffs/Debuffs on Target/Focus Frames --
------------------------------------------
---@param aura Button
local function applyAuraSkin(aura)
  local icon = aura.Icon
  StyleIcon(icon)

  local border = ApplyEuiBackdrop(icon, aura)

  if aura.Border then
    aura.Border:SetAlpha(1)
    SetEuiBorderColor(border, GetVertexColor(aura.Border))
    aura.Border:SetAlpha(0)
  else
    SetEuiBorderColor(border)
  end
end

OnPlayerLogin(function()
  TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
  FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()

  hooksecurefunc("UnitFrameHealthBar_Update", setUnitColor)
  hooksecurefunc("HealthBar_OnValueChanged", setUnitColor)

  hooksecurefunc(TargetFrame, "OnEvent", function(self)
    for aura, _ in self.auraPools:EnumerateActive() do
      applyAuraSkin(aura)
    end
  end)

  hooksecurefunc(FocusFrame, "OnEvent", function(self)
    for aura, _ in self.auraPools:EnumerateActive() do
      applyAuraSkin(aura)
    end
  end)

  hooksecurefunc("PlayerFrame_UpdateStatus", function()
    if IsResting() then
      PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Hide()
    end
  end)
end)
