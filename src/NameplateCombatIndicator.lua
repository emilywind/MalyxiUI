-- Combat Indicator
local function CombatIndicator(frame)
  local unit = frame.displayedUnit
  local info = GetUnitInfo(unit)

  -- Create food texture
  if not frame.combatIndicator then
    frame.combatIndicator = frame:CreateTexture(nil, "OVERLAY")
    if EUIDB.combatIndicator == 'food' then
      frame.combatIndicator:SetSize(18, 18)
      frame.combatIndicator:SetAtlas("food")
    elseif EUIDB.combatIndicator == 'sap' then
      frame.combatIndicator:SetSize(18, 16)
      frame.combatIndicator:SetTexture("Interface\\AddOns\\BetterBlizzPlates\\media\\ABILITY_SAP")
    end
  end

  -- Conditon check: Only show on enemy players
  local shouldShow = not info.inCombat and info.isEnemy and info.isPlayer

  -- frame.combatIndicator:SetScale(config.combatIndicatorScale)

  -- Add some offset if both Pet Indicator and Combat Indicator has the same anchor and shows at the same time
  local petOffset = 0
  if frame.petIndicator and frame.petIndicator:IsShown() then
    petOffset = 5
  end

  -- Tiny adjustment to position depending on texture
  local yPosAdjustment = EUIDB.combatIndicator == 'sap' and 0 or 1
  frame.combatIndicator:SetPoint("CENTER", frame.healthBar, "CENTER", petOffset, yPosAdjustment)

  -- Target is not in combat so return
  if shouldShow then
    return
  end

  -- Target is in combat so hide texture
  if frame.combatIndicator then
    frame.combatIndicator:Hide()
  end
end

-- Event Listener for Combat Indicator
OnEvent("UNIT_FLAGS", function(self, event, unit)
  if EUIDB.combatIndicator == 'none' then
    self:UnregisterEvent("UNIT_FLAGS")
    return
  end

  local frame = select(2, GetSafeNameplate(unit))
  if frame then CombatIndicator(frame) end
end)
