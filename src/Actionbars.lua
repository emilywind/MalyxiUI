---@param bu Button
local function styleActionButton(bu)
  if not bu then return end

  local name = bu:GetName()
  local na = _G[name .. "Name"]

  if EUIDB.hideMacroText and na then
    na:Hide()
  elseif na and not na:IsShown() then
    na:Show()
  end

  local nt = bu:GetNormalTexture()

  if not nt then return end

  ApplyUIMode(nt)
end

---@param self Button
local function updateHotkey(self)
  local ho = _G[self:GetName() .. "HotKey"]
  local text = ho:GetText()

  if EUIDB.hideHotkeys and ho:IsShown() then
    ho:Hide()
  elseif not EUIDB.hideHotkeys and not ho:IsShown() and text and text ~= "●" then
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

---@param func fun(button: Button)
---@param allButtons? boolean
function DoToActionButtons(func, allButtons)
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

  if not allButtons then return end

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

local function updateHotkeys()
  DoToActionButtons(updateHotkey, true)
end

function StyleActionBars()
  DoToActionButtons(styleActionButton, true)

  updateHotkeys()
end

OnEvents({
  "PLAYER_LOGIN",
  "PLAYER_SPECIALIZATION_CHANGED",
  "EDIT_MODE_LAYOUTS_UPDATED"
}, function(_, event)
  if event == "PLAYER_LOGIN" then
    OnEvent("UPDATE_BINDINGS", updateHotkeys)

    SpellFlyout:HookScript("OnSizeChanged", skinSpellFlyout)
  end

  StyleActionBars()
end)
