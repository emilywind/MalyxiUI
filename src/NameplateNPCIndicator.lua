local npcIDs = {}

local importantNpcIDs = {
  -- [npcID] = { spellID, duration }
  [5913] = { 8143, 10 },       -- Tremor
  [5925] = { 204336, 3 },      -- Grounding
  [53006] = { 98008, 6 },      -- Spirit Link
  [59764] = { 108280, 12 },    -- Healing Tide
  [61245] = { 192058, 2 },     -- Static Charge
  [105451] = { 204331, 15 },   -- Counterstrike
  [105427] = { 204330, 15 },   -- Skyfury
  [179867] = { 355580, 6 },    -- Static Field

  -- Warrior
  [119052] = { 236320, 15 },   -- War Banner

  --Priest
  [101398] = { 211522, 12 },   -- Psyfiend

  --Warlock
  [89] = { 1122, 30 },         -- Infernal
  [135002] = { 265187, 15 },   -- Demonic Tyrant
  [179193] = { 353601, 15 },   -- Fel Obelisk
  [107100] = { 201996, 20 },   -- Call Observer
  [103673] = { 205180, 20 },   -- Darkglare
}

local lessImportantNpcIDs = {
  [2630] = { 2484, 20 },       -- Earthbind
  [60561] = { 51485, 20 },     -- Earthgrab
  [3527] = { 5394, 15 },       -- Healing Stream
  [6112] = { 8512, 120 },      -- Windfury
  [100943] = { 198838, 15 },   -- Earthen Wall
  [97285] = { 192077, 15 },    -- Wind Rush
}

local allNpcIDs = {}
PushTableIntoTable(allNpcIDs, importantNpcIDs)
PushTableIntoTable(allNpcIDs, lessImportantNpcIDs)

local npcStartTimes = setmetatable({}, { __mode = "v" })

local function createIcon(nameplate)
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

---@param np Frame
local function nameplateTotem(np)
  local unitInfo = GetNameplateUnitInfo(np)

  if not unitInfo.exists then return end

  local iconFrame = np.npcIcon

  if unitInfo.isNpc and unitInfo.npcID and npcIDs[unitInfo.npcID] then
    if not iconFrame then
      iconFrame = createIcon(np)
      np.npcIcon = iconFrame
    end

    iconFrame:Show()

    local totemData = npcIDs[unitInfo.npcID]
    local spellID, duration = unpack(totemData)

    local tex = C_Spell.GetSpellTexture(spellID)

    iconFrame.icon:SetTexture(tex)
    local startTime = npcStartTimes[unitInfo.guid]
    if startTime then
      iconFrame.cooldown:SetCooldown(startTime, duration)
      iconFrame.cooldown:Show()
    else
      iconFrame.cooldown:Hide()
    end
  elseif iconFrame then
    iconFrame:Hide()
  end
end

OnEvents({
  "NAME_PLATE_UNIT_ADDED",
  "NAME_PLATE_UNIT_REMOVED",
  "COMBAT_LOG_EVENT_UNFILTERED"
},
---@param event string
---@param ... any
function(_, event, ...)
  local unit = ... -- Will not be unit for COMBAT_LOG_EVENT_UNFILTERED
  local np = GetSafeNameplate(unit)

  if event == 'NAME_PLATE_UNIT_ADDED' then
    nameplateTotem(np)
  elseif event == 'NAME_PLATE_UNIT_REMOVED' then
    if np.npcIcon then
      np.npcIcon:Hide()
    end
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    local _, subevent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_SUMMON" then
      local npcID = GetNPCIDFromGUID(destGUID)
      if npcID and npcIDs[npcID] then
        npcStartTimes[destGUID] = GetTime()
      end
    end
  end
end)

function UpdateNPCIndicatorSetting()
  npcIDs = {}

  if EUIDB.nameplateNPCIndicators == "important" then
    npcIDs = importantNpcIDs
  elseif EUIDB.nameplateNPCIndicators == "all" then
    npcIDs = allNpcIDs
  end

  DoToNameplates(nameplateTotem)
end

OnPlayerLogin(function()
  UpdateNPCIndicatorSetting()
end)
