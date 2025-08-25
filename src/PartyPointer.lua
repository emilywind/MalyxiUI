local HealerSpecs = {
  [105]  = true,   --> druid resto
  [270]  = true,   --> monk mw
  [65]   = true,   --> paladin holy
  [256]  = true,   --> priest disc
  [257]  = true,   --> priest holy
  [264]  = true,   --> shaman resto
  [1468] = true,   --> preservation evoker
}

local ppTextures = {
  [1] = "UI-QuestPoiImportant-QuestNumber-SuperTracked",
  [2] = "CreditsScreen-Assets-Buttons-Rewind",           --rotate
  [3] = "CovenantSanctum-Renown-DoubleArrow-Disabled",   -- rotate
  [4] = "Crosshair_Quest_128",
  [5] = "Crosshair_Wrapper_128",
  [6] = "honorsystem-icon-prestige-2",
  [7] = "plunderstorm-glues-queueselector-solo-selected",
  [8] = "plunderstorm-glues-queueselector-solo",
  [9] = "AutoQuest-Badge-Campaign",
  [10] = "Ping_Marker_Icon_OnMyWay",
  [11] = "Ping_Marker_Icon_NonThreat",
  [12] = "charactercreate-icon-customize-body-selected",
  [13] = "128-RedButton-Delete",
  [14] = 'plunderstorm-glues-logoarrow',
}

function PartyPointer(frame)
  if not EUIDB.partyPointer or frame:IsForbidden() then return end

  local info = GetNameplateUnitInfo(frame)
  if not info then return end

  local isInParty = UnitInParty(frame.displayedUnit)

  local pointerMode =  EUIDB.partyPointerTexture
  local normalTexture = ppTextures[pointerMode]

  if info.isEnemy or not isInParty or not info.isPlayer or info.isSelf or info.isNpc then
    if EUIDB.partyPointerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
    end
    if frame.partyPointer then
      frame.partyPointer:Hide()
    end
    return
  else
    if frame.partyPointer then
      frame.partyPointer:Show()
    end
  end

  if not frame.partyPointer then
    frame.partyPointer = CreateFrame("Frame", nil, frame)
    frame.partyPointer:SetFrameLevel(0)
    frame.partyPointer:SetSize(24, 24)
    frame.partyPointer.icon = frame.partyPointer:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.partyPointer.icon:SetAtlas(normalTexture)
    frame.partyPointer.icon:SetSize(34, 48)
    frame.partyPointer.icon:SetPoint("BOTTOM", frame.partyPointer, "BOTTOM", 0, 5)
    frame.partyPointer.icon:SetDesaturated(true)

    frame.partyPointer.highlight = frame.partyPointer:CreateTexture(nil, "BACKGROUND")
    frame.partyPointer.highlight:SetAtlas(normalTexture)
    frame.partyPointer.highlight:SetSize(55, 69)
    frame.partyPointer.highlight:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, -1)
    frame.partyPointer.highlight:SetDesaturated(true)
    frame.partyPointer.highlight:SetBlendMode("ADD")
    frame.partyPointer.highlight:SetVertexColor(1, 1, 0)
    frame.partyPointer.highlight:Hide()

    frame.partyPointer.healerIcon = frame.partyPointer:CreateTexture(nil, "BORDER")
    frame.partyPointer.healerIcon:SetAtlas("communities-chat-icon-plus")
    frame.partyPointer.healerIcon:SetSize(45, 45)
    frame.partyPointer.healerIcon:SetPoint("BOTTOM", frame.partyPointer.icon, "TOP", 0, -13)
    frame.partyPointer.healerIcon:SetDesaturated(true)
    frame.partyPointer.healerIcon:SetVertexColor(0, 1, 0)
    frame.partyPointer.healerIcon:Hide()

    frame.partyPointer:SetIgnoreParentAlpha(true)
    frame.partyPointer:SetFrameStrata("LOW")
  end
  frame.partyPointer.icon:SetAtlas(normalTexture)
  frame.partyPointer:SetAlpha(1)

  if pointerMode == 2 or pointerMode == 3 then
    frame.partyPointer.icon:SetRotation(math.rad(90))
  else
    frame.partyPointer.icon:SetRotation(0)
  end

  frame.partyPointer:SetScale(EUIDB.partyPointerScale)
  frame.partyPointer.icon:SetWidth(120)
  frame.partyPointer.icon:SetHeight(120)
  frame.partyPointer.highlight:SetWidth(120 + 26)
  frame.partyPointer.highlight:SetHeight(120 + 26)
  frame.partyPointer.healerIcon:SetScale(EUIDB.partyPointerScale)

  frame.partyPointer:SetPoint("BOTTOM", frame.name, "TOP", 0, -26)

  local classColor = GetUnitClassColor(frame.displayedUnit)
  local r, g, b = classColor.r, classColor.g, classColor.b

  frame.partyPointer.icon:SetVertexColor(r, g, b)

  if EUIDB.partyPointerHighlight then
    frame.partyPointer.highlight:SetScale(EUIDB.partyPointerScale)
    if info.isTarget then
      frame.partyPointer.highlight:Show()
    else
      frame.partyPointer.highlight:Hide()
    end
  end

  if EUIDB.partyPointerHealer then
    local specID = GetSpecID(frame)
    if specID then
      if HealerSpecs[specID] then
        frame.partyPointer.healerIcon:Show()
        frame.partyPointer.healerIcon:ClearAllPoints()
        frame.partyPointer.healerIcon:SetPoint("CENTER", frame.partyPointer.icon, "CENTER", 0, 0)
        frame.partyPointer.icon:Hide()
      else
        frame.partyPointer.healerIcon:Hide()
        frame.partyPointer.icon:Show()
      end
    end
  else
    frame.partyPointer.healerIcon:Hide()
    frame.partyPointer:Show()
    if EUIDB.partyPointerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
    end
  end
end

local function RefreshAllNameplates()
  for _, frame in pairs(C_NamePlate.GetNamePlates()) do
    PartyPointer(frame)
  end
end

local updateFrame = CreateFrame("Frame")

local function UpdateNpWidthShuffle(_, event)
  local instanceInfo = GetInstanceData()
  if event == "ARENA_OPPONENT_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
    if not instanceInfo.isInArena then return end
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(32727) -- Arena Preparation
    if not aura then return end

    if InCombatLockdown() then
      if not updateFrame.eventRegistered then
        updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        updateFrame.eventRegistered = true
      end
    else
      RefreshAllNameplates()
      C_Timer.After(1, function()
        if not InCombatLockdown() then
          RefreshAllNameplates()
        end
      end)
    end
  elseif event == "PLAYER_REGEN_ENABLED" then
    updateFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    updateFrame.eventRegistered = false
    RefreshAllNameplates()
  end
end
updateFrame:SetScript("OnEvent", UpdateNpWidthShuffle)
updateFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
updateFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
