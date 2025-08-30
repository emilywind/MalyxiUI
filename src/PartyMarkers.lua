function PartyMarker(frame)
  if (not EUIDB.partyMarker and not EUIDB.partyMarkerHealer) or frame:IsForbidden() then return end

  local info = GetNameplateUnitInfo(frame)
  if not info then return end

  local markerMode =  EUIDB.partyMarkerTexture
  local partyMarker = frame.partyMarker

  if not UnitInParty(frame.displayedUnit) or info.isEnemy or not info.isPlayer or info.isSelf or info.isNpc then
    if EUIDB.partyMarkerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
    end
    if partyMarker then
      partyMarker:Hide()
    end
    return
  else
    if partyMarker then
      partyMarker:Show()
    end
  end

  if not partyMarker then
    partyMarker = CreateFrame("Frame", nil, frame)
    partyMarker:SetFrameLevel(0)
    partyMarker:SetSize(24, 24)
    partyMarker.icon = partyMarker:CreateTexture(nil, "BACKGROUND", nil, 1)
    partyMarker.icon:SetAtlas(PARTY_MARKER)
    partyMarker.icon:SetSize(34, 48)
    partyMarker.icon:SetPoint("BOTTOM", partyMarker, "BOTTOM", 0, 5)
    partyMarker.icon:SetDesaturated(true)

    partyMarker.highlight = partyMarker:CreateTexture(nil, "BACKGROUND")
    partyMarker.highlight:SetAtlas(PARTY_MARKER)
    partyMarker.highlight:SetSize(55, 69)
    partyMarker.highlight:SetPoint("CENTER", partyMarker.icon, "CENTER", 0, -1)
    partyMarker.highlight:SetDesaturated(true)
    partyMarker.highlight:SetBlendMode("ADD")
    partyMarker.highlight:SetVertexColor(1, 1, 0)
    partyMarker.highlight:Hide()

    partyMarker.healerIcon = partyMarker:CreateTexture(nil, "BORDER")
    partyMarker.healerIcon:SetAtlas("communities-chat-icon-plus")
    partyMarker.healerIcon:SetSize(45, 45)
    partyMarker.healerIcon:SetPoint("BOTTOM", partyMarker.icon, "TOP", 0, -13)
    partyMarker.healerIcon:SetDesaturated(true)
    partyMarker.healerIcon:SetVertexColor(0, 1, 0)
    partyMarker.healerIcon:Hide()

    partyMarker:SetIgnoreParentAlpha(true)
    partyMarker:SetFrameStrata("LOW")
    frame.partyMarker = partyMarker
  end
  partyMarker.icon:SetAtlas(PARTY_MARKER)
  partyMarker:SetAlpha(1)

  if markerMode == 2 or markerMode == 3 then
    partyMarker.icon:SetRotation(math.rad(90))
  else
    partyMarker.icon:SetRotation(0)
  end

  partyMarker:SetScale(EUIDB.partyMarkerScale)
  partyMarker.icon:SetWidth(120)
  partyMarker.icon:SetHeight(120)
  partyMarker.highlight:SetWidth(120 + 26)
  partyMarker.highlight:SetHeight(120 + 26)
  partyMarker.healerIcon:SetScale(EUIDB.partyMarkerScale)

  partyMarker:SetPoint("BOTTOM", frame.name, "TOP", 0, -26)

  local classColor = GetUnitClassColor(frame.displayedUnit)

  if classColor then
    partyMarker.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
  end

  if EUIDB.partyMarkerHighlight then
    partyMarker.highlight:SetScale(EUIDB.partyMarkerScale)
    if info.isTarget then
      partyMarker.highlight:Show()
    else
      partyMarker.highlight:Hide()
    end
  end

  if EUIDB.partyMarkerHealer then
    local specID = GetSpecID(frame)
    if specID then
      if HEALER_SPECS[specID] then
        partyMarker.healerIcon:Show()
        partyMarker.healerIcon:ClearAllPoints()
        partyMarker.healerIcon:SetPoint("CENTER", partyMarker.icon, "CENTER", 0, 0)
        partyMarker.icon:Hide()
      else
        partyMarker.healerIcon:Hide()
        if EUIDB.partyMarker then
          partyMarker.icon:Show()
        else
          partyMarker.icon:Hide()
        end
      end
    end
  else
    partyMarker.healerIcon:Hide()
    partyMarker:Show()
    if EUIDB.partyMarkerHideRaidmarker then
      frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(0)
    end
  end
end

local function RefreshAllNameplates()
  for _, frame in pairs(C_NamePlate.GetNamePlates()) do
    PartyMarker(frame)
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
