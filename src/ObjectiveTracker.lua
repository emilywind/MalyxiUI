local function skinObjectiveTracker(desaturation)
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
    objectiveTrackerFrame.Header.Background:SetDesaturation(desaturation)
    objectiveTrackerFrame.Header.Background:SetVertexColor(getFrameColour())
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript('OnEvent', function()
  if EUIDB.hideObjectiveTracker then
    local instanceType = select(2, IsInInstance())

    if instanceType == 'pvp' then
      ObjectiveTrackerFrame:SetAlpha(0)
      RegisterStateDriver(ObjectiveTrackerFrame, 'visibility', 'hide')
    else
      ObjectiveTrackerFrame:SetAlpha(1)
      RegisterStateDriver(ObjectiveTrackerFrame, 'visibility', 'show')
    end
  end

  if EUIDB.darkenUi then
    skinObjectiveTracker(1)
  end
end)
