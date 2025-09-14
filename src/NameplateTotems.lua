-- Simplified and enhanced version of NugTotemIcon
OnPlayerLogin(function()
  if
    not EUIDB.skinNameplates
    or EUIDB.nameplateTotemIndicators == "none"
  then
    return
  end

  local f = OnEvents({
    "NAME_PLATE_UNIT_ADDED",
    "NAME_PLATE_UNIT_REMOVED",
    "COMBAT_LOG_EVENT_UNFILTERED"
  }, function(self, event, ...)
    return self[event](...)
  end)

  local totemStartTimes = setmetatable({}, { __mode = "v" })

  local importantTotemNpcIDs = {
    -- [npcID] = { spellID, duration }
    [5913] = { 8143, 10 },     -- Tremor
    [5925] = { 204336, 3 },    -- Grounding
    [53006] = { 98008, 6 },    -- Spirit Link
    [59764] = { 108280, 12 },  -- Healing Tide
    [61245] = { 192058, 2 },   -- Static Charge
    [105451] = { 204331, 15 }, -- Counterstrike
    [105427] = { 204330, 15 }, -- Skyfury
    [179867] = { 355580, 6 },  -- Static Field

    -- Warrior
    [119052] = { 236320, 15 }, -- War Banner

    --Priest
    [101398] = { 211522, 12 }, -- Psyfiend

    --Warlock
    [89] = { 1122, 30 },       -- Infernal
    [135002] = { 265187, 15 }, -- Demonic Tyrant
    [179193] = { 353601, 15 }, -- Fel Obelisk
    [107100] = { 201996, 20 }, -- Call Observer
    [103673] = { 205180, 20 }, -- Darkglare
  }

  local lessImportantTotemNpcIDs = {
    [2630] = { 2484, 20 },     -- Earthbind
    [60561] = { 51485, 20 },   -- Earthgrab
    [3527] = { 5394, 15 },     -- Healing Stream
    [6112] = { 8512, 120 },    -- Windfury
    [100943] = { 198838, 15 }, -- Earthen Wall
    [97285] = { 192077, 15 },  -- Wind Rush
  }

  local totemNpcIDs = importantTotemNpcIDs
  if EUIDB.nameplateTotemIndicators == "all" then
    for k, v in pairs(lessImportantTotemNpcIDs) do
      totemNpcIDs[k] = v
    end
  end

  local function CreateIcon(nameplate)
    local frame = CreateFrame("Frame", nil, nameplate)
    frame:SetSize(42, 42)
    frame:SetPoint("BOTTOM", nameplate, "TOP", 0, 5)

    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    frame.icon = icon

    local bg = ApplyEuiBackdrop(frame, frame)

    local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cd:SetReverse(true)
    cd:SetDrawEdge(false)
    cd:SetAllPoints(frame)

    frame.cooldown = cd
    frame.icon = icon
    frame.bg = bg

    return frame
  end

  function f.NAME_PLATE_UNIT_ADDED(unit)
    local np = C_NamePlate.GetNamePlateForUnit(unit)
    local guid = UnitGUID(unit)

    if not np or not guid then return end

    local npcID = GetNPCIDFromGUID(guid)

    if npcID and totemNpcIDs[npcID] then
      if not np.totemIcon then
        np.totemIcon = CreateIcon(np)
      end

      local iconFrame = np.totemIcon
      iconFrame:Show()

      local totemData = totemNpcIDs[npcID]
      local spellID, duration = unpack(totemData)

      local tex = C_Spell.GetSpellTexture(spellID)

      iconFrame.icon:SetTexture(tex)
      local startTime = totemStartTimes[guid]
      if startTime then
        iconFrame.cooldown:SetCooldown(startTime, duration)
        iconFrame.cooldown:Show()
      end
    end
  end

  function f.NAME_PLATE_UNIT_REMOVED(unit)
    local np = C_NamePlate.GetNamePlateForUnit(unit)

    if not np then return end

    if np.totemIcon then
      np.totemIcon:Hide()
    end
  end

  function f:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subevent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_SUMMON" then
      local npcID = GetNPCIDFromGUID(destGUID)
      if npcID and totemNpcIDs[npcID] then
        totemStartTimes[destGUID] = GetTime()
      end
    end
  end
end)
