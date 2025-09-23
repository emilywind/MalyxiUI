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

function SkinObjectiveTracker()
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
    ApplyUIMode(objectiveTrackerFrame.Header.Background)
  end
end

OnEvents({
  "PLAYER_ENTERING_WORLD",
  "ZONE_CHANGED_NEW_AREA"
}, function()
  if EUIDB.hideObjectiveTracker then
    hideObjectiveTracker()
  end

  SkinObjectiveTracker()
end)
