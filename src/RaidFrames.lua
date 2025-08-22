---------------------
-- Skinning Frames --
---------------------
local function updateTextures(self)
  if self:IsForbidden() then return end
  if self and self:GetName() then
    local name = self:GetName()
    if name and name:match("^Compact") then
      if self:IsForbidden() then return end

      local healthTex = EUIDB.healthBarTex
      local powerTex = EUIDB.powerBarTex

      self.healthBar:SetStatusBarTexture(healthTex)
      self.healthBar:GetStatusBarTexture():SetDrawLayer("BORDER")
      self.powerBar:SetStatusBarTexture(powerTex)
      self.powerBar:GetStatusBarTexture():SetDrawLayer("BORDER")
      self.myHealPrediction:SetTexture(healthTex)
      self.otherHealPrediction:SetTexture(healthTex)

      self.vertLeftBorder:Hide()
      self.vertRightBorder:Hide()
      self.horizTopBorder:Hide()
      self.horizBottomBorder:Hide()
      self.background:SetTexture(SQUARE_TEXTURE)
      self.background:SetVertexColor(0.15, 0.15, 0.15, 0.9)

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
          SetEuiBorderColor(debuffFrame.euiBorder, debuffFrame.Border:GetVertexColor())
          debuffFrame.Border:SetAlpha(0)
        end
      end
    end
  end
end

hooksecurefunc("CompactUnitFrame_UpdateAll", updateTextures)

local function skinAura(self)
  local border = self.border
  if border then
    border:GetVertexColor()
  end

  local euiBorder = ApplyEuiBackdrop(self)
  if border then
    border:SetAlpha(1)
    SetEuiBorderColor(euiBorder, border:GetVertexColor())
    border:SetAlpha(0)
  end
end

hooksecurefunc("CompactUnitFrame_UtilSetBuff", skinAura)
hooksecurefunc("CompactUnitFrame_UtilSetDebuff", skinAura)
