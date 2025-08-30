------------
-- Player --
------------
PlayerCastingBarFrame:HookScript("OnEvent", function()
  local castBar = PlayerCastingBarFrame
  castBar.StandardGlow:Hide()
  castBar.TextBorder:Hide()
  castBar:SetSize(209, 18)
  castBar.TextBorder:ClearAllPoints()
  castBar.TextBorder:SetAlpha(0)
  castBar.Text:ClearAllPoints()
  castBar.Text:SetPoint("CENTER", castBar, "CENTER")
  castBar.Text:SetFont(EUIDB.font, 12, "OUTLINE")

  DarkenTexture(castBar.Border)
  DarkenTexture(castBar.Background)

  castBar.Icon:Show()
  castBar.Icon:SetSize(20, 20)
  castBar.Icon:ClearAllPoints()
  castBar.Icon:SetPoint("TOPLEFT", castBar, "TOPLEFT", -26, 1)
  ApplyEuiBackdrop(castBar.Icon, castBar)
end)

-------------------------------------
-- Target, Focus, and Arena Frames --
-------------------------------------
local function skinCastBar(self, setScale)
  if self:IsForbidden() then return end
  if InCombatLockdown() then return end
  local unit = self.unit

  self.Icon:SetSize(16, 16)
  self.Icon:ClearAllPoints()
  self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", -20, 2)
  ApplyEuiBackdrop(self.Icon, self)
  self.BorderShield:ClearAllPoints()
  self.BorderShield:SetPoint("CENTER", self.Icon, "CENTER", 0, -2.5)
  self.TextBorder:ClearAllPoints()
  self.TextBorder:SetAlpha(0)
  self.Text:ClearAllPoints()
  self.Text:SetPoint("CENTER", self, "CENTER")
  self.Text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")

  if setScale then
    self:SetScale(EUIDB.castBarScale, EUIDB.castBarScale)
  end

  DarkenTexture(self.Border, unit)
  DarkenTexture(self.Background, unit)

  local castText = self.Text:GetText()
  if castText ~= nil then
    if (strlen(castText) > 19) then
      local newCastText = strsub(castText, 0, 19)
      self.Text:SetText(newCastText .. "...")
    end
  end
end

for i = 1, 3 do
  _G['CompactArenaFrameMember' .. i].CastingBarFrame:HookScript("OnEvent", function(self)
    skinCastBar(self, false)
  end)
end

for i = 1, 5 do
  _G['Boss' .. i .. 'TargetFrameSpellBar']:HookScript("OnEvent", function(self)
    skinCastBar(self, false)
  end)
end

TargetFrameSpellBar:HookScript("OnEvent", function(self)
  skinCastBar(self, true)
end)
FocusFrameSpellBar:HookScript("OnEvent", function(self)
  skinCastBar(self, true)
end)

------------
-- Timers --
------------
OnPlayerLogin(function()
  local format = string.format
  local max = math.max
  local FONT = EUIDB.font

  if not InCombatLockdown() then
    PlayerCastingBarFrame.timer = PlayerCastingBarFrame:CreateFontString(nil)
    PlayerCastingBarFrame.timer:SetFont(FONT, 14, "THINOUTLINE")
    PlayerCastingBarFrame.timer:SetPoint("LEFT", PlayerCastingBarFrame, "RIGHT", 5, 0)
    PlayerCastingBarFrame.update = 0.1
    TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
    TargetFrameSpellBar.timer:SetFont(FONT, 11, "THINOUTLINE")
    TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 4, 0)
    TargetFrameSpellBar.update = 0.1
    FocusFrameSpellBar.timer = FocusFrameSpellBar:CreateFontString(nil)
    FocusFrameSpellBar.timer:SetFont(FONT, 11, "THINOUTLINE")
    FocusFrameSpellBar.timer:SetPoint("LEFT", FocusFrameSpellBar, "RIGHT", 4, 0)
    FocusFrameSpellBar.update = 0.1
  end

  local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
    if not self.timer then return end
    if self.update and self.update < elapsed then
      if self.casting then
        self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
      elseif self.channeling then
        self.timer:SetText(format("%.1f", max(self.value, 0)))
      else
        self.timer:SetText("")
      end
      self.update = .1
    else
      self.update = self.update - elapsed
    end
  end

  PlayerCastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
  TargetFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
  FocusFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
end)
