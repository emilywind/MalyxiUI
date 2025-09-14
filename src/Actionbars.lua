local function applyEuiButtonSkin(bu)
  if not bu then return end

  local nt = bu:GetNormalTexture()

  if not nt then return end

  ApplyUIMode(nt)

  return bu.border
end

local function styleExtraActionButton(bu)
  if not bu then return end

  local icon = bu.icon or bu.Icon

  StyleIcon(icon)

  applyEuiButtonSkin(bu)
end

local function styleActionButton(bu)
  if not bu then return end

  local name = bu:GetName()
  local na = _G[name .. "Name"]
  local nt = _G[name .. "NormalTexture"]

  if EUIDB.hideMacroText then
    na:Hide()
  end

  if not nt then
    nt = bu:GetNormalTexture()
  end

  applyEuiButtonSkin(bu)
end

local function stylePossessButton(bu)
  if not bu then return end

  local name = bu:GetName()
  local nt = _G[name .. "NormalTexture"]
  nt:SetAllPoints(bu)

  applyEuiButtonSkin(bu)
end

local function updateHotkey(self)
  local ho = _G[self:GetName() .. "HotKey"]
  if ho and ho:IsShown() then
    ho:Hide()
  end
end

local function skinSpellFlyout()
  for _, texture in pairs({
    SpellFlyout.Background.Start,
    SpellFlyout.Background.VerticalMiddle,
    SpellFlyout.Background.HorizontalMiddle,
    SpellFlyout.Background.End,
  }) do
    ApplyUIMode(texture)
  end

  local i = 1
  while (true) do
    local btnTexture = _G["SpellFlyoutPopupButton" .. i .. "NormalTexture"]

    if not btnTexture then
      break
    end

    ApplyUIMode(btnTexture)

    i = i + 1
  end
end

local function hideHotKeys()
  for i = 1, 12 do
    updateHotkey(_G["ActionButton" .. i])
    updateHotkey(_G["MultiBarBottomLeftButton" .. i])
    updateHotkey(_G["MultiBarBottomRightButton" .. i])
    updateHotkey(_G["MultiBarLeftButton" .. i])
    updateHotkey(_G["MultiBarRightButton" .. i])
  end
  for i = 1, 10 do
    updateHotkey(_G["StanceButton" .. i])
    updateHotkey(_G["PetActionButton" .. i])
  end
  updateHotkey(ExtraActionButton1)
end

local function applyHooks()
  if EUIDB.hideHotkeys then
    OnEvent("UPDATE_BINDINGS", hideHotKeys)

    hideHotKeys()
  end

  SpellFlyout:HookScript("OnSizeChanged", function()
    skinSpellFlyout()
  end)
end

function StyleActionBars()
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    styleActionButton(_G["ActionButton" .. i])
    styleActionButton(_G["MultiBarBottomLeftButton" .. i])
    styleActionButton(_G["MultiBarBottomRightButton" .. i])
    styleActionButton(_G["MultiBarRightButton" .. i])
    for k = 5, 7 do
      styleActionButton(_G["MultiBar" .. k .. "Button" .. i])
    end
    styleActionButton(_G["MultiBarLeftButton" .. i])
  end

  for i = 1, 6 do
    styleActionButton(_G["OverrideActionBarButton" .. i])
  end
  for i = 1, NUM_PET_ACTION_SLOTS do
    styleActionButton(_G["PetActionButton" .. i])
  end
  for i = 1, NUM_POSSESS_SLOTS do
    stylePossessButton(_G["PossessButton" .. i])
  end

  styleExtraActionButton(ExtraActionButton1)

  for i = 1, StanceBar.numButtons do
    styleActionButton(_G["StanceButton" .. i])
  end
end

OnEvents({
  "PLAYER_LOGIN",
  "PLAYER_SPECIALIZATION_CHANGED",
  "EDIT_MODE_LAYOUTS_UPDATED"
}, function(_, event)
  if event == "PLAYER_LOGIN" then
    applyHooks()
  end

  StyleActionBars()
end)
