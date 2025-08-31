local function hideObjectiveTracker()
  local instanceData = GetInstanceData()

  if instanceData.isInBg then
    ObjectiveTrackerFrame:SetAlpha(0)
  else
    local alpha = ObjectiveTrackerFrame:GetAlpha()
    if alpha == 0 then
      ObjectiveTrackerFrame:SetAlpha(1)
    end
  end
end

local function skinObjectiveTracker()
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

OnEvents({
  "PLAYER_ENTERING_WORLD",
  "ZONE_CHANGED_NEW_AREA"
}, function()
  if EUIDB.hideObjectiveTracker then
    hideObjectiveTracker()
  end

  if EUIDB.uiMode ~= 'blizzard' then
    skinObjectiveTracker()
  end
end)
