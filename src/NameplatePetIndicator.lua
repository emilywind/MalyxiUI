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
    frame.fadedNPC = true
    frame:SetAlpha(0.5)
    frame.petIndicator:Hide()
  end
end
-- Pet Indicator
function PetIndicator(frame)
  local unit = frame.displayedUnit or frame.unit
  if not unit then return end
  local info = GetUnitInfo(unit)

  if not EUIDB.nameplatePetIndicator then
    if frame.petIndicator then
      frame.petIndicator:Hide()
    end
    return
  end

  if not frame.alphaHook then
    hooksecurefunc(frame, "SetAlpha", function(self, alpha)
      if not self.fadedNPC or self.changingAlpha or self:IsForbidden() then return end
      self.changingAlpha = true
      if self.unit and not UnitIsUnit(self.unit, "target") then
        self:SetAlpha(alpha)
      end
      self.changingAlpha = nil
    end)
    frame.alphaHook = true
  end

  -- Initialize
  if not frame.petIndicator then
    frame.petIndicator = frame:CreateTexture(nil, "OVERLAY")
    frame.petIndicator:SetAtlas("newplayerchat-chaticon-newcomer")
    frame.petIndicator:SetSize(12, 12)
  end

  -- Set position and scale dynamically
  frame.petIndicator:SetPoint("CENTER", frame.healthBar, "CENTER", 0, 0)

  local npcID = GetNPCIDFromGUID(info.guid)

  -- Demo lock pet
  if npcID == 17252 then
    local isRealPet = UnitIsUnit(frame.unit, "pet")
    for i = 1, 3 do
      if UnitIsUnit(frame.unit, "arenapet" .. i) or UnitIsUnit(frame.unit, "partypet" .. i) then
        isRealPet = true
        break
      end
    end
    if isRealPet then
      frame.petIndicator:Show()
      return
    else
      frame.petIndicator:Hide()
    end
    if EUIDB.nameplateFadeSecondaryPets then
      FadeNameplate(frame)
      return
    end
  end
  -- All hunter pets have same NPC id, check for it.
  if npcID == 165189 then
    local isRealPet = UnitIsUnit(frame.unit, "pet")
    for i = 1, 3 do
      if UnitIsUnit(frame.unit, "arenapet" .. i) or UnitIsUnit(frame.unit, "partypet" .. i) then
        isRealPet = true
        break
      end
    end
    if isRealPet then
      frame.petIndicator:Show()
      return
    else
      frame.petIndicator:Hide()
    end
    if EUIDB.nameplateFadeSecondaryPets then
      FadeNameplate(frame)
      return
    end
  end

  if EUIDB.nameplateFadeSecondaryPets and secondaryPets[npcID] and info.isEnemy then
    FadeNameplate(frame)
    return
  end

  if frame.fadedNPC then -- Unfade any faded NPCs not re-caught above
    frame:SetAlpha(1)
    frame.fadedNPC = false
  end
end
