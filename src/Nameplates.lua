local SetCVar = C_CVar.SetCVar

---@param frame Frame
local function updateHealth(frame)
  if frame:IsForbidden() or not frame.isNameplate then return end

  local unit = GetNameplateUnit(frame)

  local healthBar = frame.healthBar
  local healthPercentage = UnitHealthPercent(unit, true)
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
        SetStatusBarColor(healthBar, healthColor)
      elseif healthPercentage < 30 then   -- Red color when below 30% on Personal Resource Bar
        SetStatusBarColor(healthBar, COLOR_RED)
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

function MUI.RepositionName(frame)
  local info = GetNameplateUnitInfo(frame)
  local function RepositionName(frame)
    if frame:IsForbidden() or not info.exists or frame.name.changing then return end
    frame.name.changing = true

    frame.name:ClearAllPoints()
    frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4)
    frame.name.changing = false
  end
  if not frame.nameHooked then
    hooksecurefunc(frame.name, "SetPoint", function()
      RepositionName(frame)
    end)

    frame.nameHooked = true
  end
  RepositionName(frame)

  if not frame.newNameParent then
    frame.newNameParent = CreateFrame("Frame", nil, frame)
    frame.newNameParent:SetAllPoints(frame)
    frame.newNameParent:SetFrameStrata("HIGH")
  end
  frame.name:SetParent(frame.newNameParent)
  frame.name:SetDrawLayer("OVERLAY", 7)
end

---@param frame Frame
local function modifyNamePlates(frame)
  if frame:IsForbidden() or not frame.isNameplate then return end

  -- local healthBar = frame.healthBar
  -- healthBar:SetStatusBarTexture(EUIDB.statusBarTex)
  -- healthBar.myHealPrediction:SetTexture(EUIDB.statusBarTex)

  MUI.RepositionName(frame)
  ModifyFont(frame.name, EUIDB.nameplateFont, EUIDB.nameplateNameFontSize)

  if frame.ClassificationFrame then
    frame.ClassificationFrame:SetPoint('CENTER', frame.healthBar, 'LEFT', 0, 0)
  end
end

---@param frame Frame
local function updateNameplate(frame)
  local unitInfo = GetNameplateUnitInfo(frame)
  if not unitInfo.exists or frame:IsForbidden() or not frame.isNameplate then return end

  frame.classificationIndicator:SetAlpha(EUIDB.nameplateHideClassificationIcon and 0 or 1)
  frame.selectionHighlight:SetAlpha(0)   -- Hide the ugly target background

  local instanceData = GetInstanceData()

  if not unitInfo.exists then return end

  if EUIDB.nameplateHideFriendlyHealthbars and unitInfo.isFriend and not unitInfo.isSelf then
    frame.HealthBarsContainer:Hide()
    frame.HealthBarsContainer:SetAlpha(0)
  else
    frame.HealthBarsContainer:Show()
    frame.HealthBarsContainer:SetAlpha(1)
  end

  if EUIDB.arenaNumbers and instanceData.isInArena and unitInfo.isPlayer and unitInfo.isEnemy then   -- Check to see if unit is a player to avoid needless checks on pets
    for i = 1, 5 do
      if UnitIsUnit(unitInfo.id, "arena" .. i) then
        frame.name:SetText(i)
        frame.hasArenaNumber = true
        break
      end
    end
  else
    frame.hasArenaNumber = false
  end

  local healthColor = GetUnitHealthColor(unitInfo.id)
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

  if not frame.hasArenaNumber then
    local name = unitInfo.name
    if not EUIDB.nameplateHideServerNames and unitInfo.realm then
      name = name .. " - " .. unitInfo.realm
    elseif EUIDB.nameplateAbbrevNames and not unitInfo.isPlayer and not issecretvalue(name) then
      name = (string.len(name) > 20) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
    end

    frame.name:SetText(name)
  end
end

local initNameplates = false
local hookedAcquireUnitFrame = false
function InitNameplates()
  if initNameplates then return end

  if not hookedAcquireUnitFrame then
    hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded",
      ---@param unit string
      function(_, unit) -- This needs to be run for party markers to work
        local nameplate = GetSafeNameplate(unit)
        if nameplate then nameplate.isNameplate = true end
      end
    )
    hookedAcquireUnitFrame = true
  end

  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1)
  SetCVar("nameplateOtherTopInset", 0.08)

  if not EUIDB.skinNameplates then return end

  -- local cVars = {
  --   nameplateGlobalScale = 1,
  --   nameplateMinScale = 1,
  --   nameplateMaxScale = 1,
  --   nameplateSelectedScale = 1.2,
  --   namePlateVerticalScale = 2.7,
  --   nameplateHorizontalScale = 1.4,
  -- }

  -- for cVar, value in pairs(cVars) do
  --   SetCVar(cVar, value)
  -- end

  EUISetCVar("nameplateResourceOnTarget")
  EUISetCVar("nameplateShowAll")
  EUISetCVar("nameplateShowFriends")
  EUISetCVar("nameplateShowEnemyMinions")

  -- C_NamePlate.SetNamePlateFriendlyClickThrough(EUIDB.nameplateFriendlyClickthrough)

  -- local defaultFriendlyWidth, defaultFriendlyHeight = C_NamePlate.GetNamePlateFriendlySize()

  -- function SetFriendlyNameplateSize()
  --   if EUIDB.nameplateFriendlySmall then
  --     C_NamePlate.SetNamePlateFriendlySize((0.7 * defaultFriendlyWidth), defaultFriendlyHeight)
  --   else
  --     C_NamePlate.SetNamePlateFriendlySize(defaultFriendlyWidth, defaultFriendlyHeight)
  --   end
  -- end

  -- SetFriendlyNameplateSize()

  -- hooksecurefunc("CompactUnitFrame_UpdateHealth", updateHealth)
  hooksecurefunc("CompactUnitFrame_UpdateName", modifyNamePlates)

  OnEvents({
    "NAME_PLATE_UNIT_ADDED",
    "NAME_PLATE_UNIT_REMOVED",
  }, function(_, _, unit)
    local frame = GetSafeNameplate(unit)
    if not frame then return end

    PetIndicator(frame)
    CombatIndicator(frame)
  end)

  hooksecurefunc("CompactUnitFrame_UpdateName", updateNameplate)

  initNameplates = true
end

OnPlayerLogin(InitNameplates)

function RefreshNameplates()
  DoToNameplates(function(nameplate)
    updateNameplate(nameplate)
    updateHealth(nameplate)
    modifyNamePlates(nameplate)
  end)
end
