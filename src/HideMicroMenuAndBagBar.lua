function SetMicroMenuVisibility()
    local micromenuVisible = not EUIDB.hideMicroMenu
    for _, button in pairs({
        CharacterMicroButton, SpellbookMicroButton, TalentMicroButton,
        QuestLogMicroButton, GuildMicroButton, LFDMicroButton,
        EJMicroButton, StoreMicroButton, MainMenuMicroButton,
        CollectionsMicroButton, HelpMicroButton, AchievementMicroButton
    }) do
        button:SetShown(micromenuVisible)
    end

    StoreMicroButton:SetShown(micromenuVisible)
    StoreMicroButton:GetParent():SetShown(micromenuVisible)
end

function SetBagBarVisibility()
    local bagsVisible = not EUIDB.hideBagBar
    MainMenuBarBackpackButton:SetShown(bagsVisible)
    BagBarExpandToggle:SetShown(bagsVisible)
    for i = 0, 3 do
      local bagButton =_G['CharacterBag' .. i .. 'Slot']
      -- Bag buttons have a strange interaction that causes them to show when hovering over NPCs unless done this way
      if not bagsVisible then
        bagButton:SetAlpha(0)
        bagButton:GetParent():SetAlpha(0)
        RegisterStateDriver(bagButton, "visibility", "hide")
      else
        bagButton:GetParent():SetAlpha(1)
        bagButton:SetAlpha(1)
        RegisterStateDriver(bagButton, "visibility", "show")
      end
    end
    CharacterReagentBag0Slot:SetShown(bagsVisible)
end

OnEvents({
  "PLAYER_LOGIN",
  "EDIT_MODE_LAYOUTS_UPDATED"
}, function()
  SetMicroMenuVisibility()
  SetBagBarVisibility()
end)
