local function applySkin(aura)
  local duration = aura.Duration
  if duration then
    local point, relativeTo, relativePoint, xOfs = duration:GetPoint()
    local yOfs = point == "TOP" and -3 or 3
    duration:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
  end

  if aura.TempEnchantBorder then aura.TempEnchantBorder:Hide() end

  local icon = aura.Icon
  StyleIcon(icon)

  local border = ApplyEuiBackdrop(icon, aura)

  aura.border = border

  local debuffBorder = aura.DebuffBorder
  debuffBorder:SetAlpha(1)
  local debuffColor = CreateColor(debuffBorder:GetVertexColor())
  debuffBorder:SetAlpha(0)

  local isBuff = debuffColor.r == 1 and debuffColor.g == 1 and debuffColor.b == 1

  if isBuff then
    SetEuiBorderColor(border, 0, 0, 0)
  else
    SetEuiBorderColor(border, debuffColor.r, debuffColor.g, debuffColor.b)
  end
end

local function updateAuras(self)
  for _, aura in pairs(self.auraFrames) do
    if not aura.Icon.SetTexCoord then return end

    applySkin(aura)
  end
end

hooksecurefunc(BuffFrame, "UpdateAuraButtons", updateAuras)
hooksecurefunc(DebuffFrame, "UpdateAuraButtons", updateAuras)
