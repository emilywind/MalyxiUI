local interruptSpellsByClass = {
  -- [classID] = {spellID, ...}
  [1] = { 6552 },    -- Pummel (Warrior)
  [2] = {            -- Paladin
    96231,           -- Rebuke
    231665,          -- Avenger's Shield
  },
  [3] = {            -- Hunter
    187707,          -- Muzzle
    147362,          -- Countershot
  },
  [4] = { 1766 },    -- Kick (Rogue)
  [6] = {            -- Death Knight
    47528,           -- Mind Freeze
    15487,           -- Silence
    47482,           -- Leap
    91802,           -- Shambling Rush
  },
  [7] = { 57994 },   -- Wind Shear (Shaman)
  [8] = { 2139 },    -- Counterspell (Mage)
  [9] = {            -- Warlock
    19647,           -- Spell Lock
    132409,          -- Spell Lock (Grimoire of Sacrifice)
    119910,          -- Spell lock (pet)
    115781,          -- Optical Blast
    89766,           -- Axe Toss
    119914,          -- Axe Toss (pet)
    212619,          -- Call Felhunter
    171138,          -- Shadow Lock
  },
  [10] = { 116705 }, -- Spear Hand Strike (Monk)
  [11] = {           -- Druid
    97547,           -- Solar Beam
    78675,           -- Solar Beam
    106839,          -- Skull Bash
  },
  [12] = { 183752 }, -- Disrupt (Demon Hunter)
  [13] = { 351338 }, -- Evoker (Quell)
}

local isSpellKnown = function(spellID, isPet)
  return C_SpellBook.IsSpellInSpellBook(spellID, isPet and 1 or 0, true)
end

local function GetKnownInterruptSpells()
  local classID = select(3, UnitClass("player"))
  local interruptSpells = interruptSpellsByClass[classID]
  local knownInterruptSpells = {}

  if interruptSpells then
    for _, spellID in ipairs(interruptSpells) do
      if isSpellKnown(spellID, false) or (UnitExists("pet") and isSpellKnown(spellID, true)) then
        table.insert(knownInterruptSpells, spellID)
      end
    end
  end

  return knownInterruptSpells
end

local function colorCastbarByInterrupt(castBar, unit)
  local spellName, spellID, notInterruptible, endTime, channeling, castStart, empoweredCast

  if UnitCastingInfo(unit) then
    spellName, _, _, castStart, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
  elseif UnitChannelInfo(unit) then
    spellName, _, _, castStart, endTime, _, notInterruptible, spellID, empoweredCast = UnitChannelInfo(unit)
    if empoweredCast then
      channeling = false
    else
      channeling = true
    end
  end

  if notInterruptible or (not spellName and not spellID) then return end

  if not UnitIsEnemy("player", unit) then return end

  local knownInterruptSpellIDs = GetKnownInterruptSpells()

  local cooldownRemaining = nil
  for _, interruptSpellID in ipairs(knownInterruptSpellIDs) do
    local start, duration = TWWGetSpellCooldown(interruptSpellID)
    local cooldown = start + duration - GetTime()

    if not cooldownRemaining then
      cooldownRemaining = cooldown
    elseif cooldown < cooldownRemaining then
      cooldownRemaining = cooldown
    end
  end
  if not cooldownRemaining then return end

  local castRemaining = (endTime / 1000) - GetTime()
  local totalCastTime = (endTime / 1000) - (castStart / 1000)

  local castSpark = castBar.spark
  if not castSpark then
    castSpark = castBar:CreateTexture(nil, "OVERLAY")
    castSpark:SetColorTexture(0, 1, 0, 1)
    castSpark:SetSize(2, castBar:GetHeight())
    castBar.spark = castSpark
  end

  if castSpark:IsShown() then
    castSpark:Hide()
  end

  local castBarTexture = castBar:GetStatusBarTexture()

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
          sparkPosition = sparkPosition *
          0.7                                 -- ? idk why but on empowered casts it needs to be roughly 30% to the left compared to cast/channel
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

local function skinCastbar(frame)
  local castBar = frame.castBar
  if not castBar then return end
  if castBar:IsForbidden() then return end

  local unit = frame.displayedUnit or frame.unit

  ApplyEuiBackdrop(castBar.Icon, castBar)
  local timer = castBar.timer
  if not timer then
    timer = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timer:SetPoint("LEFT", castBar, "RIGHT", 2, 0)
    castBar.timer = timer
  end
  ModifyFont(castBar.Text, EUIDB.nameplateFont)
  ModifyFont(timer, EUIDB.nameplateFont, 11, "THINOUTLINE", 'ffffffff')

  if EUIDB.nameplateCastbarColorInterrupt then
    colorCastbarByInterrupt(castBar, unit)
  end
end

function TWWGetSpellCooldown(spellID)
  local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
  if spellCooldownInfo then
    return spellCooldownInfo.startTime, spellCooldownInfo.duration
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

  if not EUIDB.nameplateShowTargetText then
    if targetText then
      targetText:SetText("")
    end
    return
  end

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

  targetText:SetText("")

  if isCasting and UnitExists(unit.."target") and frame.castBar:IsShown() and not frame.hideCastInfo then
    local targetOfTarget = unit.."target"
    local name = UnitName(targetOfTarget)
    local classColor = GetUnitHealthColor(targetOfTarget)

    targetText:SetText(name)
    targetText:SetTextColor(classColor.r, classColor.g, classColor.b)
    targetText:ClearAllPoints()
    if UnitCanAttack("player", unit) then
      targetText:SetPoint("TOPRIGHT", frame.castBar, "BOTTOMRIGHT", -4, 0)  -- Set anchor point for enemy
    else
      targetText:SetPoint("TOP", frame.castBar, "BOTTOM", 0, 0)  -- Set anchor point for friendly
    end
  else
    targetText:SetText("")
  end
end

hooksecurefunc(CastingBarMixin, "OnEvent", function(self)
  local unit = self.unit
  if not unit or not unit:find("nameplate") then return end

  local frame = GetSafeNameplate(unit)
  if not frame then return end
  if unit == "player" then return end

  local castBar = frame.castBar

  if frame.hideCastbarOverride or (EUIDB.nameplateHideFriendlyCastbars and UnitIsFriend("player", unit)) then
    castBar:Hide()
    return
  end

  if EUIDB.nameplateHideCastText then
    castBar.Text:Hide()
  elseif not castBar.Text:IsShown() then
    castBar.Text:Show()
  end

  skinCastbar(frame)

  updateCastTimer(frame, castBar, unit)

  UpdateNameplateTargetText(frame, unit)
end)
