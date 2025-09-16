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
      for _, nameplate in pairs(GetAllNameplates()) do
        SkinCastbar(nameplate)
      end
    end)
  end
end)
interruptSpellUpdate:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

function SkinCastbar(frame)
  local castBar = frame.castBar
  if not castBar then return end
  if castBar:IsForbidden() then return end

  local unitToken = frame.displayedUnit or frame.unit

  ApplyEuiBackdrop(castBar.Icon, castBar)
  local timer = castBar.timer
  if not timer then
    timer = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timer:SetPoint("LEFT", castBar, "RIGHT", 2, 0)
    castBar.timer = timer
  end
  ModifyFont(castBar.Text, EUIDB.nameplateFont)
  ModifyFont(timer, EUIDB.nameplateFont, 11, "THINOUTLINE", 'ffffffff')

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

  if not EUIDB.nameplateCastbarColorInterrupt or (not spellName and not spellID) then return end

  if not UnitIsEnemy("player", unitToken) then return end

  local knownInterruptSpellID = GetInterruptSpell()
  if not knownInterruptSpellID or notInterruptible then return end

  local start, duration = TWWGetSpellCooldown(knownInterruptSpellID)
  local cooldownRemaining = start + duration - GetTime()
  local castRemaining = (endTime / 1000) - GetTime()
  local totalCastTime = (endTime / 1000) - (castStart / 1000)

  local castSpark = castBar.spark
  if not castSpark then
    castSpark = castBar:CreateTexture(nil, "OVERLAY")
    castSpark:SetColorTexture(0, 1, 0, 1)
    castSpark:SetSize(2, castBar:GetHeight())
    castBar.spark = castSpark
  end
  if castSpark and castSpark:IsShown() then
    castSpark:Hide()
  end

  if cooldownRemaining > 0 and cooldownRemaining > castRemaining then
    castBarTexture:SetDesaturated(true)
    castBar:SetStatusBarColor(unpack(CASTBAR_NO_INTERRUPT_COLOR))
  elseif cooldownRemaining > 0 and cooldownRemaining <= castRemaining then
    castBarTexture:SetDesaturated(true)
    castBar:SetStatusBarColor(unpack(CASTBAR_DELAYED_INTERRUPT_COLOR))

    if cooldownRemaining < castRemaining then
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

      castSpark:SetPoint("CENTER", castBar, "LEFT", sparkPosition, 0)
      castSpark:Show()

      -- Schedule the color update for when the interrupt will be ready
      C_Timer.After(cooldownRemaining, function()
        if castBar then
          castBarTexture:SetDesaturated(false)
          castBar:SetStatusBarColor(1, 1, 1)
          castSpark:Hide()
        end
      end)
    else
      castSpark:Hide()
    end
  else
    castBarTexture:SetDesaturated(false)
    castBar:SetStatusBarColor(1, 1, 1)
    castSpark:Hide()
  end
end

function TWWGetSpellCooldown(spellID)
  local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
  if spellCooldownInfo then
    return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled,
      spellCooldownInfo.modRate
  end
end

local function updateCastTimer(frame, castBar, unit)
  local name, _, _, startTime, endTime = UnitCastingInfo(unit)
  if not name then
    name, _, _, startTime, endTime = UnitChannelInfo(unit)
  end

  if name and endTime and startTime and frame then
    local timer = castBar.timer
    timer.endTime = endTime / 1000
    local timeLeft = timer.endTime - GetTime()
    if timeLeft > 0 then
      castBar.timer:SetText(format("%.1f", max(timeLeft, 0)))
      C_Timer.After(0.1, function()
        updateCastTimer(frame, castBar, unit)
      end)
    else
      castBar.timer:SetText("")
    end
  else
    castBar.timer:SetText("")
  end
end

local function UpdateNameplateTargetText(frame, unit)
  local targetText = frame.TargetText
  if not targetText then
    targetText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    targetText:SetJustifyH("CENTER")
    targetText:SetParent(frame.castBar)
    targetText:SetIgnoreParentScale(true)
    frame.TargetText = targetText
    -- fix me (make it appear above resource when higher strata resource) bodify
  end
  ModifyFont(targetText, EUIDB.nameplateFont)

  local isCasting = UnitCastingInfo(unit) or UnitChannelInfo(unit)

  frame.TargetText:SetText("")

  if isCasting and UnitExists(unit.."target") and frame.castBar:IsShown() and not frame.hideCastInfo then
    local targetOfTarget = unit.."target"
    local name = UnitName(targetOfTarget)
    local classColor = GetUnitHealthColor(targetOfTarget)

    frame.TargetText:SetText(name)
    frame.TargetText:SetTextColor(classColor.r, classColor.g, classColor.b)
    frame.TargetText:ClearAllPoints()
    if UnitCanAttack("player", unit) then
      frame.TargetText:SetPoint("TOPRIGHT", frame.castBar, "BOTTOMRIGHT", -4, 0)  -- Set anchor point for enemy
    else
      frame.TargetText:SetPoint("TOP", frame.castBar, "BOTTOM", 0, 0)  -- Set anchor point for friendly
    end
  else
    frame.TargetText:SetText("")
  end
end

hooksecurefunc(CastingBarMixin, "OnEvent", function(self)
  local unit = self.unit
  if not unit or not unit:find("nameplate") then return end
  local info = GetUnitInfo(unit)
  if not info.exists then return end

  local frame = GetSafeNameplate(unit)
  if not frame then return end
  if unit == "player" then return end

  local castBar = frame.castBar

  if frame.hideCastbarOverride or (EUIDB.nameplateHideFriendlyCastbars and info.isFriend) then
    castBar:Hide()
    return
  end

  if EUIDB.nameplateHideCastText then
    castBar.Text:Hide()
  elseif not castBar.Text:IsShown() then
    castBar.Text:Show()
  end

  if castBar.timer then
    updateCastTimer(frame, castBar, unit)
  end

  if EUIDB.nameplateShowTargetText then
    UpdateNameplateTargetText(frame, unit)
  end

  if EUIDB.nameplateCastbarColorInterrupt then
    SkinCastbar(frame)
  end
end)

OnEvent("UNIT_TARGET", function(_, _, unit)
  local np = GetSafeNameplate(unit)
  if np then SkinCastbar(np) end
end)
