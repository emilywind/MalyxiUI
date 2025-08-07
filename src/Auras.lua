----------------------------------
-- Buffs/Debuffs on Unit Frames --
----------------------------------
function ApplyAuraSkin(aura)
  if aura.border and aura.Border then
    aura.Border:SetAlpha(1)
    SetEuiBorderColor(aura.border, aura.Border:GetVertexColor())
    aura.Border:SetAlpha(0)
  end

  if aura.euiClean then return end

  --icon
  local icon = aura.Icon
  StyleIcon(icon)

  --border
  local border = ApplyEuiBackdrop(icon, aura)
  aura.border = border

  if aura.Border then
    SetEuiBorderColor(border, aura.Border:GetVertexColor())
    aura.Border:SetAlpha(0)
  else
    SetEuiBorderColor(border, 0, 0, 0)
  end

  aura.euiClean = true
end
