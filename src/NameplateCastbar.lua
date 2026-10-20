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

local interruptIcons = {}
local interruptReady = nil

local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local isSpellKnown = function(spellID, isPet)
  return C_SpellBook.IsSpellInSpellBook(spellID, isPet and 1 or 0, true)
end

local function getKnownInterruptSpells()
  local classID = select(3, UnitClass("player"))
  local interruptSpells = interruptSpellsByClass[classID]
  local knownInterruptSpells = {}

  if interruptSpells then
    for _, spellID in ipairs(interruptSpells) do
      if isSpellKnown(spellID, false) or (UnitExists("pet") and isSpellKnown(spellID, true)) then
        table.insert(knownInterruptSpells, spellID)
        if not interruptIcons[spellID] then
          interruptIcons[spellID] = CreateFrame('Frame')
          interruptIcons[spellID].cooldown = CreateFrame("Cooldown", nil, interruptIcons[spellID], "CooldownFrameTemplate")
          interruptIcons[spellID].cooldown:SetMinimumCountdownDuration(0)
          interruptIcons[spellID].cooldown:HookScript("OnCooldownDone", function()
            interruptReady = true
            UpdateCastbarInterruptStatus()
          end)
        end
      end
    end
  end

  return knownInterruptSpells
end

local function updateInterruptTracking(castBar, unit)
  local castBarTexture = castBar:GetStatusBarTexture()
  if not EUIDB.nameplateCastbarColorInterrupt then
    castBarTexture:SetDesaturated(false)
    SetStatusBarColor(castBar, COLOR_WHITE)
    return
  end
  local notInterruptible

  if castBar.casting then
    _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
  elseif castBar.channeling then
    _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
  end

  if UnitIsEnemy("player", unit) then
    local knownInterruptSpellIDs = getKnownInterruptSpells()

    for _, interruptSpellID in ipairs(knownInterruptSpellIDs) do
      local cooldownInfo = C_Spell.GetSpellCooldownDuration(interruptSpellID)
      if cooldownInfo then
        interruptIcons[interruptSpellID].cooldown:SetCooldownFromDurationObject(cooldownInfo)
        interruptReady = not interruptIcons[interruptSpellID].cooldown:IsShown()
        if interruptReady then break end
      end
    end

    if notInterruptible ~= nil and interruptReady ~= nil and not interruptReady then
      castBarTexture:SetVertexColorFromBoolean(
        notInterruptible,
        COLOR_CASTBAR_NOT_INTERRUPTIBLE,
        COLOR_CASTBAR_NO_INTERRUPT
      )
    else
      castBarTexture:SetDesaturated(false)
      SetStatusBarColor(castBar, COLOR_WHITE)
    end
  end
end

function UpdateCastbarInterruptStatus()
  DoToNameplates(function(frame)
    if frame.castBar then
      updateInterruptTracking(frame.castBar, frame.unit)
    end
  end)
end

---@param frame Frame
local function skinCastbar(frame)
  local castBar = frame.castBar
  if not castBar then return end
  if castBar:IsForbidden() then return end

  ApplyEuiBackdrop(castBar.Icon, castBar)
  local timer = castBar.timer
  if not timer then
    timer = castBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timer:SetPoint("LEFT", castBar, "RIGHT", 2, 0)
    castBar.timer = timer
  end
  ModifyFont(castBar.Text, EUIDB.nameplateFont)
  ModifyFont(timer, EUIDB.nameplateFont, 11, "THINOUTLINE", COLOR_WHITE)
end

local function updateCastTimer(frame, castBar, unit)
  local duration = UnitCastingDuration(unit)
  if not duration then
    duration = UnitChannelDuration(unit)
  end

  local timerFrame = castBar.timer
  if duration and frame then
    timerFrame:SetAlpha(1)
    timerFrame:SetText(format("%.1f", duration:GetRemainingDuration()))
    C_Timer.After(0.1, function()
      updateCastTimer(frame, castBar, unit)
      updateInterruptTracking(castBar, unit)
    end)
  else
    timerFrame:SetAlpha(0)
  end
end

local function updateNameplateTargetText(frame, unit)
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

function HookCastbarOnEvent(frame)
  if not frame or frame.hookedCastbarOnEvent then return end
  if not frame.castBar then
    frame.castBar = frame.CastBarsContainer.castBar
  end
  frame.castBar:HookScript("OnEvent", function(castBar, event)
    if not EUIDB.skinNameplates then return end

    local unitInfo = GetNameplateUnitInfo(frame)

    if EUIDB.nameplateHideFriendlyCastbars and unitInfo.isFriend then
      castBar:Hide()
      return
    end

    if EUIDB.nameplateHideCastText then
      castBar.Text:Hide()
    elseif not castBar.Text:IsShown() then
      castBar.Text:Show()
    end

    skinCastbar(frame)

    updateNameplateTargetText(frame, unitInfo.id)

    updateCastTimer(frame, castBar, unitInfo.id)
  end)
  frame.hookedCastbarOnEvent = true
end
