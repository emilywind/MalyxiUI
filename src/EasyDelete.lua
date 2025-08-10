OnPlayerLogin(function()
  hooksecurefunc(
    StaticPopupDialogs["DELETE_GOOD_ITEM"],
    "OnShow",
    function(s)
      (s.EditBox or s.editBox):SetText(DELETE_ITEM_CONFIRM_STRING)
    end
  )
end)
