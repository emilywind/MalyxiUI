-- Raid Frames, Raid-style Party Frames, Arena Frames --
local SetCVar = C_CVar.SetCVar

local compactUnitFrames = {}

local function updateTextures(self)
  if self:IsForbidden() then return end
  if self and self:GetName() then
    local name = self:GetName()
    if name and name:match("^Compact") then
      if not compactUnitFrames[name] then
        compactUnitFrames[name] = self
      end

      if self:IsForbidden() then return end

      local healthbar = self.healthBar
      healthbar:SetStatusBarTexture(EUIDB.statusBarTex)
      healthbar:GetStatusBarTexture():SetDrawLayer("BORDER")
      self.myHealPrediction:SetTexture(EUIDB.statusBarTex)
      self.otherHealPrediction:SetTexture(EUIDB.statusBarTex)

      local powerBar = self.powerBar
      powerBar:SetStatusBarTexture(EUIDB.statusBarTex)
      powerBar:GetStatusBarTexture():SetDrawLayer("BORDER")

      self.vertLeftBorder:Hide()
      self.vertRightBorder:Hide()
      self.horizTopBorder:Hide()
      self.horizBottomBorder:Hide()
      self.background:SetTexture(SQUARE_TEXTURE)
      SetVertexColor(self.background, CreateColor(0.15, 0.15, 0.15, 0.9))

      if self.CcRemoverFrame then
        ApplyEuiBackdrop(self.CcRemoverFrame.Icon, self.CcRemoverFrame)
      end

      local debuffFrame = self.DebuffFrame
      if debuffFrame then
        if not debuffFrame.euiBorder then
          local border = ApplyEuiBackdrop(debuffFrame.Icon, debuffFrame)
          debuffFrame.euiBorder = border
        end

        if debuffFrame.Border then
          debuffFrame.Border:SetAlpha(1)
          SetEuiBorderColor(debuffFrame.euiBorder, GetVertexColor(debuffFrame.Border))
          debuffFrame.Border:SetAlpha(0)
        end
      end
    end
  end
end

hooksecurefunc("CompactUnitFrame_UpdateAll", updateTextures)

local function skinAura(self)
  local border = self.border

  local euiBorder = ApplyEuiBackdrop(self)
  if border then
    border:SetAlpha(1)
    SetEuiBorderColor(euiBorder, GetVertexColor(border))
    border:SetAlpha(0)
  end
end

hooksecurefunc("CompactUnitFrame_UtilSetBuff", skinAura)
hooksecurefunc("CompactUnitFrame_UtilSetDebuff", skinAura)

function UpdateCUFCVars()
  local classColor = EUIDB.cUFClassColoredHealth and 1 or 0
  local powerBars = EUIDB.cUFDisplayPowerBars and 1 or 0
  local healerPowerBars = EUIDB.cUFPowerBarsHealerOnly and 1 or 0

  SetCVar("raidFramesDisplayClassColor", classColor)
  SetCVar("raidFramesDisplayPowerBars", powerBars)
  SetCVar("raidFramesDisplayOnlyHealerPowerBars", healerPowerBars)

  SetCVar("pvpFramesDisplayClassColor", classColor)
  SetCVar("pvpFramesDisplayPowerBars", powerBars)
  SetCVar("pvpFramesDisplayOnlyHealerPowerBars", healerPowerBars)
end

OnPlayerLogin(function()
  UpdateCUFCVars()
end)

function UpdateAllCompactUnitFrames()
  for _, frame in pairs(compactUnitFrames) do
    updateTextures(frame)
  end
end
