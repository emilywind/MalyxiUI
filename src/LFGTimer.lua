-----------------------------------
-- Adapted from LFG_ProposalTime --
-----------------------------------
local _, addon = ...

local function init()
  local TIMEOUT = 40

  if BigWigsLoader then -- If BigWigs is loaded, let's get rid of that ugly LFG status bar it makes
  	BigWigsLoader.RegisterMessage(addon, "BigWigs_FrameCreated", function(event, frame, name)
      if name == 'QueueTimer' then
        frame:Hide()
        frame:SetScript("OnUpdate", nil)
      end
    end)
  end

  local timerBar = CreateFrame("StatusBar", "EmsUILFGStatusBar", LFGDungeonReadyPopup)
  timerBar:SetFrameLevel(10) -- Ensure it appears above the popup
  timerBar:SetPoint("TOP", LFGDungeonReadyPopup, "BOTTOM", 0, -5)
  timerBar:SetSize(194, 14)

  SkinStatusBar(timerBar)

  timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
  timerBar.Text:SetFontObject(GameFontHighlight)
  timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")

  local timeLeft = 0
  local function barUpdate(self, elapsed)
    timeLeft = (timeLeft or 0) - elapsed
    timeLeft = max(timeLeft, 0) -- Ensure timeLeft doesn't go negative

    self:SetValue(timeLeft)
    self.Text:SetFormattedText("%.1f", timeLeft)
  end
  timerBar:SetScript("OnUpdate", barUpdate)

  OnEvent("LFG_PROPOSAL_SHOW", function()
    timerBar:SetMinMaxValues(0, TIMEOUT)
    timeLeft = TIMEOUT
  end)
end

OnPlayerLogin(init)
