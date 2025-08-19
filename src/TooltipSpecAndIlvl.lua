----------------------------------------------------------------------------
--    Modified and Simplified version of TipTacTalents (thanks Frozn)     --
-- Includes a custom version of LibFroznFunctions to show PVP Item Levels --
----------------------------------------------------------------------------
local MOD_NAME = ...
local tts = CreateFrame("Frame", MOD_NAME, nil, BackdropTemplateMixin and "BackdropTemplate")
tts:Hide()

local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0")

----------------------------------------------------------------------------------------------------
--                                           Variables                                            --
----------------------------------------------------------------------------------------------------

-- text constants
local TTT_TEXT = {
  talentsPrefix = (SPECIALIZATION or TALENTS), -- MoP: Could be changed from TALENTS (Talents) to SPECIALIZATION (Specialization)
  ailAndGSPrefix = STAT_AVERAGE_ITEM_LEVEL,
  loading = SEARCH_LOADING_TEXT,
  outOfRange = ERR_SPELL_OUT_OF_RANGE:sub(1, -2),
  none = NONE_KEY,
}

-- colors
local TTT_COLOR = {
  text = {
    default = HIGHLIGHT_FONT_COLOR, -- white
    spec = HIGHLIGHT_FONT_COLOR,  -- white
    pointsSpent = LIGHTYELLOW_FONT_COLOR,
    ail = HIGHLIGHT_FONT_COLOR,   -- white
    inlineGSPrefix = LIGHTYELLOW_FONT_COLOR
  }
}

----------------------------------------------------------------------------------------------------
--                                          Setup Addon                                           --
----------------------------------------------------------------------------------------------------

-- EVENT: addon loaded (one-time-event)
function tts:ADDON_LOADED(event, addOnName)
  -- not this addon
  if (addOnName ~= MOD_NAME) then
    return
  end

  -- apply hooks for inspecting
  self:ApplyHooksForInspecting()

  -- remove this event handler as it's not needed anymore
  self:UnregisterEvent(event)
  self[event] = nil
end

-- register events
tts:SetScript("OnEvent", function(self, event, ...)
  self[event](self, event, ...)
end)

tts:RegisterEvent("ADDON_LOADED")

----------------------------------------------------------------------------------------------------
--                                           Inspecting                                           --
----------------------------------------------------------------------------------------------------

-- HOOK: GameTooltip's OnTooltipSetUnit -- will schedule a delayed inspect request
local ttsTipLineIndexTalents, ttsTipLineIndexAILAndGS

local function TTS_OnTooltipSetUnit()
  if (
    C_AddOns.IsAddOnLoaded('TinyTooltip')
    or C_AddOns.IsAddOnLoaded('TipTac')
    or not EUIDB.enhanceTooltips
    or not EUIDB.tooltipSpecAndIlvl
  ) then
    return
  end

  -- get the unit id -- check the UnitFrame unit if this tip is from a concated unit, such as "targettarget".
  local unitID = GetTooltipUnit()

  -- no unit id
  if (not unitID) then
    return
  end

  -- invalidate line indexes
  ttsTipLineIndexTalents = nil
  ttsTipLineIndexAILAndGS = nil

  -- inspect unit
  local unitCacheRecord = LibFroznFunctions:InspectUnit(unitID, TTT_UpdateTooltip, true)

  if (unitCacheRecord) then
    TTT_UpdateTooltip(unitCacheRecord)
  end
end

-- apply hooks for inspecting during event ADDON_LOADED (one-time-function)
function tts:ApplyHooksForInspecting()
  -- hooks needs to be applied as late as possible during load, as we want to try and be the
  -- last addon to hook GameTooltip's OnTooltipSetUnit so we always have a "completed" tip to work on.

  -- HOOK: GameTooltip's OnTooltipSetUnit -- will schedule a delayed inspect request
  LibFroznFunctions:HookScriptOnTooltipSetUnit(GameTooltip, TTS_OnTooltipSetUnit)

  -- remove this function as it's not needed anymore
  self.ApplyHooksForInspecting = nil
end

----------------------------------------------------------------------------------------------------
--                                         Main Functions                                         --
----------------------------------------------------------------------------------------------------

function TTT_UpdateTooltip(unitCacheRecord)
  if not EUIDB.tooltipSpecAndIlvl then return end

  -- exit if unit from unit cache record doesn't match the current displaying unit
  local unitID = select(2, LibFroznFunctions:GetUnitFromTooltip(GameTooltip))

  if not unitID then return end

  local unitGUID = UnitGUID(unitID)

  if unitGUID ~= unitCacheRecord.guid then return end

  -- update tooltip with the unit cache record

  -- talents
  if unitCacheRecord.talents then
    local specText = LibFroznFunctions:CreatePushArray()

    -- talents available but no inspect data
    if unitCacheRecord.talents == LFF_TALENTS.available then
      if unitCacheRecord.canInspect then
        specText:Push(TTT_TEXT.loading)
      else
        -- check if talents/AIL for people out of range shouldn't be shown
        specText:Push(TTT_TEXT.outOfRange)
      end

      -- no talents available
    elseif unitCacheRecord.talents == LFF_TALENTS.na then
      specText:Clear()

      -- no talents found
    elseif unitCacheRecord.talents == LFF_TALENTS.none then
      specText:Push(TTT_TEXT.none)

      -- talents found
    else
      local spacer
      local talentFormat = 1

      if unitCacheRecord.talents.role then
        specText:Push(LibFroznFunctions:CreateMarkupForRoleIcon(unitCacheRecord.talents.role))
      end

      if unitCacheRecord.talents.iconFileID then
        spacer = (specText:GetCount() > 0) and " " or ""

        specText:Push(spacer .. LibFroznFunctions:CreateMarkupForClassIcon(unitCacheRecord.talents.iconFileID))
      end

      if ((talentFormat == 1) or (talentFormat == 2)) and (unitCacheRecord.talents.name) then
        spacer = (specText:GetCount() > 0) and " " or ""

        local classColor = LibFroznFunctions:GetClassColor(unitCacheRecord.classID, 5, nil)
        specText:Push(spacer .. classColor:WrapTextInColorCode(unitCacheRecord.talents.name))
      end
    end

    -- show spec text
    if (specText:GetCount() > 0) then
      local tipLineTextTalents = LibFroznFunctions:FormatText("{prefix}: {specText}", {
        prefix = TTT_TEXT.talentsPrefix,
        specText = TTT_COLOR.text.spec:WrapTextInColorCode(specText:Concat())
      })

      if (ttsTipLineIndexTalents) then
        _G["GameTooltipTextLeft" .. ttsTipLineIndexTalents]:SetText(tipLineTextTalents)
      else
        GameTooltip:AddLine(tipLineTextTalents)
        ttsTipLineIndexTalents = GameTooltip:NumLines()
      end
    end
  end

  -- Average Item Level
  if (unitCacheRecord.averageItemLevel) then
    local ailAndGSText = LibFroznFunctions:CreatePushArray()

    -- average item level available or no item data
    if (unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL.available) then
      if (unitCacheRecord.canInspect) then
        ailAndGSText:Push(TTT_TEXT.loading)
      else
        -- check if talents/AIL for people out of range shouldn't be shown
        ailAndGSText:Push(TTT_TEXT.outOfRange)
      end

      -- no average item level available
    elseif (unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL.na) then
      ailAndGSText:Clear()

      -- no average item level found
    elseif (unitCacheRecord.averageItemLevel == LFF_AVERAGE_ITEM_LEVEL.none) then
      ailAndGSText:Push(TTT_TEXT.none)

      -- average item level found
    elseif (unitCacheRecord.averageItemLevel) then
      -- average item level
      local averageItemLevel = (unitCacheRecord.averageItemLevel.value > 0) and unitCacheRecord.averageItemLevel.value or "-"

      local pvpIlvlText = ''
      if unitCacheRecord.averageItemLevel.pvpItemLevel then
        pvpIlvlText = ' (' .. unitCacheRecord.averageItemLevel.pvpItemLevel .. ' PVP)'
      end

      ailAndGSText:Push(unitCacheRecord.averageItemLevel.qualityColor:WrapTextInColorCode(averageItemLevel .. pvpIlvlText))
    end

    -- show ail and GS text
    if (ailAndGSText:GetCount() > 0) then
      local tipLineTextAverageItemLevel = LibFroznFunctions:FormatText("{prefix}: {averageItemLevelAndGearScore}", {
        prefix = TTT_TEXT.ailAndGSPrefix,
        averageItemLevelAndGearScore = TTT_COLOR.text.ail:WrapTextInColorCode(ailAndGSText:Concat())
      })

      if (ttsTipLineIndexAILAndGS) then
        _G["GameTooltipTextLeft" .. ttsTipLineIndexAILAndGS]:SetText(tipLineTextAverageItemLevel)
      else
        GameTooltip:AddLine(tipLineTextAverageItemLevel)
        ttsTipLineIndexAILAndGS = GameTooltip:NumLines()
      end
    end
  end

  -- recalculate size of tip to ensure that it has the correct dimensions
  LibFroznFunctions:RecalculateSizeOfGameTooltip(GameTooltip)
end
