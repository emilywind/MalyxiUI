local SetCVar = C_CVar.SetCVar

OnPlayerLogin(function()
  if not EUIDB.skinNameplates or C_AddOns.IsAddOnLoaded('BetterBlizzPlates') then return end

  local healthTex = EUIDB.healthBarTex
  local powerTex = EUIDB.powerBarTex

  local cVars = {
    nameplateGlobalScale = 1,
    nameplateMinScale = 1,
    nameplateMaxScale = 1,
    nameplateSelectedScale = 1.2,
    namePlateVerticalScale = 2.7,
    nameplateHorizontalScale = 1.4,
  }

  for cVar, value in pairs(cVars) do
    SetCVar(cVar, value)
  end

  SetCVar("nameplateResourceOnTarget", EUIDB.nameplateResourceOnTarget and 1 or 0)
  SetCVar("nameplateShowAll", EUIDB.showAllNameplates and 1 or 0)
  SetCVar("nameplateShowFriends", EUIDB.nameplateShowFriends and 1 or 0)
  SetCVar("nameplateShowEnemyMinions", EUIDB.nameplateShowEnemyMinions and 1 or 0)

  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1)
  SetCVar("nameplateOtherTopInset", 0.08)

  C_NamePlate.SetNamePlateFriendlyClickThrough(EUIDB.nameplateFriendlyClickthrough)

  local defaultFriendlyWidth, defaultFriendlyHeight = C_NamePlate.GetNamePlateFriendlySize()

  function SetFriendlyNameplateSize()
    if EUIDB.nameplateFriendlySmall then
      C_NamePlate.SetNamePlateFriendlySize((0.7 * defaultFriendlyWidth), defaultFriendlyHeight)
    else
      C_NamePlate.SetNamePlateFriendlySize(defaultFriendlyWidth, defaultFriendlyHeight)
    end
  end
  SetFriendlyNameplateSize()

  -------------------------------------------------------
  -- Red color when below 30% on Personal Resource Bar --
  -------------------------------------------------------
  hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
    if frame:IsForbidden() or not frame.isNameplate then return end

    local unit = frame.displayedUnit or frame.unit

    local healthBar = frame.healthBar
    local healthPercentage = ceil((UnitHealth(unit) / UnitHealthMax(unit) * 100))
    local isPersonal = C_NamePlate.GetNamePlateForUnit(unit) == C_NamePlate.GetNamePlateForUnit("player")
    local healthColor = GetUnitHealthColor(unit)

    if isPersonal then
      healthBar:SetStatusBarTexture(healthTex)
      ClassNameplateManaBarFrame:SetStatusBarTexture(powerTex)
      ClassNameplateManaBarFrame.FeedbackFrame.BarTexture:SetTexture(powerTex)
      ClassNameplateManaBarFrame.FeedbackFrame.LossGlowTexture:SetTexture(powerTex)
      if healthBar.myHealPrediction then
        healthBar.myHealPrediction:SetTexture(healthTex)
      end

      if frame.optionTable.colorNameBySelection then
        if healthPercentage <= 100 and healthPercentage >= 30 then
          healthBar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b, 1)
        elseif healthPercentage < 30 then
          healthBar:SetStatusBarColor(1, 0, 0)
        end
      end
    end

    local hPercFrame = frame.healthPercentage
    if not hPercFrame then
      hPercFrame = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      ModifyFont(hPercFrame, EUIDB.nameplateFont)
      hPercFrame:SetTextColor( 1, 1, 1 )
      hPercFrame:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
      frame.healthPercentage = hPercFrame
    end

    if EUIDB.nameplateHealthPercent and healthPercentage ~= 100 then
      hPercFrame:SetText(healthPercentage .. '%')
    else
      hPercFrame:SetText('')
    end
  end)

  local function abbrev(str, length)
    if not str then
      return UNKNOWN
    end

    length = length or 20

    str = (string.len(str) > length) and string.gsub(str, "%s?(.[\128-\191]*)%S+%s", "%1. ") or str
    return str
  end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", function(_, nameplate)
    if (nameplate.UnitFrame) then
      nameplate.UnitFrame.isNameplate = true
    end
  end)

  local function modifyNamePlates(frame)
    if frame:IsForbidden() or not frame.isNameplate then return end

    local healthBar = frame.healthBar
    healthBar:SetStatusBarTexture(healthTex)
    healthBar.myHealPrediction:SetTexture(healthTex)

    ModifyFont(frame.name, EUIDB.nameplateFont, EUIDB.nameplateNameFontSize)

    if frame.ClassificationFrame then
      frame.ClassificationFrame:SetPoint('CENTER', frame.healthBar, 'LEFT', 0, 0)
    end
  end

  hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)

  local function setValue(table, member, bool)
    if bool then
      TextureLoadingGroupMixin.AddTexture(
        { textures = table }, member
      )
    else
      TextureLoadingGroupMixin.RemoveTexture(
        { textures = table }, member
      )
    end
  end

  hooksecurefunc(
    NamePlateDriverFrame,
    'GetNamePlateTypeFromUnit',
    function(_, unit)
      local unitInfo = GetUnitInfo(unit)
      local instanceInfo = GetInstanceData()
      if not unitInfo.isFriend or not instanceInfo.isInPvE then
        setValue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar', false)
      else
        if EUIDB.nameplateHideFriendlyHealthbars then
          setValue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar', true)
        else
          setValue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar', false)
        end
      end
    end
  )

  hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    local unit = frame.displayedUnit or frame.unit
    if not unit or not frame.isNameplate or frame:IsForbidden() then return end

    frame.classificationIndicator:SetAlpha(EUIDB.nameplateHideClassificationIcon and 0 or 1)
    frame.selectionHighlight:SetAlpha(0) -- Hide the ugly target background

    local instanceData = GetInstanceData()

    PartyMarker(frame)

    local unitInfo = GetUnitInfo(unit)

    if EUIDB.nameplateHideFriendlyHealthbars and unitInfo.isFriend and not unitInfo.isSelf then
      frame.HealthBarsContainer:Hide()
      frame.HealthBarsContainer:SetAlpha(0)
    else
      frame.HealthBarsContainer:Show()
      frame.HealthBarsContainer:SetAlpha(1)
    end

    if EUIDB.arenaNumbers and instanceData.isInArena and unitInfo.isPlayer and unitInfo.isEnemy then -- Check to see if unit is a player to avoid needless checks on pets
      for i = 1, 5 do
        if UnitIsUnit(frame.unit, "arena" .. i) then
          frame.name:SetText(i)
          frame.hasArenaNumber = true
          break
        end
      end
    end

    local healthColor = GetUnitHealthColor(frame.displayedUnit)
    if EUIDB.nameplateFriendlyNamesClassColor and unitInfo.isFriend then
      frame.name:SetTextColor(healthColor.r, healthColor.g, healthColor.b, 1)
    end

    if EUIDB.nameplateShowLevel then
      if not frame.levelText then
        frame.levelText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.levelText:SetPoint("RIGHT", frame.healthBar, "RIGHT", -1, 0)
        ModifyFont(frame.levelText, EUIDB.nameplateFont)
      end
      frame.unitLevel = unitInfo.level
      local c = GetCreatureDifficultyColor(frame.unitLevel)
      if unitInfo.classification == 'rare' or unitInfo.classification == 'rareelite' then
        c = {
          r = 0.8,
          g = 0.8,
          b = 0.8
        }
      end

      local levelText = frame.unitLevel
      local levelSuffix = ''
      if (levelText < 0) then
        levelText = '|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12|t'
      else
        if (unitInfo.classification == 'elite') then
          levelSuffix = '+'
        elseif (unitInfo.classification == 'rareelite') then
          levelSuffix = '*+'
        elseif (unitInfo.classification == 'worldboss') then
          levelSuffix = '++'
        elseif (unitInfo.classification == 'rare') then
          levelSuffix = '*'
        elseif (unitInfo.classification == 'minus') then
          levelSuffix = '-'
        end
      end
      frame.levelText:SetTextColor( c.r, c.g, c.b )
      frame.levelText:SetText(levelText .. levelSuffix)
      frame.levelText:Show()
    elseif not EUIDB.nameplateShowLevel and frame.levelText then
      frame.levelText:SetText('')
      frame.levelText:Hide()
    end

    if unitInfo.isSelf and frame.levelText then
      frame.levelText:SetText('')
      frame.levelText:Hide()
    end

    if not frame.hasArenaNumber and (EUIDB.nameplateHideServerNames or EUIDB.nameplateNameLength > 0) then
      local name, realm = UnitName(frame.displayedUnit)

      if not EUIDB.nameplateHideServerNames and realm then
        name = name .. " - " .. realm
      end

      if EUIDB.nameplateNameLength > 0 then
        name = abbrev(name, EUIDB.nameplateNameLength)
      end

      frame.name:SetText(name)
    end
  end)
end)
