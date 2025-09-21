local SetCVar = C_CVar.SetCVar

OnEvent("PLAYER_ENTERING_WORLD", function()
    local instanceInfo = GetInstanceData()

    if instanceInfo.isInPvE and EUIDB.nameplateShowFriends and EUIDB.nameplateHideFriendsPve then
      SetCVar("nameplateShowFriends", 0)
    elseif EUIDB.nameplateShowFriends then
      SetCVar("nameplateShowFriends", 1)
    end
  end)
