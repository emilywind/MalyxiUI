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

local knownInterruptSpellID = nil

local petSummonSpells = {
  [30146]  = true,   -- Summon Demonic Tyrant (Demonology)
  [691]    = true,   -- Summon Felhunter (for Spell Lock)
  [108503] = true,   -- Grimoire of Sacrifice
}

local function GetInterruptSpell()
  for _, spellID in ipairs(interruptSpells) do
    if C_SpellBook.IsSpellKnown(spellID) or (UnitExists("pet") and C_SpellBook.IsSpellKnown(spellID, true)) then
      knownInterruptSpellID = spellID
      petSummonSpells[spellID] = true
      return spellID
    elseif petSummonSpells[spellID] then
      petSummonSpells[spellID] = nil
    end
  end
  knownInterruptSpellID = nil
end

local function OnEvent(self, event, unit, _, spellID)
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
end

local interruptSpellUpdate = CreateFrame("Frame")
interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
interruptSpellUpdate:RegisterEvent("TRAIT_CONFIG_UPDATED")
interruptSpellUpdate:RegisterEvent("PLAYER_TALENT_UPDATE")
interruptSpellUpdate:SetScript("OnEvent", OnEvent)

function SkinCastbar(frame, unitToken)
  local castBar = frame.castBar
  if not castBar then return end
  if castBar:IsForbidden() then return end

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
      local isFriend = select(2, GetUnitCharacteristics(unitToken))
      if isFriend then return end

      if not knownInterruptSpellID then
        GetInterruptSpell()
      end
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
