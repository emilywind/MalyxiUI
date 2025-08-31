-- Combat Indicator
function CombatIndicator(frame)
  local unit = frame.displayedUnit
  local info = GetUnitInfo(unit)

  -- Create food texture
  if not frame.combatIndicator then
    frame.combatIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
    if EUIDB.nameplateCombatIndicator == 'food' then
      frame.combatIndicator:SetSize(14, 14)
      frame.combatIndicator:SetAtlas("food")
    elseif EUIDB.nameplateCombatIndicator == 'sap' then
      frame.combatIndicator:SetSize(12, 12)
      frame.combatIndicator:SetTexture("Interface\\Icons\\Ability_Sap")
      StyleIcon(frame.combatIndicator)
    end
  end

  -- Conditon check: Only show on enemy players
  local shouldShow = not info.inCombat and info.isEnemy

  -- Add some offset if both Pet Indicator and Combat Indicator has the same anchor and shows at the same time
  local petOffset = 2
  if frame.petIndicator and frame.petIndicator:IsShown() then
    petOffset = petOffset + 5
  end

  -- Tiny adjustment to position depending on texture
  local yPosAdjustment = EUIDB.nameplateCombatIndicator == 'sap' and 0 or 1
  frame.combatIndicator:SetPoint("LEFT", frame.healthBar, "LEFT", petOffset, yPosAdjustment)

  -- Target is not in combat so return
  if shouldShow then
    frame.combatIndicator:Show()
    return
  end

  -- Target is in combat so hide texture
  if frame.combatIndicator then
    frame.combatIndicator:Hide()
  end
end

-- Event Listener for Combat Indicator
OnEvent("UNIT_FLAGS", function(self, event, unit)
  if EUIDB.nameplateCombatIndicator == 'none' then
    self:UnregisterEvent("UNIT_FLAGS")
    return
  end

  local frame = select(2, GetSafeNameplate(unit))
  if frame then CombatIndicator(frame) end
end)
