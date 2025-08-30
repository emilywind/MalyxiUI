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
  local partyPointer = frame.partyPointer

  if info.isEnemy or not isInParty or not info.isPlayer or info.isSelf or info.isNpc then
    if EUIDB.partyPointerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
    end
    if partyPointer then
      partyPointer:Hide()
    end
    return
  else
    if partyPointer then
      partyPointer:Show()
    end
  end

  if not partyPointer then
    partyPointer = CreateFrame("Frame", nil, frame)
    partyPointer:SetFrameLevel(0)
    partyPointer:SetSize(24, 24)
    partyPointer.icon = partyPointer:CreateTexture(nil, "BACKGROUND", nil, 1)
    partyPointer.icon:SetAtlas(normalTexture)
    partyPointer.icon:SetSize(34, 48)
    partyPointer.icon:SetPoint("BOTTOM", partyPointer, "BOTTOM", 0, 5)
    partyPointer.icon:SetDesaturated(true)

    partyPointer.highlight = partyPointer:CreateTexture(nil, "BACKGROUND")
    partyPointer.highlight:SetAtlas(normalTexture)
    partyPointer.highlight:SetSize(55, 69)
    partyPointer.highlight:SetPoint("CENTER", partyPointer.icon, "CENTER", 0, -1)
    partyPointer.highlight:SetDesaturated(true)
    partyPointer.highlight:SetBlendMode("ADD")
    partyPointer.highlight:SetVertexColor(1, 1, 0)
    partyPointer.highlight:Hide()

    partyPointer.healerIcon = partyPointer:CreateTexture(nil, "BORDER")
    partyPointer.healerIcon:SetAtlas("communities-chat-icon-plus")
    partyPointer.healerIcon:SetSize(45, 45)
    partyPointer.healerIcon:SetPoint("BOTTOM", partyPointer.icon, "TOP", 0, -13)
    partyPointer.healerIcon:SetDesaturated(true)
    partyPointer.healerIcon:SetVertexColor(0, 1, 0)
    partyPointer.healerIcon:Hide()

    partyPointer:SetIgnoreParentAlpha(true)
    partyPointer:SetFrameStrata("LOW")
    frame.partyPointer = partyPointer
  end
  partyPointer.icon:SetAtlas(normalTexture)
  partyPointer:SetAlpha(1)

  if pointerMode == 2 or pointerMode == 3 then
    partyPointer.icon:SetRotation(math.rad(90))
  else
    partyPointer.icon:SetRotation(0)
  end

  partyPointer:SetScale(EUIDB.partyPointerScale)
  partyPointer.icon:SetWidth(120)
  partyPointer.icon:SetHeight(120)
  partyPointer.highlight:SetWidth(120 + 26)
  partyPointer.highlight:SetHeight(120 + 26)
  partyPointer.healerIcon:SetScale(EUIDB.partyPointerScale)

  partyPointer:SetPoint("BOTTOM", frame.name, "TOP", 0, -26)

  local classColor = GetUnitClassColor(frame.displayedUnit)
  local r, g, b = classColor.r, classColor.g, classColor.b

  partyPointer.icon:SetVertexColor(r, g, b)

  if EUIDB.partyPointerHighlight then
    partyPointer.highlight:SetScale(EUIDB.partyPointerScale)
    if info.isTarget then
      partyPointer.highlight:Show()
    else
      partyPointer.highlight:Hide()
    end
  end

  if EUIDB.partyPointerHealer then
    local specID = GetSpecID(frame)
    if specID then
      if HealerSpecs[specID] then
        partyPointer.healerIcon:Show()
        partyPointer.healerIcon:ClearAllPoints()
        partyPointer.healerIcon:SetPoint("CENTER", partyPointer.icon, "CENTER", 0, 0)
        partyPointer.icon:Hide()
      else
        partyPointer.healerIcon:Hide()
        partyPointer.icon:Show()
      end
    end
  else
    partyPointer.healerIcon:Hide()
    partyPointer:Show()
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

OnEvents({
  "ARENA_OPPONENT_UPDATE",
  "GROUP_ROSTER_UPDATE"
}, function(self, event)
  local instanceInfo = GetInstanceData()
  if not instanceInfo.isInArena then return end
  if event == "ARENA_OPPONENT_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(32727) -- Arena Preparation
    if not aura then return end

    if InCombatLockdown() then
      if not self.eventRegistered then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.eventRegistered = true
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
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self.eventRegistered = false
    RefreshAllNameplates()
  end
end)
