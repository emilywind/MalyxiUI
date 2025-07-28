function HideArenaFrames()
  if InCombatLockdown() then return end

  if not EUIDB.hideArenaFrames then
    CompactArenaFrame:SetAlpha(1)
    RegisterStateDriver(CompactArenaFrame, 'visibility', 'show')
  else
    CompactArenaFrame:SetAlpha(0)
    RegisterStateDriver(CompactArenaFrame, 'visibility', 'hide')
  end
end

OnPlayerLogin(function()
  if not CompactArenaFrame then return end

  hooksecurefunc(CompactArenaFrame, "UpdateVisibility", HideArenaFrames)
end)
