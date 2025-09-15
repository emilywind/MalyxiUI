OnPlayerLogin(function()
  TimerTracker:HookScript("OnEvent", function(self, event)
    if event ~= "START_TIMER" then return end

    for i = 1, #self.timerList do
      local prefix = 'TimerTrackerTimer'..i
      local timer = _G[prefix]
      local statusBar = _G['TimerTrackerTimer'..i..'StatusBar']
      if statusBar and not timer.isFree then
        _G[prefix..'StatusBarBorder']:Hide()
        SkinStatusBar(statusBar)
      end
    end
  end)

  MirrorTimerContainer:HookScript("OnEvent", function(self, event)
    if event ~= 'MIRROR_TIMER_START' then return end

    for _, timer in pairs(self.mirrorTimers) do
      timer.TextBorder:Hide()
      timer.Text:ClearAllPoints()
      timer.Text:SetPoint("CENTER", timer.StatusBar, "CENTER")
      timer.Text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
      ApplyUIMode(timer.Border)
    end
  end)
end)
