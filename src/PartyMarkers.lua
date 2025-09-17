---@param frame Frame
function PartyMarker(frame)
  if frame:IsForbidden() then return end

  local info = GetNameplateUnitInfo(frame)
  if not info then return end

  local partyMarker = frame.partyMarker

  if not info.isInParty or info.isEnemy or not info.isPlayer or info.isSelf or info.isNpc then
    frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(1)
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
    partyMarker.icon:SetAtlas("plunderstorm-glues-logoarrow")
    partyMarker.icon:SetSize(48, 48)
    partyMarker.icon:SetPoint("BOTTOM", partyMarker, "BOTTOM", 0, 5)
    partyMarker.icon:SetDesaturated(true)

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
  partyMarker:SetAlpha(1)

  partyMarker:SetScale(EUIDB.partyMarkerScale)
  partyMarker.icon:SetWidth(120)
  partyMarker.icon:SetHeight(120)
  partyMarker.healerIcon:SetScale(EUIDB.partyMarkerScale)

  partyMarker:SetPoint("BOTTOM", frame.name, "TOP", 0, -26)

  local healthColor = GetUnitHealthColor(frame.displayedUnit)
  SetVertexColor(partyMarker.icon, healthColor)

  local specID = GetSpecID(frame)
  if EUIDB.partyMarkerHealer and specID and HEALER_SPECS[specID] then
    partyMarker.healerIcon:Show()
    partyMarker.healerIcon:ClearAllPoints()
    partyMarker.healerIcon:SetPoint("CENTER", partyMarker.icon, "CENTER", 0, 0)
    partyMarker.icon:Hide()
  elseif EUIDB.partyMarker then
    partyMarker.healerIcon:Hide()
    partyMarker.icon:Show()
  else
    partyMarker:Hide()
  end

  frame.RaidTargetFrame.RaidTargetIcon:SetAlpha(EUIDB.partyMarkerHideRaidmarker and 0 or 1)
end

local function RefreshAllNameplates()
  for _, nameplate in pairs(GetAllNameplates()) do
    PartyMarker(nameplate)
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
