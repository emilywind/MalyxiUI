OnPlayerLogin(function()
  if C_AddOns.IsAddOnLoaded('Prat-3.0') or C_AddOns.IsAddOnLoaded('BasicChatMods') then return end

  local patterns = {
    "(https://%S+%.%S+)",
    "(http://%S+%.%S+)",
    "(www%.%S+%.%S+)",
    "(%d+%.%d+%.%d+%.%d+:?%d*/?%S*)"
  }

  for _, event in next, {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_BATTLEGROUND",
    "CHAT_MSG_BATTLEGROUND_LEADER",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_CONVERSATION",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_SYSTEM"
  } do
    ChatFrame_AddMessageEventFilter(event, function(self, event, str, ...)
      for _, pattern in pairs(patterns) do
        local result, match = string.gsub(str, pattern, "|cff0394ff|Hurl:%1|h[%1]|h|r")
        if match > 0 then
          return false, result, ...
        end
      end
    end)
  end

  local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
  function _G.ItemRefTooltip:SetHyperlink(link, ...)
    if link and (strsub(link, 1, 3) == "url") then
      local editbox = ChatEdit_ChooseBoxForSend()
      ChatEdit_ActivateChat(editbox)
      editbox:Insert(string.sub(link, 5))
      editbox:HighlightText()
      return
    end

    SetHyperlink(self, link, ...)
  end

  CHAT_FRAME_FADE_TIME = 0.3
  CHAT_FRAME_FADE_OUT_TIME = 1
  CHAT_TAB_HIDE_DELAY = 0.3
  CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
  CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

  -- Set chat style
  local function SetChatStyle(frame)
    local id = frame:GetID()
    local chatName = frame:GetName()
    local chat = _G[chatName]

    chat:SetFrameLevel(5)

    -- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen
    chat:SetClampedToScreen(false)

    -- Stop the chat chat from fading out
    chat:SetFading(true)

    local editBox = _G[chatName .. "EditBox"]

    -- Move the chat edit box
    editBox:ClearAllPoints()

    if (EUIDB.chatTop) then
      editBox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -7, 25)
      editBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 10, 25)
    else
      editBox:SetPoint("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -7, -5)
      editBox:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT", 10, -5)
    end

    -- Hide textures
    for j = 1, #CHAT_FRAME_TEXTURES do
      if chatName .. CHAT_FRAME_TEXTURES[j] ~= chatName .. "Background" then
        _G[chatName .. CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
      end
    end

    -- Removes Default ChatFrame Tabs texture
    local chatFrameTab = _G[format("ChatFrame%sTab", id)]
    chatFrameTab.Left:SetTexture(nil)
    chatFrameTab.Middle:SetTexture(nil)
    chatFrameTab.Right:SetTexture(nil)

    chatFrameTab.ActiveLeft:SetTexture(nil)
    chatFrameTab.ActiveMiddle:SetTexture(nil)
    chatFrameTab.ActiveRight:SetTexture(nil)

    chatFrameTab.HighlightLeft:SetTexture(nil)
    chatFrameTab.HighlightMiddle:SetTexture(nil)
    chatFrameTab.HighlightRight:SetTexture(nil)

    -- Hiding off the new chat tab selected feature
    _G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Hide()
    _G[format("ChatFrame%sButtonFrame", id)]:Hide()

    -- Hides off the retarded new circle around the editbox
    _G[format("ChatFrame%sEditBoxLeft", id)]:Hide()
    _G[format("ChatFrame%sEditBoxMid", id)]:Hide()
    _G[format("ChatFrame%sEditBoxRight", id)]:Hide()

    _G[format("ChatFrame%sTabGlow", id)]:Hide()

    -- Hide scroll bar
    local chatFrame = _G[format("ChatFrame%s", id)]
    chatFrame.ScrollBar.Back:Hide()
    chatFrame.ScrollBar.Forward:Hide()
    chatFrame.ScrollBar:Hide()
    chatFrame.ScrollBar.Track:Hide()
    chatFrame.ScrollBar.Track.Begin:Hide()
    chatFrame.ScrollBar.Track.Middle:Hide()
    chatFrame.ScrollBar.Track.End:Hide()
    chatFrame.ScrollBar.Track.Thumb:Hide()
    chatFrame.ScrollBar.Track.Thumb.Begin:Hide()
    chatFrame.ScrollBar.Track.Thumb.Middle:Hide()
    chatFrame.ScrollBar.Track.Thumb.End:Hide()

    -- Hide off editbox artwork
    local a, b, c = select(6, editBox:GetRegions())
    if a then a:Hide() end
    if b then b:Hide() end
    if c then c:Hide() end

    -- Hide bubble tex/glow
    local chatTab = _G[chatName .. "Tab"]
    if chatTab.conversationIcon then chatTab.conversationIcon:Hide() end

    -- Disable alt key usage
    editBox:SetAltArrowKeyMode(false)

    -- Hide editbox on login
    editBox:Hide()

    -- Script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
    editBox:HookScript("OnEditFocusGained", function(self) self:Show() end)
    editBox:HookScript("OnEditFocusLost",
      function(self) if self:GetText() == "" then self:Hide() end end)

    -- Hide edit box every time we click on a tab
    chatTab:HookScript("OnClick", function() editBox:Hide() end)

    frame.skinned = true
  end

  -- Setup chatframes 1 to 10 on login
  local function SetupChat()
    for i = 1, NUM_CHAT_WINDOWS do
      local frame = _G[format("ChatFrame%s", i)]
      SetChatStyle(frame)
    end
  end

  function SetupChatPosAndFont()
    for i = 1, NUM_CHAT_WINDOWS do
      local chat = _G[format("ChatFrame%s", i)]
      local id = chat:GetID()
      local fontSize = EUIDB.chatFontSize

      -- Min. size for chat font
      if fontSize < 11 then
        FCF_SetChatWindowFontSize(nil, chat, 11)
      else
        FCF_SetChatWindowFontSize(nil, chat, fontSize)
      end

      chat:SetFont(EUIDB.chatFont, fontSize, "")
    end
  end

  -- Setup temp chat (BN, WHISPER) when needed
  local function SetupTempChat()
    local frame = FCF_GetCurrentChatFrame()
    if frame.skinned then return end
    SetChatStyle(frame)
  end

  hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

  -- init
  SetupChat()
  SetupChatPosAndFont()

  -- Hide quick Join
  QuickJoinToastButton:Hide()
  QuickJoinToastButton.Show = function() end
end)
