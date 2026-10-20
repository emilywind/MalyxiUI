local SetCVar = C_CVar.SetCVar

---@param frame Frame
local function updateHealth(frame)
  if frame:IsForbidden() or not frame.isNameplate then return end

  local unit = GetNameplateUnit(frame)

  local healthBar = frame.healthBar

  local hPercFrame = frame.healthPercentage
  if not hPercFrame then
    hPercFrame = healthBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hPercFrame:SetTextColor(1, 1, 1)
    hPercFrame:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    frame.healthPercentage = hPercFrame
    ModifyFont(hPercFrame, EUIDB.nameplateFont)
  end

  if frame:IsForbidden() then return end
  if not unit then return end
  local percent = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100) or 0
  local healthPercentage = string.format("%.0f", percent)

  if EUIDB.nameplateHealthPercent then
    hPercFrame:SetText(healthPercentage .. "%")
    hPercFrame:SetAlpha(1)
  else
    hPercFrame:SetText('')
    hPercFrame:SetAlpha(0)
  end
end

local ClickAreaFramePool = CreateFramePool("Frame")
local NameplateClickAreas = {}

local function updateClickableArea(nameplate)
  if not (nameplate and nameplate:CanChangeHitTestPoints()) then return end

  local frame = nameplate.UnitFrame
  local info = GetNameplateUnitInfo(frame)
  if not info.exists then return end

  local clickableArea = NameplateClickAreas[nameplate:GetName()]
  if not clickableArea then
    clickableArea = ClickAreaFramePool:Acquire()
    clickableArea:SetParent(nameplate)
    NameplateClickAreas[nameplate:GetName()] = clickableArea
  end

  clickableArea:Show()
  clickableArea:ClearAllPoints()

  local isClickthroughFriend = info.isFriend and EUIDB.nameplateFriendlyClickthrough

  if isClickthroughFriend then
    clickableArea:SetPoint("TOPLEFT", frame.HealthBarsContainer, "CENTER", 0, 0)
    clickableArea:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "CENTER", 0, 0)
    else
      clickableArea:SetPoint("TOPLEFT", frame.HealthBarsContainer, "TOPLEFT", -9,  24)
      clickableArea:SetPoint("BOTTOMRIGHT", frame.HealthBarsContainer, "BOTTOMRIGHT",  9,  -16)
  end

  nameplate:SetAllHitTestPoints(clickableArea)
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
local function modifyNamePlate(frame)
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
function InitNameplates()
  if initNameplates then return end

  -- hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded",
  --   ---@param unit string
  --   function(_, unit) -- This needs to be run for party markers to work
  --     if issecretvalue(unit) or not unit:find("nameplate") then return end
  --     local nameplate = GetSafeNameplate(unit)
  --     if nameplate then
  --       updateNameplate(nameplate)
  --       updateHealth(nameplate)
  --       modifyNamePlate(nameplate)
  --     end
  --   end
  -- )

  -- Keep nameplates on screen
  SetCVar("nameplateOtherBottomInset", 0.1)
  SetCVar("nameplateOtherTopInset", 0.08)

  if not EUIDB.skinNameplates then return end

  EUISetCVar("nameplateResourceOnTarget")
  EUISetCVar("nameplateShowAll")
  EUISetCVar("nameplateShowFriends")
  EUISetCVar("nameplateShowEnemyMinions")

  hooksecurefunc("CompactUnitFrame_UpdateHealth", updateHealth)

  OnEvents({
    "NAME_PLATE_UNIT_ADDED",
    "NAME_PLATE_UNIT_REMOVED",
  }, function(_, event, unit)
    local frame, nameplate = GetSafeNameplate(unit)
    if not frame then return end

    if event == "NAME_PLATE_UNIT_ADDED" then
      modifyNamePlate(frame)
      updateNameplate(frame)
      updateHealth(frame)
      HookCastbarOnEvent(frame)
    end

    updateClickableArea(nameplate)
    PetIndicator(frame)
    CombatIndicator(frame)
  end)

  hooksecurefunc("CompactUnitFrame_UpdateName", updateNameplate)

  initNameplates = true
end

OnPlayerLogin(InitNameplates)

function RefreshNameplates()
  DoToNameplates(function(frame, nameplate)
    modifyNamePlate(frame)
    updateNameplate(frame)
    updateHealth(frame)
    updateClickableArea(nameplate)
    HookCastbarOnEvent(frame)
  end)
end
