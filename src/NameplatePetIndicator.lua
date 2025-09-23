-- Main pet buff spell id's
local petValidSpellIDs = {
  [264662] = true,
  [264656] = true,
  [264663] = true,
  [284301] = true,
}

local mainPets = {
  [26125] = true,    -- DK Pet
  [103673] = true,   -- Darkglare
  [135002] = true,   -- Demonic Tyrant
  [89] = true,       -- Infernal
  [417] = true,      -- Felhunter Lock
  [416] = true,      -- Imp Lock
  [1860] = true,     -- VoidWalker Lock
  [1863] = true,     -- Sayaad/Succubus Lock
}

local secondaryPets = {
  -- Death Knight
  [221633] = true,   -- High Inquisitor Whitemane
  [221632] = true,   -- Highlord Darion Mograine
  [221634] = true,   -- Nazgrim
  [221635] = true,   -- King Thoras Trollbane
  [149555] = true,   -- Raise Abomination
  [163366] = true,   -- Magus (Army of the Dead)

  -- Warlock
  [135816] = true,   -- Vilefiend
  [226268] = true,   -- Gloomhound
  [226269] = true,   -- Charhound
  [136408] = true,   -- Darkhound
  [136398] = true,   -- Illidari Satyr
  [136403] = true,   -- Void Terror
  [198757] = true,   -- Void Lasher
  [224466] = true,   -- Voidwraith
  [98035] = true,    -- Dreadstalker
  [143622] = true,   -- Wild Imp
  [55659] = true,    -- Wild Imp (alternate)
  [228574] = true,   -- Pit Lord
  [228576] = true,   -- Mother of Chaos
  [217429] = true,   -- Overfiend
  [225493] = true,   -- Doomguard
  [89] = true,       -- Infernal

  -- Shaman
  [29264] = true,   -- Spirit Wolves (Enhancement)
  [77936] = true,   -- Greater Storm Elemental
  [95061] = true,   -- Greater Fire Elemental

  -- Druid
  [54983] = true,    -- Treant
  [103822] = true,   -- Treant (alternative)

  -- -- Priest
  [62982] = true,   -- Mindbender

  -- Hunter
  [105419] = true,   -- Dire Basilisk
  [62005] = true,    -- Beast
  [228224] = true,   -- Fenryr
  [228226] = true,   -- Hati
  [225190] = true,   -- Dark Hound
  [217228] = true,   -- Blood Beast
  [234018] = true,   -- Bear Pack Leader
}

local function FadeNameplate(frame)
  if not UnitIsUnit(frame.unit, "target") then
    frame:SetAlpha(0.5)
  end
end

local function ShowIndicator(frame)
  frame:SetAlpha(1)
  if not EUIDB.nameplatePetIndicator then return end
  if frame.petIndicator then
    frame.petIndicator:Show()
  end
end

local function HideIndicator(frame)
  frame:SetAlpha(1)
  if frame.petIndicator then
    frame.petIndicator:Hide()
  end
end

function PetIndicator(frame)
  local info = GetNameplateUnitInfo(frame)
  local instanceData = GetInstanceData()

  if not EUIDB.skinNameplates or not info.isNpc then -- Pets are always NPCs, so no need to create the indicator if not an NPC
    HideIndicator(frame)
    return
  end

  local petIndicator = frame.petIndicator
  if not petIndicator then
    petIndicator = frame.healthBar:CreateTexture(nil, "OVERLAY")
    petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
    petIndicator:SetSize(12, 12)
    frame.petIndicator = petIndicator
  end

  petIndicator:SetPoint("LEFT", frame.healthBar, "LEFT", 2, 0)

  -- Demo lock pet
  if info.npcID == 17252 then
    if instanceData.isInArena then
      local isRealPet = UnitIsUnit(info.id, "pet")
      for i = 1, 3 do
        if UnitIsUnit(info.id, "arenapet" .. i) or UnitIsUnit(info.id, "partypet" .. i) then
          isRealPet = true
          break
        end
      end
      if isRealPet then
        ShowIndicator(frame)
      else
        HideIndicator(frame)
        if EUIDB.nameplateFadeSecondaryPets then
          FadeNameplate(frame)
        end
      end
    else
      ShowIndicator(frame)
    end
    return
  end
  -- All hunter pets have same NPC id
  if info.npcID == 165189 then
    if instanceData.isInArena then
      local isRealPet = UnitIsUnit(info.id, "pet")
      for i = 1, 3 do
        if UnitIsUnit(info.id, "arenapet" .. i) or UnitIsUnit(info.id, "partypet" .. i) then
          isRealPet = true
          break
        end
      end
      if isRealPet then
        ShowIndicator(frame)
      else
        HideIndicator(frame)
        if EUIDB.nameplateFadeSecondaryPets then
          FadeNameplate(frame)
        end
      end
    else
      local isValidPet = false
      for i = 1, 6 do
        local aura = C_UnitAuras.GetAuraDataByIndex(info.id, i, "HELPFUL")
        if aura and petValidSpellIDs[aura.spellId] then
          isValidPet = true
          break
        end
      end
      if isValidPet then
        ShowIndicator(frame)
      else
        HideIndicator(frame)
        if EUIDB.nameplateFadeSecondaryPets then
          FadeNameplate(frame)
        end
      end
    end
    return
  end

  if mainPets[info.npcID] then
    ShowIndicator(frame)
  else
    HideIndicator(frame)
    if EUIDB.nameplateFadeSecondaryPets and secondaryPets[info.npcID] then
      FadeNameplate(frame)
    end
  end
end
