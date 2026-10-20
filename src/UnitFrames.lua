local unitHealthbars = {}

local BUFF_DEBUFF_SIZE = 20

-------------------------------
-- Class Colored Health Bars --
-------------------------------
---@param healthbar StatusBar
local function setUnitColor(healthbar)
  local unit = healthbar.unit
  if not unit then return end
  local unitInfo = GetUnitInfo(unit)

  unitHealthbars[unit] = healthbar

  if not EUIDB.classColoredUnitHealth then
    healthbar:SetStatusBarDesaturated(false)
    SetStatusBarColor(healthbar, COLOR_WHITE)
    return
  end

  healthbar:SetStatusBarDesaturated(true)
  local healthColor = GetUnitHealthColor(unit)
  if unitInfo.isPlayer and not unitInfo.isConnected then
    SetStatusBarColor(healthbar, COLOR_GREY)
  else
    SetStatusBarColor(healthbar, healthColor)
  end
end

function UpdateUnitFrameHealthbars()
  for _, healthbar in pairs(unitHealthbars) do
    setUnitColor(healthbar)
  end
end

------------------------------------------
-- Buffs/Debuffs on Target/Focus Frames --
------------------------------------------
---@param aura Button
local function applyAuraSkin(aura)
  local icon = aura.Icon
  StyleIcon(icon)

  local border = ApplyEuiBackdrop(icon, aura)

  if aura.Border then
    aura.Border:SetAlpha(1)
    SetEuiBorderColor(border, GetVertexColor(aura.Border))
    aura.Border:SetAlpha(0)
  else
    SetEuiBorderColor(border)
  end
end

local hooked = {}

local function UpdateFrameAuras(aura)
  if not hooked[aura] then
    hooked[aura] = true

    applyAuraSkin(aura)
  end
end

local function SafeCall(object, method, ...)
  if object and object[method] then
    return pcall(object[method], object, ...)
  end

  return false
end

local function StyleTargetBuff(buff)
  if buff.Count then
    buff.Count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    buff.Count:ClearAllPoints()
    buff.Count:SetPoint("BOTTOMRIGHT", buff, "BOTTOMRIGHT", 2, 0)
  end
end

local function StyleTargetDebuff(debuff)
  if debuff.Count then
    debuff.Count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    debuff.Count:ClearAllPoints()
    debuff.Count:SetPoint("BOTTOMRIGHT", debuff, "BOTTOMRIGHT", 2, 0)
  end
end

local function DisableDefaultUnitAuraContainer(frame)
  if not frame or not frame.GetAuraContainer then
    return
  end

  local ok, defaultAuraContainer = pcall(frame.GetAuraContainer, frame)
  if not ok or not defaultAuraContainer then
    return
  end

  frame.maxBuffs = 0
  frame.maxDebuffs = 0
  SafeCall(defaultAuraContainer, "SetEnabled", false)
  SafeCall(defaultAuraContainer, "Hide")
end

local function InitializeUnitAuraButton(auraFrame, isDebuff, size)
  auraFrame:SetSize(size, size)

  if not auraFrame.Icon then
    auraFrame.Icon = auraFrame:CreateTexture(nil, "BACKGROUND")
    auraFrame.Icon:SetAllPoints(auraFrame)
    auraFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    auraFrame:SetIcon(auraFrame.Icon)
  end

  if not auraFrame.Cooldown then
    auraFrame.Cooldown = CreateFrame("Cooldown", nil, auraFrame, "CooldownFrameTemplate")
    auraFrame.Cooldown:SetAllPoints(auraFrame.Icon)
    auraFrame.Cooldown:SetDrawBling(false)
    auraFrame.Cooldown:SetReverse(true)
    auraFrame:SetDurationCooldown(auraFrame.Cooldown)
  end

  if auraFrame.Cooldown.GetCountdownFontString then
    auraFrame.CooldownText = auraFrame.Cooldown:GetCountdownFontString()
    if auraFrame.CooldownText then
      auraFrame.CooldownText:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
      auraFrame.CooldownText:ClearAllPoints()
      auraFrame.CooldownText:SetPoint("CENTER", auraFrame.Icon, "CENTER", 0, 0)
    end
  end

  if not auraFrame.MUIBorderOverlay then
    auraFrame.MUIBorderOverlay = CreateFrame("Frame", nil, auraFrame)
    auraFrame.MUIBorderOverlay:SetAllPoints(auraFrame)
    auraFrame.MUIBorderOverlay:SetFrameLevel(auraFrame.Cooldown:GetFrameLevel() + 1)
  end

  if not auraFrame.Count then
    auraFrame.Count = auraFrame.MUIBorderOverlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    auraFrame.Count:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    auraFrame.Count:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 1, 0)
    auraFrame:SetApplicationCount(auraFrame.Count)
  end

  UpdateFrameAuras(auraFrame)
  if auraFrame.border and auraFrame.MUIBorderOverlay then
    auraFrame.border:SetParent(auraFrame.MUIBorderOverlay)
    auraFrame.border:SetDrawLayer("OVERLAY", 1)
  end

  if isDebuff then
    StyleTargetDebuff(auraFrame)
  else
    StyleTargetBuff(auraFrame)
  end
end

local function GetUnitAuraParent(frame)
  return frame and frame.TargetFrameContent and frame.TargetFrameContent.TargetFrameContentContextual or frame
end

local function GetUnitAuraAnchor(frame)
  return frame and frame.TargetFrameContainer and frame.TargetFrameContainer.FrameTexture or frame
end

local function ReflowUnitAuraContainers(frame)
  if not frame or not frame.MUIBuffContainer or not frame.MUIDebuffContainer or not AnchorUtil then
    return
  end

  local mirrorVertically = frame.buffsOnTop == true
  local point = mirrorVertically and "BOTTOMLEFT" or "TOPLEFT"
  local relativePoint = mirrorVertically and "TOPLEFT" or "BOTTOMLEFT"
  local verticalGrowth = mirrorVertically and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
  local yOffset = mirrorVertically and -6 or 4

  frame.MUIDebuffContainer:ClearAllPoints()
  frame.MUIDebuffContainer:SetPoint(point, GetUnitAuraAnchor(frame), relativePoint, 5, yOffset)
  frame.MUIDebuffContainer:SetFlowLayoutAnchorPoint(point)
  frame.MUIDebuffContainer:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, verticalGrowth)
  frame.MUIDebuffContainer:SetFlowLayoutMaximumLineSize(155)

  frame.MUIBuffContainer:ClearAllPoints()
  frame.MUIBuffContainer:SetPoint(point, frame.MUIDebuffContainer, relativePoint, 0, yOffset)
  frame.MUIBuffContainer:SetFlowLayoutAnchorPoint(point)
  frame.MUIBuffContainer:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, verticalGrowth)
  frame.MUIBuffContainer:SetFlowLayoutMaximumLineSize(155)
end

local function UpdateUnitDebuffCasterFilter(frame)
  local debuffContainer = frame and frame.MUIDebuffContainer
  if not debuffContainer then
    return
  end

  local unit = frame.unit or debuffContainer:GetUnit()
  local showAllCasters = unit and (UnitIsUnit(unit, "player") or UnitIsFriend("player", unit)) == true
  if debuffContainer.MUIShowAllCasters == showAllCasters then
    return
  end

  debuffContainer.MUIShowAllCasters = showAllCasters
  debuffContainer:SetAuraGroupCandidateFilters("Debuffs", {
    isFromPlayerOrPlayerPet = not showAllCasters or nil
  })
  debuffContainer:SetAuraGroupMaxFrameCount("DebuffsAlwaysShown", showAllCasters and 0 or 16)
end

local function CreateUnitAuraContainers(frame, unit)
  if not frame or not frame.GetAuraContainer or frame.MUIBuffContainer or frame.MUIDebuffContainer or
      not AuraUtil or type(AuraUtil.CreateFilterString) ~= "function" then
    return
  end

  DisableDefaultUnitAuraContainer(frame)

  local parent = GetUnitAuraParent(frame)
  local buffContainer = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
  if parent and parent.GetFrameLevel then
    buffContainer:SetFrameLevel(math.max(parent:GetFrameLevel() + 2, 0))
  end
  buffContainer:SetSize(1, 1)
  buffContainer:SetFlowLayoutPadding(0, 0, 0, 10)
  buffContainer:SetUnit(unit)
  buffContainer:SetEnabled(true)
  frame.MUIBuffContainer = buffContainer

  local debuffContainer = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
  if parent and parent.GetFrameLevel then
    debuffContainer:SetFrameLevel(math.max(parent:GetFrameLevel() + 2, 0))
  end
  debuffContainer:SetSize(1, 1)
  debuffContainer:SetFlowLayoutPadding(0, 0, 0, 10)
  debuffContainer:SetUnit(unit)
  debuffContainer:SetEnabled(true)
  frame.MUIDebuffContainer = debuffContainer

  buffContainer:AddAuraGroup("Buffs", AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), {
    maxFrameCount = 32,
    candidateFilters = {
      isStealable = false
    },
    initializeFrame = function(auraFrame)
      InitializeUnitAuraButton(auraFrame, false, BUFF_DEBUFF_SIZE)
    end,
    layout = {
      elementSpacing = 3,
      lineSpacing = 3
    }
  })

  buffContainer:AddAuraGroup("BuffsStealable", AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), {
    maxFrameCount = 32,
    candidateFilters = {
      isStealable = true
    },
    initializeFrame = function(auraFrame)
      InitializeUnitAuraButton(auraFrame, false, BUFF_DEBUFF_SIZE)
      if auraFrame.border then
        auraFrame.border:SetVertexColor(0.8, 0.3, 1)
      end
    end,
    layout = {
      elementSpacing = 3,
      lineSpacing = 3
    }
  })

  local debuffFilter = AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful)
  debuffContainer:AddAuraGroup("Debuffs", debuffFilter, {
    maxFrameCount = 16,
    candidateFilters = {
      isFromPlayerOrPlayerPet = true
    },
    initializeFrame = function(auraFrame)
      InitializeUnitAuraButton(auraFrame, true, BUFF_DEBUFF_SIZE)
    end,
    layout = {
      elementSpacing = 3,
      lineSpacing = 3
    }
  })

  debuffContainer:AddAuraGroup("DebuffsAlwaysShown", debuffFilter, {
    maxFrameCount = 16,
    candidateFilters = {
      nameplateShowAll = true,
      isFromPlayerOrPlayerPet = false
    },
    initializeFrame = function(auraFrame)
      InitializeUnitAuraButton(auraFrame, true, BUFF_DEBUFF_SIZE)
    end,
    layout = {
      elementSpacing = 3,
      lineSpacing = 3
    }
  })

  ReflowUnitAuraContainers(frame)
  UpdateUnitDebuffCasterFilter(frame)
end

local function UpdateUnitAuraContainers(frame, unit)
  if not frame then
    return
  end

  unit = unit or frame.unit
  if not unit then
    return
  end

  CreateUnitAuraContainers(frame, unit)
  DisableDefaultUnitAuraContainer(frame)
  ReflowUnitAuraContainers(frame)
  UpdateUnitDebuffCasterFilter(frame)

  if frame.MUIBuffContainer then
    frame.MUIBuffContainer:SetUnit(unit)
    frame.MUIBuffContainer:UpdateAllAuras()
  end

  if frame.MUIDebuffContainer then
    frame.MUIDebuffContainer:SetUnit(unit)
    frame.MUIDebuffContainer:UpdateAllAuras()
  end
end

local function RefreshFrameAuras(frame)
  if not frame then
    return
  end

  UpdateUnitAuraContainers(frame, frame.unit)

  if frame.auraPools then
    for aura, _ in frame.auraPools:EnumerateActive() do
      UpdateFrameAuras(aura)

      if aura.Border then
        StyleTargetDebuff(aura)
      else
        StyleTargetBuff(aura)
      end
    end
  end
end

OnPlayerLogin(function()
  TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()
  FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:Hide()

  hooksecurefunc("UnitFrameHealthBar_Update", setUnitColor)
  hooksecurefunc("HealthBar_OnValueChanged", setUnitColor)

  hooksecurefunc(TargetFrame, "OnEvent", function(self)
    UpdateUnitAuraContainers(self, self.unit or "target")
  end)

  hooksecurefunc(FocusFrame, "OnEvent", function(self)
    UpdateUnitAuraContainers(self, self.unit or "focus")
  end)

  if TargetFrame and type(TargetFrame.UpdateAuras) == "function" then
    hooksecurefunc(TargetFrame, "UpdateAuras", RefreshFrameAuras)
  end

  if FocusFrame and type(FocusFrame.UpdateAuras) == "function" then
    hooksecurefunc(FocusFrame, "UpdateAuras", RefreshFrameAuras)
  end

  hooksecurefunc("PlayerFrame_UpdateStatus", function()
    if IsResting() then
      PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Hide()
    end
  end)
end)
