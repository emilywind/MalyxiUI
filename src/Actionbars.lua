local function applyEuiButtonSkin(bu)
  if EUIDB.uiMode == 'blizzard' then return end

  if not bu then return end
  if bu.euiClean then return bu.border end

  local nt = bu:GetNormalTexture()

  if not nt then return end

  BlackenTexture(nt)

  bu.euiClean = true
end

local function init()
  --style extraactionbutton
  local function styleExtraActionButton(bu)
    if not bu or (bu and bu.euiClean) then return end

    local icon = bu.icon or bu.Icon

    --icon
    StyleIcon(icon)

    --apply background
    applyEuiButtonSkin(bu)
  end

  --initial style func
  local function styleActionButton(bu)
    if not bu or (bu and bu.euiClean) then
      return
    end
    local name = bu:GetName()
    local na = _G[name .. "Name"]
    local nt = _G[name .. "NormalTexture"]

    -- Macro name
    if EUIDB.hideMacroText then
      na:Hide()
    end

    if not nt then
      --fix the non existent texture problem (no clue what is causing this)
      nt = bu:GetNormalTexture()
    end

    applyEuiButtonSkin(bu)
  end

  -- Style stance buttons
  for i = 1, StanceBar.numButtons do
    styleActionButton(_G["StanceButton" .. i])
  end

  -- Style possess buttons
  local function stylePossessButton(bu)
    if not bu or (bu and bu.euiClean) then
      return
    end
    local name = bu:GetName()
    local nt = _G[name .. "NormalTexture"]
    nt:SetAllPoints(bu)

    applyEuiButtonSkin(bu)
  end

  --update hotkey func
  local function updateHotkey(self, actionButtonType)
    local ho = _G[self:GetName() .. "HotKey"]
    if ho and ho:IsShown() then
      ho:Hide()
    end
  end

  if EUIDB.hideHotkeys then
    OnEvents({
      "UPDATE_BINDINGS",
      "PLAYER_LOGIN"
    }, function()
      for i = 1, 12 do
        updateHotkey(_G["ActionButton"..i])
        updateHotkey(_G["MultiBarBottomLeftButton"..i])
        updateHotkey(_G["MultiBarBottomRightButton"..i])
        updateHotkey(_G["MultiBarLeftButton"..i])
        updateHotkey(_G["MultiBarRightButton"..i])
      end
      for i = 1, 10 do
        updateHotkey(_G["StanceButton"..i])
        updateHotkey(_G["PetActionButton"..i])
      end
      updateHotkey(ExtraActionButton1)
    end)
  end

  --style the actionbar buttons
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
  --petbar buttons
  for i = 1, NUM_PET_ACTION_SLOTS do
    styleActionButton(_G["PetActionButton" .. i])
  end
  --possess buttons
  for i = 1, NUM_POSSESS_SLOTS do
    stylePossessButton(_G["PossessButton" .. i])
  end

  --extraactionbutton1
  styleExtraActionButton(ExtraActionButton1)

  local function skinSpellFlyout()
    -- Main frame.
    for _, texture in pairs({
      SpellFlyout.Background.Start,
      SpellFlyout.Background.VerticalMiddle,
      SpellFlyout.Background.HorizontalMiddle,
      SpellFlyout.Background.End,
    }) do
      DarkenTexture(texture)
    end

    -- Button borders.
    local i = 1
    while (true) do
      local btnTexture = _G["SpellFlyoutPopupButton" .. i .. "NormalTexture"]

      if not btnTexture then
        break
      end

      DarkenTexture(btnTexture)

      i = i + 1
    end
  end

  SpellFlyout:HookScript("OnSizeChanged", function()
    skinSpellFlyout()
  end)
end

OnEvents({
  "PLAYER_LOGIN",
  "PLAYER_SPECIALIZATION_CHANGED",
  "EDIT_MODE_LAYOUTS_UPDATED"
}, init)
