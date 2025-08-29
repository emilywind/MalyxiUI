local interruptSpells = {
  1766,     -- Kick (Rogue)
  2139,     -- Counterspell (Mage)
  6552,     -- Pummel (Warrior)
  19647,    -- Spell Lock (Warlock)
  47528,    -- Mind Freeze (Death Knight)
  57994,    -- Wind Shear (Shaman)
  --91802, -- Shambling Rush (Death Knight)
  96231,    -- Rebuke (Paladin)
  106839,   -- Skull Bash (Feral)
  115781,   -- Optical Blast (Warlock)
  116705,   -- Spear Hand Strike (Monk)
  132409,   -- Spell Lock (Warlock)
  119910,   -- Spell Lock (Warlock Pet)
  89766,    -- Axe Toss (Warlock Pet)
  171138,   -- Shadow Lock (Warlock)
  147362,   -- Countershot (Hunter)
  183752,   -- Disrupt (Demon Hunter)
  187707,   -- Muzzle (Hunter)
  212619,   -- Call Felhunter (Warlock)
  --231665,-- Avengers Shield (Paladin)
  351338,   -- Quell (Evoker)
  97547,    -- Solar Beam
  78675,    -- Solar Beam
  15487,    -- Silence
  --47482, -- Leap (DK Transform)
}

local petSummonSpells = {
  [30146]  = true,   -- Summon Demonic Tyrant (Demonology)
  [691]    = true,   -- Summon Felhunter (for Spell Lock)
  [108503] = true,   -- Grimoire of Sacrifice
}

local isSpellKnown = function(spellID, isPet)
  return C_SpellBook.IsSpellInSpellBook(spellID, isPet and 1 or 0, true)
end

local function GetInterruptSpell()
  for _, spellID in ipairs(interruptSpells) do
    if isSpellKnown(spellID, false) or (UnitExists("pet") and isSpellKnown(spellID, true)) then
      petSummonSpells[spellID] = true
      return spellID
    elseif petSummonSpells[spellID] then
      petSummonSpells[spellID] = nil
    end
  end

  return nil
end

local interruptSpellUpdate = OnEvents({
  "TRAIT_CONFIG_UPDATED",
  "PLAYER_TALENT_UPDATE"
}, function(_, event, _, _, spellID)
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if not petSummonSpells[spellID] then return end
  end
  if EUIDB.skinNameplates and EUIDB.nameplateCastbarColorInterrupt then
    C_Timer.After(0.1, function()
      GetInterruptSpell()
      for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
        local frame = namePlate.UnitFrame
        SkinCastbar(frame, frame.unit)
      end
    end)
  end
end)
interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

function SkinCastbar(frame, unitToken)
  local castBar = frame.castBar
  if not castBar then return end
  if castBar:IsForbidden() then return end

  if EUIDB.nameplateHideCastText then
    castBar.Text:Hide()
  end

  if not castBar.euiClean then
    ModifyFont(castBar.Text, EUIDB.nameplateFont, EUIDB.nameplateNameFontSize - 1)
    ApplyEuiBackdrop(castBar.Icon, castBar)
    castBar.euiClean = true
  end

  local castBarTexture = castBar:GetStatusBarTexture()
  local spellName, spellID, notInterruptible, endTime, channeling, castStart, empoweredCast

  if UnitCastingInfo(unitToken) then
    spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unitToken)
  elseif UnitChannelInfo(unitToken) then
    spellName, _, _, castStart, endTime, _, notInterruptible, spellID, empoweredCast = UnitChannelInfo(unitToken)
    if empoweredCast then
      channeling = false
    else
      channeling = true
    end
  end

  if EUIDB.nameplateCastbarColorInterrupt then
    if spellName or spellID then
      local isEnemy = GetUnitCharacteristics(unitToken)
      if not isEnemy then return end

      local knownInterruptSpellID = GetInterruptSpell()
      if not knownInterruptSpellID or notInterruptible then return end

      local start, duration = TWWGetSpellCooldown(knownInterruptSpellID)
      local cooldownRemaining = start + duration - GetTime()
      local castRemaining = (endTime / 1000) - GetTime()
      local totalCastTime = (endTime / 1000) - (castStart / 1000)

      if castBar.spark and castBar.spark:IsShown() then
        castBar.spark:Hide()
      end

      if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
        if castBarTexture then
          castBarTexture:SetDesaturated(true)
        end
        castBar:SetStatusBarColor(unpack(CASTBAR_NO_INTERRUPT_COLOR))
      elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
        if castBarTexture then
          castBarTexture:SetDesaturated(true)
        end
        castBar:SetStatusBarColor(unpack(CASTBAR_DELAYED_INTERRUPT_COLOR))

        if cooldownRemaining < castRemaining then
          if not castBar.spark then
            castBar.spark = castBar:CreateTexture(nil, "OVERLAY")
            castBar.spark:SetColorTexture(0, 1, 0, 1) -- Solid green color with full opacity
            castBar.spark:SetSize(2, castBar:GetHeight())
          end

          local interruptPercent = (totalCastTime - castRemaining + cooldownRemaining) / totalCastTime

          -- Adjust the spark position based on the percentage, reverse if channeling
          local sparkPosition
          if channeling then
            -- Channeling: reverse the direction, starting from the right
            sparkPosition = (1 - interruptPercent) * castBar:GetWidth()
          else
            -- Casting: normal direction, from left to right
            sparkPosition = interruptPercent * castBar:GetWidth()
            if empoweredCast then
                sparkPosition = sparkPosition * 0.7 -- ? idk why but on empowered casts it needs to be roughly 30% to the left compared to cast/channel
            end
          end

          castBar.spark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, 0)
          castBar.spark:Show()

          -- Schedule the color update for when the interrupt will be ready
          C_Timer.After(cooldownRemaining, function()
            if castBar then
              if castBarTexture then
                castBarTexture:SetDesaturated(false)
              end
              castBar:SetStatusBarColor(1, 1, 1)
              if castBar.spark then
                castBar.spark:Hide()
              end
            end
          end)
        else
          if castBar.spark then
            castBar.spark:Hide()
          end
        end
      else
        if castBarTexture then
          castBarTexture:SetDesaturated(false)
        end
        castBar:SetStatusBarColor(1, 1, 1)
        if castBar.spark then
          castBar.spark:Hide()
        end
      end
    end
  end
end

function TWWGetSpellCooldown(spellID)
  local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
  if spellCooldownInfo then
    return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled,
      spellCooldownInfo.modRate
  end
end

function GetSafeNameplate(unit)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  -- If there's no nameplate or the nameplate doesn't have a UnitFrame, return nils.
  if not nameplate or not nameplate.UnitFrame then return nil, nil end

  local frame = nameplate.UnitFrame
  -- If none of the above conditions are met, return both the nameplate and the frame.
  return nameplate, frame
end

hooksecurefunc(CastingBarMixin, "OnEvent", function(self, event, ...)
  if not self.unit or not self.unit:find("nameplate") then return end

  local frame = select(2, GetSafeNameplate(self.unit))
  if not frame then return end
  if self.unit == "player" then return end

  if frame.hideCastbarOverride then
    frame.castBar:Hide()
    return
  end

  -- if showNameplateCastbarTimer then
  --   BBP.UpdateCastTimer(frame, self.unit)
  -- end

  -- if showNameplateTargetText then
  --   BBP.UpdateNameplateTargetText(frame, self.unit)
  -- end

  if EUIDB.nameplateCastbarColorInterrupt then
    SkinCastbar(frame, self.unit)

    if not UnitTargetCastbarUpdate then
      UnitTargetCastbarUpdate = OnEvent("UNIT_TARGET", function(_, _, unit)
        local npFrame = select(2, GetSafeNameplate(unit))
        if npFrame and not UnitIsPlayer(unit) then
          SkinCastbar(npFrame, unit)
        end
      end)
    end
  end
end)
