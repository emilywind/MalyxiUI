OnPlayerLogin(function()
  if not EUIDB.skinNameplates or C_AddOns.IsAddOnLoaded('BetterBlizzPlates') then return end

  C_NamePlate.SetNamePlateFriendlyClickThrough(EUIDB.nameplateFriendlyClickthrough)

  local defaultFriendlyWidth, defaultFriendlyHeight = C_NamePlate.GetNamePlateFriendlySize()

  function SetFriendlyNameplateSize(isChange)
    if EUIDB.nameplateFriendlySmall then
      C_NamePlate.SetNamePlateFriendlySize((0.5 * defaultFriendlyWidth), defaultFriendlyHeight)
    elseif isChange then
      C_NamePlate.SetNamePlateFriendlySize(defaultFriendlyWidth, defaultFriendlyHeight)
    end
  end
  SetFriendlyNameplateSize()

  -------------------------------------------------------
  -- Red color when below 30% on Personal Resource Bar --
  -------------------------------------------------------
  hooksecurefunc("CompactUnitFrame_UpdateHealth", function(frame)
    if frame:IsForbidden() then return end

    local healthPercentage = ceil((UnitHealth(frame.displayedUnit) / UnitHealthMax(frame.displayedUnit) * 100))
    local isPersonal = C_NamePlate.GetNamePlateForUnit(frame.unit) == C_NamePlate.GetNamePlateForUnit("player")

    if isPersonal then
      local _, className = UnitClass("player")
      local classR, classG, classB = GetClassColor(className)
      if not frame.emsUISkinned then
        local healthTex = EUIDB.healthBarTex
        local powerTex = EUIDB.powerBarTex
        frame.healthBar:SetStatusBarTexture(healthTex)
        ClassNameplateManaBarFrame:SetStatusBarTexture(powerTex)
        ClassNameplateManaBarFrame.FeedbackFrame.BarTexture:SetTexture(powerTex)
        ClassNameplateManaBarFrame.FeedbackFrame.LossGlowTexture:SetTexture(powerTex)
        frame.emsUISkinned = true
      end
      if frame.optionTable.colorNameBySelection and not frame:IsForbidden() then
        if healthPercentage <= 100 and healthPercentage >= 30 then
          frame.healthBar:SetStatusBarColor(classR, classG, classB, 1)
        elseif healthPercentage < 30 then
          frame.healthBar:SetStatusBarColor(1, 0, 0)
        end
      end
    end

    if not frame.isNameplate then return end

    if not frame.healthPercentage then
      frame.healthPercentage = frame.healthBar:CreateFontString(frame.healthPercentage, "OVERLAY", "GameFontNormalSmall")
      SetDefaultFont(frame.healthPercentage, nil)
      frame.healthPercentage:SetTextColor( 1, 1, 1 )
      frame.healthPercentage:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
    end

    if EUIDB.nameplateHealthPercent and healthPercentage ~= 100 then
      frame.healthPercentage:SetText(healthPercentage .. '%')
    else
      frame.healthPercentage:SetText('')
    end
  end)

  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1)
  SetCVar("nameplateOtherTopInset", 0.08)

  local function abbrev(str, length)
    if ( not str ) then
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

  local function setTrue(table, member)
    TextureLoadingGroupMixin.AddTexture(
      { textures = table }, member
    )
  end

  local function setNil(table, member)
    TextureLoadingGroupMixin.RemoveTexture(
      { textures = table }, member
    )
  end

  local function modifyNamePlates(frame, options)
    if ( frame:IsForbidden() ) then return end

    local healthBar = frame.healthBar
    healthBar:SetStatusBarTexture(EUIDB.healthBarTex)

    local castBar = frame.castBar
    if (castBar) then
      if EUIDB.nameplateHideCastText then
        castBar.Text:Hide()
      end

      if (castBar.euiClean) then return end

      SetDefaultFont(castBar.Text, EUIDB.nameplateNameFontSize - 1)

      ApplyEuiBackdrop(castBar.Icon, castBar)

      castBar.euiClean = true
    end

    if (frame.ClassificationFrame) then
      frame.ClassificationFrame:SetPoint('CENTER', frame.healthBar, 'LEFT', 0, 0)
    end
  end

  hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)

  function GetUnitReaction(unit)
    local reaction = UnitReaction(unit, "player")
    local isEnemy = false
    local isFriend = false
    local isNeutral = false

    if reaction then
      if reaction < 4 then
        isEnemy = true
      elseif reaction == 4 then
        isNeutral = true
      else
        isFriend = true
      end
    end

    return isEnemy, isFriend, isNeutral
  end

  hooksecurefunc(
    NamePlateDriverFrame,
    'GetNamePlateTypeFromUnit',
    function(_, unit)
      local _, isFriend, _ = GetUnitReaction(unit)
      local isPlayer = UnitIsPlayer(unit)
      if not isFriend then
        setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
      else
        if isPlayer then
          -- local role = UnitGroupRolesAssigned(unit)
          if EUIDB.nameplateHideFriendlyHealthbars then
            setTrue(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
          else
            setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
          end
        else
          setNil(DefaultCompactNamePlateFrameSetUpOptions, 'hideHealthbar')
        end
      end
  end)

  hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if not frame.unit or not frame.isNameplate then return end

    if frame:IsForbidden() then return end

    if EUIDB.nameplateHideClassificationIcon then
      frame.classificationIndicator:SetAlpha(0)
    else
      frame.classificationIndicator:SetAlpha(1)
    end

    if EUIDB.nameplateHideFriendlyHealthbars and not frame:IsForbidden() then
      local _, isFriend = GetUnitReaction(frame.displayedUnit)
      local alpha = isFriend and 0 or 1
      frame.HealthBarsContainer:SetAlpha(alpha)
      frame.selectionHighlight:SetAlpha(0)
    end

    local isPersonal = UnitIsUnit(frame.displayedUnit, "player")
    if isPersonal then
      if frame.levelText then
        frame.levelText:SetText('')
      end
      return
    end

    SetDefaultFont(frame.name, EUIDB.nameplateNameFontSize)

    local hasArenaNumber = false

    if EUIDB.arenaNumbers and IsActiveBattlefieldArena() and UnitIsPlayer(frame.unit) and UnitIsEnemy("player", frame.unit) then -- Check to see if unit is a player to avoid needless checks on pets
      for i = 1, 5 do
        if UnitIsUnit(frame.unit, "arena" .. i) then
          frame.name:SetText(i)
          hasArenaNumber = true
          break
        end
      end
    end

    if EUIDB.nameplateFriendlyNamesClassColor and UnitIsPlayer(frame.unit) and UnitIsFriend("player", frame.displayedUnit) then
      local _,className = UnitClass(frame.displayedUnit)
      local classR, classG, classB = GetClassColor(className)

      frame.name:SetTextColor(classR, classG, classB, 1)
    end

    if (EUIDB.nameplateShowLevel) then
      if not frame.levelText then
        frame.levelText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        local isLargeNameplates = tonumber(GetCVar("nameplateVerticalScale")) >= 2.7
        frame.levelText:SetPoint("RIGHT", frame.healthBar, "RIGHT", -1, 0)
      end
      frame.unitLevel = UnitEffectiveLevel(frame.unit)
      local c = GetCreatureDifficultyColor(frame.unitLevel)
      local unitClassification = UnitClassification(frame.unit)
      if unitClassification == 'rare' or unitClassification == 'rareelite' then
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
        if (unitClassification == 'elite') then
          levelSuffix = '+'
        elseif (unitClassification == 'rareelite') then
          levelSuffix = '*+'
        elseif (unitClassification == 'worldboss') then
          levelSuffix = '++'
        elseif (unitClassification == 'rare') then
          levelSuffix = '*'
        elseif (unitClassification == 'minus') then
          levelSuffix = '-'
        end
      end
      frame.levelText:SetTextColor( c.r, c.g, c.b )
      frame.levelText:SetText(levelText .. levelSuffix)
      frame.levelText:Show()
    elseif (not EUIDB.nameplateShowLevel) then
      if (frame.levelText) then
        frame.levelText:SetText('')
        frame.levelText:Hide()
      end
    end

    if not hasArenaNumber and (EUIDB.nameplateHideServerNames or EUIDB.nameplateNameLength > 0) then
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
