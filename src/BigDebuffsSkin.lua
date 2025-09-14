OnPlayerLogin(function()
  if not C_AddOns.IsAddOnLoaded('BigDebuffs') then return end

  -- Nameplates
  hooksecurefunc(BigDebuffs, 'NAME_PLATE_UNIT_ADDED', function(self, _, unit)
    local namePlate = GetSafeNameplate(unit)
    if not namePlate then return end

    if namePlate:IsForbidden() then return end

    local bdbNameplate = namePlate.BigDebuffs

    if bdbNameplate then
      ApplyEuiBackdrop(bdbNameplate)
    end
  end)
end)
