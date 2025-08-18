function DarkenTexture(texture)
  if EUIDB.uiMode == 'blizzard' then return end

  texture:SetDesaturated(true)
  texture:SetVertexColor(GetFrameColour())
end

function BlackenTexture(texture)
  if EUIDB.uiMode == 'blizzard' then return end

  texture:SetDesaturated(true)

  if EUIDB.uiMode == 'black' then
    texture:SetVertexColor(0, 0, 0)
  elseif EUIDB.uiMode == 'dark' then
    texture:SetVertexColor(0.3, 0.3, 0.3)
  else
    texture:SetVertexColor(0.8, 0.8, 0.8)
  end
end

OnPlayerLogin(function()
  if EUIDB.uiMode == 'blizzard' then return end

  -- Minimap
  DarkenTexture(MinimapCompassTexture)

  -- Alternate Power Bar
  for _, v in ipairs({
      PlayerFrameAlternateManaBarBorder,
      PlayerFrameAlternateManaBarLeftBorder,
      PlayerFrameAlternateManaBarRightBorder,
      PetFrameTexture
  }) do
      BlackenTexture(v)
  end

  -- Player Frame
  PlayerFrame:HookScript("OnUpdate", function()
    BlackenTexture(PlayerFrame.PlayerFrameContainer.FrameTexture)
    BlackenTexture(PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon)
    BlackenTexture(PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture)
  end)

  -- Pet Frame
  PetFrame:HookScript("OnUpdate", function()
    BlackenTexture(PetFrameTexture)
  end)

  -- Target Frame
  TargetFrame:HookScript("OnUpdate", function()
    BlackenTexture(TargetFrame.TargetFrameContainer.FrameTexture)
    BlackenTexture(TargetFrameToT.FrameTexture)
  end)

  -- Focus Frame
  FocusFrame:HookScript("OnUpdate", function()
    BlackenTexture(FocusFrame.TargetFrameContainer.FrameTexture)
    BlackenTexture(FocusFrameToT.FrameTexture)
  end)

  -- Totem Bar
  TotemFrame:HookScript("OnEvent", function(self)
    for totem, _ in self.totemPool:EnumerateActive() do
      BlackenTexture(totem.Border)
    end
  end)

  for i = 1, 5 do
    local bossFrame = _G['Boss'..i..'TargetFrame']
    bossFrame:HookScript('OnEvent', function()
      BlackenTexture(bossFrame.TargetFrameContainer.FrameTexture)
    end)
  end

  -- Class Resource Bars
  local _, playerClass = UnitClass("player")

  if (playerClass == 'ROGUE') then
    -- Rogue
    hooksecurefunc(RogueComboPointBarFrame, "UpdatePower", function()
      for bar, _ in RogueComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.BGActive)
        BlackenTexture(bar.BGInactive)
        BlackenTexture(bar.BGShadow)
        if (bar.isCharged) then
          BlackenTexture(bar.ChargedFrameActive)
        end
      end

      for bar, _ in ClassNameplateBarRogueFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.BGActive)
        BlackenTexture(bar.BGInactive)
        BlackenTexture(bar.BGShadow)
        if (bar.isCharged) then
          BlackenTexture(bar.ChargedFrameActive)
        end
      end
    end)
  elseif (playerClass == 'MAGE') then
    -- Mage
    hooksecurefunc(MagePowerBar, "UpdatePower", function()
      for bar, _ in MageArcaneChargesFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.ArcaneBG)
        BlackenTexture(bar.ArcaneBGShadow)
      end

      for bar, _ in ClassNameplateBarMageFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.ArcaneBG)
        BlackenTexture(bar.ArcaneBGShadow)
      end
    end)
  elseif (playerClass == 'WARLOCK') then
    -- Warlock
    hooksecurefunc(WarlockPowerFrame, "UpdatePower", function()
      for bar, _ in WarlockPowerFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.Background)
      end

      for bar, _ in ClassNameplateBarWarlockFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.Background)
      end
    end)
  elseif (playerClass == 'DRUID') then
    -- Druid
    hooksecurefunc(DruidComboPointBarFrame, "UpdatePower", function()
      for bar, _ in DruidComboPointBarFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.BG_Active)
        BlackenTexture(bar.BG_Inactive)
        BlackenTexture(bar.BG_Shadow)
      end

      for bar, _ in ClassNameplateBarFeralDruidFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.BG_Active)
        BlackenTexture(bar.BG_Inactive)
        BlackenTexture(bar.BG_Shadow)
      end
    end)
  elseif (playerClass == 'MONK') then
    -- Monk
    hooksecurefunc(MonkHarmonyBarFrame, "UpdatePower", function()
      for bar, _ in MonkHarmonyBarFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.Chi_BG)
        BlackenTexture(bar.Chi_BG_Active)
      end

      for bar, _ in ClassNameplateBarWindwalkerMonkFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.Chi_BG)
        BlackenTexture(bar.Chi_BG_Active)
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
        BlackenTexture(bar)
      end
    end)
  elseif (playerClass == 'EVOKER') then
    -- Evoker
    hooksecurefunc(EssencePlayerFrame, "UpdatePower", function()
      for bar, _ in EssencePlayerFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.EssenceFillDone.CircBG)
        BlackenTexture(bar.EssenceFillDone.CircBGActive)
      end

      for bar, _ in ClassNameplateBarDracthyrFrame.classResourceButtonPool:EnumerateActive() do
        BlackenTexture(bar.EssenceFillDone.CircBG)
        BlackenTexture(bar.EssenceFillDone.CircBGActive)
      end
    end)
  elseif (playerClass == 'PALADIN') then
    -- Paladin
    hooksecurefunc(PaladinPowerBar, "UpdatePower", function()
      BlackenTexture(PaladinPowerBarFrame.Background)
      PaladinPowerBarFrame.ActiveTexture:Hide()
      BlackenTexture(ClassNameplateBarPaladinFrame.Background)
      ClassNameplateBarPaladinFrame.ActiveTexture:Hide()
    end)
  end
end)
