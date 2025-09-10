function ApplyUIMode(texture, unit)
  local unitInfo = GetUnitInfo(unit)
  texture:SetDesaturated(EUIDB.uiMode ~= 'blizzard' or (EUIDB.classColoredUnitFrames and unitInfo.isPlayer))
  local fc = GetFrameColor(unit)
  texture:SetVertexColor(fc.r, fc.g, fc.b)
end

OnPlayerLogin(function()
  -- Minimap
  ApplyUIMode(MinimapCompassTexture)

  -- Alternate Power Bar
  for _, v in ipairs({
      PlayerFrameAlternateManaBarBorder,
      PlayerFrameAlternateManaBarLeftBorder,
      PlayerFrameAlternateManaBarRightBorder,
      PetFrameTexture
  }) do
      ApplyUIMode(v, "player")
  end

  -- Player Frame
  PlayerFrame:HookScript("OnUpdate", function()
    ApplyUIMode(PlayerFrame.PlayerFrameContainer.FrameTexture, "player")
    ApplyUIMode(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon, "player")
    ApplyUIMode(PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture, "player")
  end)

  -- Pet Frame
  PetFrame:HookScript("OnUpdate", function()
    ApplyUIMode(PetFrameTexture, "pet")
  end)

  -- Target Frame
  TargetFrame:HookScript("OnUpdate", function()
    ApplyUIMode(TargetFrame.TargetFrameContainer.FrameTexture, "target")
    ApplyUIMode(TargetFrameToT.FrameTexture, "targettarget")
  end)

  -- Focus Frame
  FocusFrame:HookScript("OnUpdate", function()
    ApplyUIMode(FocusFrame.TargetFrameContainer.FrameTexture, "focus")
    ApplyUIMode(FocusFrameToT.FrameTexture, "focustarget")
  end)

  -- Totem Bar
  TotemFrame:HookScript("OnEvent", function(self)
    for totem, _ in self.totemPool:EnumerateActive() do
      ApplyUIMode(totem.Border)
    end
  end)

  for i = 1, 5 do
    local bossFrame = _G['Boss'..i..'TargetFrame']
    bossFrame:HookScript('OnEvent', function()
      ApplyUIMode(bossFrame.TargetFrameContainer.FrameTexture, bossFrame.unit)
    end)
  end

  for i = 1, MAX_PARTY_MEMBERS do
    local frame = _G["PartyFrame"]["MemberFrame" .. i]
    if frame then
      hooksecurefunc(frame, "UpdateMember", function(self)
        ApplyUIMode(self.Texture, self.unit)
      end)
    end
  end

  -- Class Resource Bars
  local _, playerClass = UnitClass("player")

  if (playerClass == 'ROGUE') then
    -- Rogue
    hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", function()
      for bar, _ in RogueComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.BGActive)
        ApplyUIMode(bar.BGInactive)
        ApplyUIMode(bar.BGShadow)
        if (bar.isCharged) then
          ApplyUIMode(bar.ChargedFrameActive)
        end
      end

      for bar, _ in ClassNameplateBarRogueFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.BGActive)
        ApplyUIMode(bar.BGInactive)
        ApplyUIMode(bar.BGShadow)
        if (bar.isCharged) then
          ApplyUIMode(bar.ChargedFrameActive)
        end
      end
    end)
  elseif (playerClass == 'MAGE') then
    -- Mage
    hooksecurefunc(MagePowerBar, "UpdatePower", function()
      for bar, _ in MageArcaneChargesFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.ArcaneBG)
        ApplyUIMode(bar.ArcaneBGShadow)
      end

      for bar, _ in ClassNameplateBarMageFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.ArcaneBG)
        ApplyUIMode(bar.ArcaneBGShadow)
      end
    end)
  elseif (playerClass == 'WARLOCK') then
    -- Warlock
    hooksecurefunc(WarlockPowerFrame, "UpdatePower", function()
      for bar, _ in WarlockPowerFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.Background)
      end

      for bar, _ in ClassNameplateBarWarlockFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.Background)
      end
    end)
  elseif (playerClass == 'DRUID') then
    -- Druid
    hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", function()
      for bar, _ in DruidComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.BG_Active)
        ApplyUIMode(bar.BG_Inactive)
        ApplyUIMode(bar.BG_Shadow)
      end

      for bar, _ in ClassNameplateBarFeralDruidFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.BG_Active)
        ApplyUIMode(bar.BG_Inactive)
        ApplyUIMode(bar.BG_Shadow)
      end
    end)
  elseif (playerClass == 'MONK') then
    -- Monk
    hooksecurefunc(MonkHarmonyBarFrame, "UpdatePower", function()
      for bar, _ in MonkHarmonyBarFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.Chi_BG)
        ApplyUIMode(bar.Chi_BG_Active)
      end

      for bar, _ in ClassNameplateBarWindwalkerMonkFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.Chi_BG)
        ApplyUIMode(bar.Chi_BG_Active)
      end
    end)
  elseif (playerClass == 'DEATHKNIGHT') then
    -- Death Knight
    hooksecurefunc(RuneFrame, "UpdateRunes", function()
      for _, bar in ipairs({
        RuneFrame.Rune1.BG_Active,
        RuneFrame.Rune1.BG_Inactive,
        RuneFrame.Rune1.BG_Shadow,
        RuneFrame.Rune2.BG_Active,
        RuneFrame.Rune2.BG_Inactive,
        RuneFrame.Rune2.BG_Shadow,
        RuneFrame.Rune3.BG_Active,
        RuneFrame.Rune3.BG_Inactive,
        RuneFrame.Rune3.BG_Shadow,
        RuneFrame.Rune4.BG_Active,
        RuneFrame.Rune4.BG_Inactive,
        RuneFrame.Rune4.BG_Shadow,
        RuneFrame.Rune5.BG_Active,
        RuneFrame.Rune5.BG_Inactive,
        RuneFrame.Rune5.BG_Shadow,
        RuneFrame.Rune6.BG_Active,
        RuneFrame.Rune6.BG_Inactive,
        RuneFrame.Rune6.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune1.BG_Active,
        DeathKnightResourceOverlayFrame.Rune1.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune1.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune2.BG_Active,
        DeathKnightResourceOverlayFrame.Rune2.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune2.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune3.BG_Active,
        DeathKnightResourceOverlayFrame.Rune3.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune3.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune4.BG_Active,
        DeathKnightResourceOverlayFrame.Rune4.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune4.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune5.BG_Active,
        DeathKnightResourceOverlayFrame.Rune5.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune5.BG_Shadow,
        DeathKnightResourceOverlayFrame.Rune6.BG_Active,
        DeathKnightResourceOverlayFrame.Rune6.BG_Inactive,
        DeathKnightResourceOverlayFrame.Rune6.BG_Shadow
      }) do
        ApplyUIMode(bar)
      end
    end)
  elseif (playerClass == 'EVOKER') then
    -- Evoker
    hooksecurefunc(EssencePlayerFrame, "UpdatePower", function()
      for bar, _ in EssencePlayerFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.EssenceFillDone.CircBG)
        ApplyUIMode(bar.EssenceFillDone.CircBGActive)
      end

      for bar, _ in ClassNameplateBarDracthyrFrame.classResourceButtonPool:EnumerateActive() do
        ApplyUIMode(bar.EssenceFillDone.CircBG)
        ApplyUIMode(bar.EssenceFillDone.CircBGActive)
      end
    end)
  elseif (playerClass == 'PALADIN') then
    -- Paladin
    hooksecurefunc(PaladinPowerBar, "UpdatePower", function()
      ApplyUIMode(PaladinPowerBarFrame.Background)
      PaladinPowerBarFrame.ActiveTexture:Hide()
      ApplyUIMode(ClassNameplateBarPaladinFrame.Background)
      ClassNameplateBarPaladinFrame.ActiveTexture:Hide()
    end)
  end
end)
