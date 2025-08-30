function HideArenaFrames()
  if InCombatLockdown() then return end

  local instanceData = GetInstanceData()

  if EUIDB.hideArenaFrames and instanceData.isInArena then
    CompactArenaFrame:SetAlpha(0)
    RegisterStateDriver(CompactArenaFrame, 'visibility', 'hide')
  elseif not EUIDB.hideArenaFrames and instanceData.isInArena then
    local alpha = CompactArenaFrame:GetAlpha()
    if alpha == 0 then
      CompactArenaFrame:SetAlpha(1)
      RegisterStateDriver(CompactArenaFrame, 'visibility', 'auto')
    end
  else
    CompactArenaFrame:SetAlpha(1)
  end
end

OnPlayerLogin(function()
  if not CompactArenaFrame then return end

  hooksecurefunc(CompactArenaFrame, "UpdateVisibility", HideArenaFrames)
end)
