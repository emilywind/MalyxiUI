OnPlayerLogin(function()
  if not C_AddOns.IsAddOnLoaded('BigDebuffs') then return end

  hooksecurefunc(BigDebuffs, 'NAME_PLATE_UNIT_ADDED', function(_, _, unit)
    local nameplate = GetSafeNameplate(unit)
    if not nameplate or nameplate:IsForbidden() then return end

    ApplyEuiBackdrop(nameplate.BigDebuffs)
  end)
end)
