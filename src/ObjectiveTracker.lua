local function hideObjectiveTracker()
  local instanceData = GetInstanceData()

  if instanceData.isInPvP or instanceData.isInPvE then
    ObjectiveTrackerFrame:SetAlpha(0)
  else
    local alpha = ObjectiveTrackerFrame:GetAlpha()
    if alpha ~= 1 then
      ObjectiveTrackerFrame:SetAlpha(1)
    end
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
frame:SetScript('OnEvent', function()
  if EUIDB.hideObjectiveTracker then
    hideObjectiveTracker()
  end

  if EUIDB.uiMode ~= 'blizzard' then
    skinObjectiveTracker()
  end
end)
