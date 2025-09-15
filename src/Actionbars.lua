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

  if EUIDB.hideMacroText and na then
    na:Hide()
  elseif na and not na:IsShown() then
    na:Show()
  end

  if not nt then
    nt = bu:GetNormalTexture()
  end

  applyEuiButtonSkin(bu)
end

local function updateHotkey(self)
  local ho = _G[self:GetName() .. "HotKey"]
  if not ho then return end

  if EUIDB.hideHotkeys and ho:IsShown() then
    ho:Hide()
  elseif not EUIDB.hideHotkeys and not ho:IsShown() then
    ho:Show()
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

local function doToActionButtons(func)
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    func(_G["ActionButton" .. i])
    func(_G["MultiBarBottomLeftButton" .. i])
    func(_G["MultiBarBottomRightButton" .. i])
    func(_G["MultiBarLeftButton" .. i])
    func(_G["MultiBarRightButton" .. i])
    for k = 5, 7 do
      func(_G["MultiBar" .. k .. "Button" .. i])
    end
  end

  for i = 1, 6 do
    func(_G["OverrideActionBarButton" .. i])
  end

  for i = 1, StanceBar.numButtons do
    func(_G["StanceButton" .. i])
  end

  for i = 1, NUM_PET_ACTION_SLOTS do
    func(_G["PetActionButton" .. i])
  end

  for i = 1, NUM_POSSESS_SLOTS do
    func(_G["PossessButton" .. i])
  end

  func(ExtraActionButton1)
end

local function toggleHotKeys()
  doToActionButtons(updateHotkey)
end

local function applyHooks()
  OnEvent("UPDATE_BINDINGS", toggleHotKeys)

  SpellFlyout:HookScript("OnSizeChanged", function()
    skinSpellFlyout()
  end)
end

function StyleActionBars()
  doToActionButtons(styleActionButton)

  styleExtraActionButton(ExtraActionButton1)

  toggleHotKeys()
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
