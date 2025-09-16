local SetCVar = C_CVar.SetCVar

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

OnPlayerLogin(function()
  if not EUIDB.skinNameplates then return end

  hooksecurefunc(NamePlateDriverFrame, "AcquireUnitFrame", function(_, nameplate)
    if (nameplate.UnitFrame) then
      nameplate.UnitFrame.isNameplate = true
    end
  end)

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

  EUISetCVar("nameplateResourceOnTarget")
  EUISetCVar("nameplateShowAll", nil, "showAllNameplates")
  EUISetCVar("nameplateShowFriends")
  EUISetCVar("nameplateShowEnemyMinions")

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

  local function updateHealth(frame)
    if frame:IsForbidden() or not frame.isNameplate then return end

    local unit = frame.displayedUnit or frame.unit

    local healthBar = frame.healthBar
    local healthPercentage = ceil((UnitHealth(unit) / UnitHealthMax(unit) * 100))
    local isPersonal = GetSafeNameplate(unit) == GetSafeNameplate("player")
    local healthColor = GetUnitHealthColor(unit)

    if isPersonal then
      healthBar:SetStatusBarTexture(EUIDB.statusBarTex)
      healthBar.myHealPrediction:SetTexture(EUIDB.statusBarTex)
      ClassNameplateManaBarFrame:SetStatusBarTexture(EUIDB.statusBarTex)
      ClassNameplateManaBarFrame.FeedbackFrame.BarTexture:SetTexture(EUIDB.statusBarTex)
      ClassNameplateManaBarFrame.FeedbackFrame.LossGlowTexture:SetTexture(EUIDB.statusBarTex)

      if frame.optionTable.colorNameBySelection then
        if healthPercentage <= 100 and healthPercentage >= 30 then
          healthBar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b, 1)
        elseif healthPercentage < 30 then -- Red color when below 30% on Personal Resource Bar
          healthBar:SetStatusBarColor(1, 0, 0)
        end
      end
    end

    local hPercFrame = frame.healthPercentage
    if not hPercFrame then
      hPercFrame = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      hPercFrame:SetTextColor(1, 1, 1)
      hPercFrame:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)
      frame.healthPercentage = hPercFrame
    end
    ModifyFont(hPercFrame, EUIDB.nameplateFont)

    if EUIDB.nameplateHealthPercent and healthPercentage ~= 100 then
      hPercFrame:SetText(healthPercentage .. '%')
    else
      hPercFrame:SetText('')
    end
  end
  hooksecurefunc("CompactUnitFrame_UpdateHealth", updateHealth)

  local function modifyNamePlates(frame)
    if frame:IsForbidden() or not frame.isNameplate then return end

    local healthBar = frame.healthBar
    healthBar:SetStatusBarTexture(EUIDB.statusBarTex)
    healthBar.myHealPrediction:SetTexture(EUIDB.statusBarTex)

    ModifyFont(frame.name, EUIDB.nameplateFont, EUIDB.nameplateNameFontSize)

    if frame.ClassificationFrame then
      frame.ClassificationFrame:SetPoint('CENTER', frame.healthBar, 'LEFT', 0, 0)
    end
  end
  hooksecurefunc("DefaultCompactNamePlateFrameSetup", modifyNamePlates)

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

  OnEvents({
    "NAME_PLATE_UNIT_ADDED",
    "NAME_PLATE_UNIT_REMOVED",
  }, function(_, _, unit)
    local frame = GetSafeNameplate(unit)
    if not frame then return end

    PetIndicator(frame)
  end)

  local function updateName(frame)
    local unit = frame.displayedUnit or frame.unit
    if not unit or frame:IsForbidden() or not frame.isNameplate then return end

    frame.classificationIndicator:SetAlpha(EUIDB.nameplateHideClassificationIcon and 0 or 1)
    frame.selectionHighlight:SetAlpha(0) -- Hide the ugly target background

    local instanceData = GetInstanceData()

    PartyMarker(frame)
    PetIndicator(frame)
    CombatIndicator(frame)

    local unitInfo = GetUnitInfo(unit)

    if not unitInfo.exists then return end

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
    else
      frame.hasArenaNumber = false
    end

    local healthColor = GetUnitHealthColor(unit)
    if EUIDB.nameplateFriendlyNamesClassColor and unitInfo.isFriend then
      frame.name:SetTextColor(healthColor.r, healthColor.g, healthColor.b, 1)
    end

    if EUIDB.nameplateShowLevel then
      local levelText = frame.levelText
      if not levelText then
        levelText = frame.healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("RIGHT", frame.healthBar, "RIGHT", -1, 0)
        frame.levelText = levelText
      end
      ModifyFont(levelText, EUIDB.nameplateFont)
      frame.unitLevel = unitInfo.level
      local c = GetCreatureDifficultyColor(frame.unitLevel)
      if unitInfo.classification == 'rare' or unitInfo.classification == 'rareelite' then
        c = {
          r = 0.8,
          g = 0.8,
          b = 0.8
        }
      end

      local levelString = frame.unitLevel
      local levelSuffix = ''
      if (levelString < 0) then
        levelString = '|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12|t'
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
      frame.levelText:SetTextColor(c.r, c.g, c.b)
      frame.levelText:SetText(levelString .. levelSuffix)
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
      local name, realm = UnitName(unit)

      if not EUIDB.nameplateHideServerNames and realm then
        name = name .. " - " .. realm
      elseif EUIDB.nameplateNameLength > 0 and not unitInfo.isPlayer then
        name = (string.len(name) > EUIDB.nameplateNameLength) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
      end

      frame.name:SetText(name)
    end
  end
  hooksecurefunc("CompactUnitFrame_UpdateName", updateName)

  function RefreshNameplates()
    for _, nameplate in pairs(GetAllNameplates()) do
      PartyMarker(nameplate)
      updateName(nameplate)
      updateHealth(nameplate)
      modifyNamePlates(nameplate)
    end
  end
end)
