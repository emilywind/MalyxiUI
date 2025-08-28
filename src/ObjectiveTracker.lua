local function hideObjectiveTracker()
  local instanceData = GetInstanceData()
  local numTrackedQuests = C_QuestLog.GetNumQuestWatches()
  local numTrackedRecipes = #C_TradeSkillUI.GetRecipesTracked(true) + #C_TradeSkillUI.GetRecipesTracked(false)

  if instanceData.isInPvP or numTrackedQuests == 0 and numTrackedRecipes == 0 then
    ObjectiveTrackerFrame:SetAlpha(0)
    RegisterStateDriver(ObjectiveTrackerFrame, 'visibility', 'hide')
  else
    ObjectiveTrackerFrame:SetAlpha(1)
    RegisterStateDriver(ObjectiveTrackerFrame, 'visibility', 'show')
  end
end

local function skinObjectiveTracker()
  -- Headers
  for _, objectiveTrackerFrame in pairs({
    AdventureObjectiveTracker,
    MonthlyActivitiesObjectiveTracker,
    ObjectiveTrackerFrame,
    WorldQuestObjectiveTracker,
    BonusObjectiveTracker,
    QuestObjectiveTracker,
    ScenarioObjectiveTracker,
    AchievementObjectiveTracker,
    CampaignQuestObjectiveTracker,
    ProfessionsRecipeTracker,
  }) do
    DarkenTexture(objectiveTrackerFrame.Header.Background)
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
frame:RegisterEvent("TRACKED_RECIPE_UPDATE")
frame:SetScript('OnEvent', function()
  if EUIDB.hideObjectiveTracker then
    hideObjectiveTracker()
  end

  if EUIDB.uiMode ~= 'blizzard' then
    skinObjectiveTracker()
  end
end)
