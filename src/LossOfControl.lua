OnPlayerLogin(function()
   -- Hide red shadow
  select(2,LossOfControlFrame:GetRegions()):SetAlpha(0)
  select(3,LossOfControlFrame:GetRegions()):SetAlpha(0)

  -- Style the icon
  local icon = select(4,LossOfControlFrame:GetRegions())

  ApplyEuiBackdrop(icon, LossOfControlFrame)
end)
