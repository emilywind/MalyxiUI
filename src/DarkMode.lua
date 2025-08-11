OnPlayerLogin(function()
  if not EUIDB.darkMode then return end

  -- Minimap
  local compass = MinimapCompassTexture
  compass:SetDesaturated(true)
  compass:SetVertexColor(GetFrameColour())

  -- Alternate Power Bar
  for i, v in ipairs({
      PlayerFrameAlternateManaBarBorder,
      PlayerFrameAlternateManaBarLeftBorder,
      PlayerFrameAlternateManaBarRightBorder,
      PetFrameTexture
  }) do
      v:SetDesaturated(true)
      v:SetVertexColor(GetFrameColour())
  end

  -- Player Frame
  PlayerFrame:HookScript("OnUpdate", function()
      PlayerFrame.PlayerFrameContainer.FrameTexture:SetDesaturated(true)
      PlayerFrame.PlayerFrameContainer.FrameTexture:SetVertexColor(GetFrameColour())
      PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetVertexColor(GetFrameColour())
      PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture:SetVertexColor(GetFrameColour())
  end)

  -- Pet Frame
  PetFrame:HookScript("OnUpdate", function()
    PetFrameTexture:SetDesaturated(true)
    PetFrameTexture:SetVertexColor(GetFrameColour())
  end)

  -- Target Frame
  TargetFrame:HookScript("OnUpdate", function()
    local targetFrame = TargetFrame.TargetFrameContainer.FrameTexture
    targetFrame:SetDesaturated(true)
    targetFrame:SetVertexColor(GetFrameColour())

    local totFrame = TargetFrameToT.FrameTexture
    totFrame:SetDesaturated(true)
    totFrame:SetVertexColor(GetFrameColour())
  end)

  -- Focus Frame
  FocusFrame:HookScript("OnUpdate", function()
    local focusTexture = FocusFrame.TargetFrameContainer.FrameTexture
    focusTexture:SetDesaturated(true)
    focusTexture:SetVertexColor(GetFrameColour())

    local focusToTTexture = FocusFrameToT.FrameTexture
    focusToTTexture:SetDesaturated(true)
    focusToTTexture:SetVertexColor(GetFrameColour())
  end)

  -- Totem Bar
  TotemFrame:HookScript("OnEvent", function(self)
    for totem, _ in self.totemPool:EnumerateActive() do
      totem.Border:SetDesaturated(true)
      totem.Border:SetVertexColor(GetFrameColour())
    end
  end)

  for i = 1, 5 do
    local bossFrame = _G['Boss'..i..'TargetFrame']
    bossFrame:HookScript('OnEvent', function()
      local bossTexture = bossFrame.TargetFrameContainer.FrameTexture
      bossTexture:SetDesaturated(true)
      bossTexture:SetVertexColor(GetFrameColour())
    end)
  end

  -- Class Resource Bars
  local _, playerClass = UnitClass("player")

  if (playerClass == 'ROGUE') then
    -- Rogue
    hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", function()
      for bar, _ in RogueComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        bar.BGActive:SetDesaturated(true)
        bar.BGActive:SetVertexColor(GetFrameColour())
        bar.BGInactive:SetDesaturated(true)
        bar.BGInactive:SetVertexColor(GetFrameColour())
        bar.BGShadow:SetDesaturated(true)
        bar.BGShadow:SetVertexColor(GetFrameColour())
        if (bar.isCharged) then
          bar.ChargedFrameActive:SetDesaturated(true)
          bar.ChargedFrameActive:SetVertexColor(GetFrameColour())
        end
      end

      for bar, _ in ClassNameplateBarRogueFrame.classResourceButtonPool:EnumerateActive() do
        bar.BGActive:SetDesaturated(true)
        bar.BGActive:SetVertexColor(GetFrameColour())
        bar.BGInactive:SetDesaturated(true)
        bar.BGInactive:SetVertexColor(GetFrameColour())
        bar.BGShadow:SetDesaturated(true)
        bar.BGShadow:SetVertexColor(GetFrameColour())
        if (bar.isCharged) then
          bar.ChargedFrameActive:SetDesaturated(true)
          bar.ChargedFrameActive:SetVertexColor(GetFrameColour())
        end
      end
    end)
  elseif (playerClass == 'MAGE') then
    -- Mage
    hooksecurefunc(MagePowerBar, "UpdatePower", function()
      for bar, _ in MageArcaneChargesFrame.classResourceButtonPool:EnumerateActive() do
        bar.ArcaneBG:SetVertexColor(GetFrameColour())
        bar.ArcaneBGShadow:SetVertexColor(GetFrameColour())
      end

      for bar, _ in ClassNameplateBarMageFrame.classResourceButtonPool:EnumerateActive() do
        bar.ArcaneBG:SetVertexColor(GetFrameColour())
        bar.ArcaneBGShadow:SetVertexColor(GetFrameColour())
      end
    end)
  elseif (playerClass == 'WARLOCK') then
    -- Warlock
    hooksecurefunc(WarlockPowerFrame, "UpdatePower", function()
      for bar, _ in WarlockPowerFrame.classResourceButtonPool:EnumerateActive() do
        bar.Background:SetVertexColor(GetFrameColour())
      end

      for bar, _ in ClassNameplateBarWarlockFrame.classResourceButtonPool:EnumerateActive() do
        bar.Background:SetVertexColor(GetFrameColour())
      end
    end)
  elseif (playerClass == 'DRUID') then
    -- Druid
    hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", function()
      for bar, _ in DruidComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        bar.BG_Active:SetVertexColor(GetFrameColour())
        bar.BG_Inactive:SetVertexColor(GetFrameColour())
        bar.BG_Shadow:SetVertexColor(GetFrameColour())
      end

      for bar, _ in ClassNameplateBarFeralDruidFrame.classResourceButtonPool:EnumerateActive() do
        bar.BG_Active:SetVertexColor(GetFrameColour())
        bar.BG_Inactive:SetVertexColor(GetFrameColour())
        bar.BG_Shadow:SetVertexColor(GetFrameColour())
      end
    end)
  elseif (playerClass == 'MONK') then
    -- Monk
    hooksecurefunc(MonkHarmonyBarFrame, "UpdatePower", function()
      for bar, _ in MonkHarmonyBarFrame.classResourceButtonPool:EnumerateActive() do
        bar.Chi_BG:SetDesaturated(true)
        bar.Chi_BG:SetVertexColor(GetFrameColour())
        bar.Chi_BG_Active:SetDesaturated(true)
        bar.Chi_BG_Active:SetVertexColor(GetFrameColour())
      end

      for bar, _ in ClassNameplateBarWindwalkerMonkFrame.classResourceButtonPool:EnumerateActive() do
        bar.Chi_BG:SetDesaturated(true)
        bar.Chi_BG:SetVertexColor(GetFrameColour())
        bar.Chi_BG_Active:SetDesaturated(true)
        bar.Chi_BG_Active:SetVertexColor(GetFrameColour())
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
        bar:SetDesaturated(true)
        bar:SetVertexColor(GetFrameColour())
      end
    end)
  elseif (playerClass == 'EVOKER') then
    -- Evoker
    hooksecurefunc(EssencePlayerFrame, "UpdatePower", function()
      for bar, _ in EssencePlayerFrame.classResourceButtonPool:EnumerateActive() do
        bar.EssenceFillDone.CircBG:SetDesaturated(true)
        bar.EssenceFillDone.CircBG:SetVertexColor(GetFrameColour())
        bar.EssenceFillDone.CircBGActive:SetDesaturated(true)
        bar.EssenceFillDone.CircBGActive:SetVertexColor(GetFrameColour())
      end

      for bar, _ in ClassNameplateBarDracthyrFrame.classResourceButtonPool:EnumerateActive() do
        bar.EssenceFillDone.CircBG:SetDesaturated(true)
        bar.EssenceFillDone.CircBG:SetVertexColor(GetFrameColour())
        bar.EssenceFillDone.CircBGActive:SetDesaturated(true)
        bar.EssenceFillDone.CircBGActive:SetVertexColor(GetFrameColour())
      end
    end)
  elseif (playerClass == 'PALADIN') then
    -- Paladin
    hooksecurefunc(PaladinPowerBar, "UpdatePower", function()
      PaladinPowerBarFrame.Background:SetDesaturated(true)
      PaladinPowerBarFrame.Background:SetVertexColor(GetFrameColour())
      PaladinPowerBarFrame.ActiveTexture:Hide()
      ClassNameplateBarPaladinFrame.Background:SetDesaturated(true)
      ClassNameplateBarPaladinFrame.Background:SetVertexColor(GetFrameColour())
      ClassNameplateBarPaladinFrame.ActiveTexture:Hide()
    end)
  end
end)
