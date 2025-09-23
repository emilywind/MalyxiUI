-- Combat Indicator
function CombatIndicator(frame)
  local info = GetNameplateUnitInfo(frame)

  local combatIndicator = frame.combatIndicator
  if not combatIndicator then
    combatIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
    frame.combatIndicator = combatIndicator
  end

  if EUIDB.nameplateCombatIndicator == 'food' then
    combatIndicator:SetSize(14, 14)
    combatIndicator:SetAtlas("food")
  elseif EUIDB.nameplateCombatIndicator == 'sap' then
    combatIndicator:SetSize(12, 12)
    combatIndicator:SetTexture("Interface\\Icons\\Ability_Sap")
    StyleIcon(combatIndicator)
  end

  local shouldShow = EUIDB.skinNameplates and EUIDB.nameplateCombatIndicator ~= 'none' and not info.inCombat and info.canAttack and info.isPlayer

  local yPosAdjustment = EUIDB.nameplateCombatIndicator == 'sap' and 0 or 1
  combatIndicator:SetPoint("LEFT", frame.healthBar, "LEFT", 2, yPosAdjustment)

  if shouldShow then
    combatIndicator:Show()
    return
  end

  if combatIndicator then
    combatIndicator:Hide()
  end
end

OnEvent("UNIT_FLAGS", function(_, _, unit)
  local frame = GetSafeNameplate(unit)
  if frame then CombatIndicator(frame) end
end)
