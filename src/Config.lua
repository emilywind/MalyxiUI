local LSM = LibStub("LibSharedMedia-3.0")

local name, EUI = ...
EUIDBDefaults = {
  uiMode = 'dark', -- 'dark', 'light', 'black', or 'blizzard'
  classColoredUnitFrames = false,
  cUFClassColoredHealth = true,
  cUFDisplayPowerBars = true,
  cUFPowerBarsHealerOnly = true,

  hideHotkeys = false,
  hideMacroText = false,
  arenaNumbers = false,
  hideMicroMenu = false,
  hideBagBar = false,
  hideArenaFrames = false,

  healthBarTex = EUI_TEXTURES.healthBar,
  powerBarTex = EUI_TEXTURES.powerBar,

  frameColor = DEFAULT_FRAME_COLOUR,

  lootSpecDisplay = true, -- Display loot spec icon in the player frame

  enableFont = true,       -- Update all fonts to something cooler
  font = EUI_FONTS.Andika,
  enableDamageFont = true, -- Change damage font to something cooler
  damageFont = EUI_FONTS.Bangers,

  -- Tooltip Settings
  enhanceTooltips = true, -- Enhance tooltips with additional information
  tooltipAnchor = "ANCHOR_CURSOR_LEFT", -- Anchor tooltips to cursor out of combat
  tooltipClassColoredName = true, -- Class coloured names in tooltips
  tooltipSpecAndIlvl = true, -- Show spec and item level in player tooltips
  tooltipShowMount = true, -- Show mount information in tooltips
  tooltipShowMythicPlus = true, -- Show Mythic+ information in tooltips
  tooltipHideHealthBar = false, -- Hide the health bar in tooltips

  -- Nameplate Settings
  skinNameplates = true,
  nameplateFont = EUI_FONTS.Andika,
  nameplateNameFontSize = 16,
  nameplateHideServerNames = true,
  nameplateNameLength = 20,
  nameplateFriendlyNamesClassColor = true,
  nameplateFriendlySmall = true,
  nameplateHideCastText = false,
  nameplateShowLevel = true,
  nameplateHealthPercent = true,
  nameplateTotems = true,
  nameplateHideClassificationIcon = true,
  nameplateHideFriendlyHealthbars = true,
  nameplateFriendlyClickthrough = true,
  nameplateCastbarColorInterrupt = true,
  nameplateResourceOnTarget = true,
  largerNameplates = true,
  showAllNameplates = true,
  nameplateShowFriends = true,
  nameplateShowEnemyMinions = true,

  partyMarker = true,
  partyMarkerScale = 1,
  partyMarkerHealer = true,
  partyMarkerHideRaidmarker = true,

  portraitStyle = "3D", -- 3D, 2D, or class (for class icons)
  classPortraitPack = EUI_TEXTURES.classCircles,

  -- PvP Settings
  tabBinder = true,
  dampeningDisplay = true,
  hideObjectiveTracker = true,

  -- Castbar Settings
  castBarScale = 1, -- Scale of the castbars for Target/Focus/Arena

  queueicon = {
    point = 'BOTTOMRIGHT',
    x = -330,
    y = 5,
  },

  enableStatsFrame = false,
  enableStatsSpeed = false,
  statsframe = {
    point = 'BOTTOMLEFT',
    x = 5,
    y = 3
  },

  -- Automation
  autoRepair = 'Personal', -- 'Off', 'Guild', or 'Personal'
  autoSellGrey = true,

  chatTop = false, -- Move chat edit box to top of chat frame
  chatFont = EUI_FONTS.Andika,
  chatFontSize = 14,
}

local function copyTable(src, dst)
  if type(src) ~= "table" then return {} end
  if type(dst) ~= "table" then dst = {} end

  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = copyTable(v, dst[k])
    elseif type(v) ~= type(dst[k]) then
      dst[k] = v
    end
  end

  return dst
end

OnPlayerLogin(function()
  EUIDB = copyTable(EUIDBDefaults, EUIDB)
end)

local function tableToWowDropdown(table)
  local wowTable = {}
  for k, v in pairs(table) do
    wowTable[v] = k
  end

  return wowTable
end

local makePanel = function(frameName, mainpanel, panelName)
  local panel = CreateFrame("Frame", frameName, mainpanel)
  panel.name, panel.parent = panelName, name
  local category = Settings.GetCategory("EmsUI")
  Settings.RegisterCanvasLayoutSubcategory(category, panel, panelName)

  return panel
end

local function openEuiConfig()
  Settings.OpenToCategory('EmsUI')
end

local function setupEuiOptions()
  LSM_STATUSBAR = tableToWowDropdown(LSM:HashTable('statusbar'))
  LSM_FONTS = tableToWowDropdown(LSM:HashTable('font'))
  -- Creation of the options menu
  EUI.panel = CreateFrame( "Frame", "euiPanel", UIParent )
  EUI.panel.name = "EmsUI";
  local category = Settings.RegisterCanvasLayoutCategory(EUI.panel, "Em's UI")
  category.ID = "EmsUI"
  Settings.RegisterAddOnCategory(category)

  local function newCheckbox(label, description, initialValue, onChange, relativeEl, frame, point1, point2, x, y)
    if ( not frame ) then
      frame = EUI.panel
    end

    local check = CreateFrame("CheckButton", "EUICheck" .. label, frame, "ChatConfigCheckButtonTemplate")
    check:SetScript("OnClick", function(self)
      local tick = self:GetChecked()
      onChange(tick and true or false)
      if tick then
        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
      else
        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
      end
    end)
    check.label = _G[check:GetName() .. "Text"]
    check.label:SetText(label)
    check.tooltip = description
    check:SetChecked(initialValue)
    if (relativeEl) then
      check:SetPoint(point1 or "TOPLEFT", relativeEl, point2 or "BOTTOMLEFT", x or 0, y or -8)
    else
      check:SetPoint("TOPLEFT", 16, -16)
    end

    return check
  end

  local function newDropdown(label, options, initialValue, width, onChange, frame)
    if not frame then
      frame = EUI.panel
    end
    local dropdownText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownText:SetText(label)

    local dropdown = CreateFrame("Frame", "EUIDropdown" .. label, frame, "UIDropdownMenuTemplate")
    dropdown.disabled = false
    _G[dropdown:GetName() .. "Middle"]:SetWidth(width)
    dropdown:SetPoint("TOPLEFT", dropdownText, "BOTTOMLEFT", 0, -8)
    local displayText = _G[dropdown:GetName() .. "Text"]
    displayText:SetText(options[initialValue])

    dropdown.initialize = function()
      local selected, info = displayText:GetText(), {}
      info.func = function(v)
        displayText:SetText(v:GetText())
        onChange(v.value)
      end
      for value, key in pairs(options) do
        info.text = key
        info.value = value
        info.checked = info.text == selected

        info.disabled = dropdown.disabled

        UIDropDownMenu_AddButton(info)
      end
    end

    dropdown.Disable = function()
      dropdown.disabled = true
    end

    dropdown.Enable = function()
      dropdown.disabled = false
    end

    return dropdownText, dropdown
  end

  local function newSlider(frameName, label, configVar, min, max, valueStep, tooltip, relativeEl, frame, onChanged)
    if not frame then
      frame = EUI.panel
    end

    local function onValueChanged(self, value)
      self.Text:SetFormattedText(label, value)
      EUIDB[configVar] = value
      if onChanged ~= nil and type(onChanged) == "function" then
        onChanged(value)
      end
    end
    local slider = CreateFrame("Slider", frameName, frame, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValue(EUIDB[configVar])
    slider:SetValueStep(valueStep)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(110)
    slider:SetScript("OnValueChanged", onValueChanged)
    slider.Low:SetText(min)
    slider.High:SetText(max)
    slider.Text:SetFormattedText(label, EUIDB[configVar])
    slider:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -24)

    slider:SetScript("OnEnter", function(self)
      GameTooltip:ClearLines()
      if GameTooltip:IsShown() then
          GameTooltip:Hide()
      end

      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(tooltip, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    slider:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
    end)

    -- Create Input Box on Right Click
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(50)
    editBox:SetHeight(20)
    editBox:SetMultiLine(false)
    editBox:SetPoint("CENTER", slider, "CENTER", 0, 0)
    editBox:SetFrameStrata("DIALOG")
    editBox:Hide()

    local function HandleEditBoxInput()
      local inputValue = tonumber(editBox:GetText())
      if inputValue then
        local outputValue = inputValue
        if inputValue < min then
          outputValue = min
        elseif inputValue > max then
          outputValue = max
        end

        onValueChanged(slider, outputValue)
      end
      editBox:Hide()
    end

    editBox:SetScript("OnEscapePressed", function()
      editBox:Hide()
    end)

    slider:SetScript("OnMouseDown", function(self, button)
      if button == "RightButton" then
        editBox:Show()
        editBox:SetText(string.format("%.1f", self:GetValue()))
        editBox:SetFocus()
      end
    end)

    editBox:SetScript("OnEnterPressed", HandleEditBoxInput)

    return slider
  end

  local function addReloadButton(frame)
    local reload = CreateFrame("Button", "reload", frame, "UIPanelButtonTemplate")
    reload:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    reload:SetSize(100,22)
    reload:SetText("Reload")
    reload:SetScript("OnClick", function()
      ReloadUI()
    end)
  end

  local version = C_AddOns.GetAddOnMetadata("EmsUI", "Version")

  local euiTitle = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  euiTitle:SetPoint("TOPLEFT", 16, -16)
  euiTitle:SetText("Em's UI ("..version..")")

  local uiModeChooser, uiModeDropdown = newDropdown(
    "UI Mode",
    { ["blizzard"] = "Blizzard", ["dark"] = "Dark", ["light"] = "Light", ["black"] = "Black" },
    EUIDB.uiMode,
    80,
    function(value)
      EUIDB.uiMode = value
    end
  )
  uiModeChooser:SetPoint("TOPLEFT", euiTitle, "BOTTOMLEFT", 0, -16)

  local classColoredUnitFrames = newCheckbox(
    "Class Colored Unit Frame Borders",
    "Color unit frame borders by class when units are players.",
    EUIDB.classColoredUnitFrames,
    function(value)
      EUIDB.classColoredUnitFrames = value
    end,
    uiModeDropdown,
    EUI.panel,
    "LEFT",
    "RIGHT",
    100,
    0
  )

  local portraitSelect, portraitDropdown = newDropdown(
    "Portrait Style",
    {["3D"] = "3D", ["class"] = "Class", ["default"] = "Default"},
    EUIDB.portraitStyle,
    50,
    function(value)
      EUIDB.portraitStyle = value
    end
  )
  portraitSelect:SetPoint("TOPLEFT", uiModeDropdown, "BOTTOMLEFT", 0, -16)

  local classPortraitPack = newDropdown(
    "Class Portrait Pack",
    CLASS_PORTRAIT_PACKS,
    EUIDB.classPortraitPack,
    200,
    function(value)
      EUIDB.classPortraitPack = value
    end
  )
  classPortraitPack:SetPoint("LEFT", portraitSelect, "RIGHT", 50, 0)

  local lootSpecDisplay = newCheckbox(
    "Display Loot Spec Indicator",
    "Display loot spec icon in your player portrait.",
    EUIDB.lootSpecDisplay,
    function(value)
      EUIDB.lootSpecDisplay = value
    end,
    portraitSelect
  )
  lootSpecDisplay:SetPoint("TOPLEFT", portraitDropdown, "BOTTOMLEFT", 0, -16)

  local enableFont = newCheckbox(
    "Use Custom Fonts",
    "Use custom fonts. Can be set in the dropdown to the right.",
    EUIDB.enableFont,
    function(value)
      EUIDB.enableFont = value
      UpdateFontChooser()
    end,
    lootSpecDisplay
  )

  local fontChooser, fontDropdown = newDropdown(
    "Font",
    LSM_FONTS,
    EUIDB.font,
    200,
    function(value)
      EUIDB.font = value
    end
  )
  fontChooser:SetPoint("LEFT", lootSpecDisplay, "RIGHT", 300, 0)

  function UpdateFontChooser()
    fontDropdown.disabled = not EUIDB.enableFont
  end
  UpdateFontChooser()

  local enableDamageFont = newCheckbox(
    "Use Custom Damage Font",
    "Use a custom font for damage numbers. Can be set in the dropdown to the right. Requires relogging.",
    EUIDB.enableDamageFont,
    function(value)
      EUIDB.enableDamageFont = value
      UpdateDamageFontChooser()
    end,
    enableFont
  )

  local damageFontChooser, damageFontDropdown = newDropdown(
    "Damage Font",
    LSM_FONTS,
    EUIDB.damageFont,
    200,
    function(value)
      EUIDB.damageFont = value
    end
  )
  damageFontChooser:SetPoint("LEFT", enableDamageFont, "RIGHT", 300, 0)

  function UpdateDamageFontChooser()
    damageFontDropdown.disabled = not EUIDB.enableDamageFont
  end
  UpdateDamageFontChooser()

  local pvpText = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  pvpText:SetText("PvP")
  pvpText:SetPoint("TOPLEFT", enableDamageFont, "BOTTOMLEFT", 0, -16)

  local dampeningDisplay = newCheckbox(
    "Dampening Display",
    "Display Dampening % under remaining time at the top of the screen in arenas.",
    EUIDB.dampeningDisplay,
    function(value)
      EUIDB.dampeningDisplay = value
    end,
    pvpText
  )

  local statusBarChooser = newDropdown(
    "Status Bar Texture (Raid Frames and Nameplates)",
    LSM_STATUSBAR,
    EUIDB.healthBarTex,
    200,
    function(value)
      EUIDB.healthBarTex = value
      EUIDB.powerBarTex = value -- Sync power bar texture with health bar texture
    end
  )
  statusBarChooser:SetPoint("LEFT", dampeningDisplay, "RIGHT", 300, 0)

  local tabBinder = newCheckbox(
    "Tab Binder",
    "Tab-target only between players in Arenas and BGs.",
    EUIDB.tabBinder,
    function(value)
      EUIDB.tabBinder = value
    end,
    dampeningDisplay
  )

  local hideArenaFrames = newCheckbox(
    "Hide Blizzard Arena Frames",
    "Hides the default arena frames in arenas, in favour of Gladius, sArena, or etc",
    EUIDB.hideArenaFrames,
    function(value)
      EUIDB.hideArenaFrames = value
      HideArenaFrames()
    end,
    tabBinder
  )

  local hideObjectiveTracker = newCheckbox(
    "Hide Objective Tracker in Battlegrounds",
    "Hide the Quest Objective Tracker in Battlegrounds to reduce clutter.",
    EUIDB.hideObjectiveTracker,
    function(value)
      EUIDB.hideObjectiveTracker = value
    end,
    hideArenaFrames
  )

  local miscText = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  miscText:SetText("Misc")
  miscText:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, -16)

  local castBarScale = newSlider(
    "EUI_CastbarScaleSlider",
    "Castbar Scale: %.1f",
    "castBarScale",
    1,
    2,
    0.1,
    "Set scale for Target and Focus cast bars",
    miscText
  )

  local enableStatsFrame = newCheckbox(
    "Enable Stats Frame",
    "Enable the stats frame that shows FPS, latency, and movement speed.",
    EUIDB.enableStatsFrame,
    function(value)
      EUIDB.enableStatsFrame = value
      UpdateStatsSpeed()
    end,
    castBarScale
  )

  local enableStatsSpeed = newCheckbox(
    "Show Movement Speed",
    "Show movement speed percentage in the stats frame.",
    EUIDB.enableStatsSpeed,
    function(value)
      EUIDB.enableStatsSpeed = value
    end,
    enableStatsFrame,
    EUI.panel,
    "LEFT",
    "RIGHT",
    0,
    0
  )

  enableStatsSpeed:SetPoint("LEFT", enableStatsFrame, "RIGHT", 200, 0)

  function UpdateStatsSpeed()
    if EUIDB.enableStatsFrame then
      enableStatsSpeed:Enable()
    else
      enableStatsSpeed:Disable()
    end
  end
  UpdateStatsSpeed()

  ----------------
  -- Nameplates --
  ----------------
  local EUI_Nameplates = makePanel("EUI_Nameplates", EUI.panel, "Nameplates")

  local nameplateText = EUI_Nameplates:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  nameplateText:SetText("Nameplates")
  nameplateText:SetPoint("TOPLEFT", 16, -16)

  local skinNameplates = newCheckbox(
    "Enhance Nameplates",
    "Enable the customisation options below for nameplates.",
    EUIDB.skinNameplates,
    function(value)
      EUIDB.skinNameplates = value
      if value then
        EnableNameplateSettings()
      else
        DisableNameplateSettings()
      end
    end,
    nameplateText,
    EUI_Nameplates
  )

  local nameplateFont, nameplateFontDropdown = newDropdown(
    "Nameplate Font",
    LSM_FONTS,
    EUIDB.nameplateFont,
    200,
    function(value)
      EUIDB.nameplateFont = value
    end,
    EUI_Nameplates
  )
  nameplateFont:SetPoint("TOPLEFT", skinNameplates, "BOTTOMLEFT", 0, -4)

  local nameplateFontSlider = newSlider(
    "EUI_NameplateFontSlider",
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "nameplateNameFontSize",
    6,
    24,
    1,
    "Font size for Nameplates",
    nameplateFontDropdown,
    EUI_Nameplates
  )
  nameplateFontSlider:ClearAllPoints()
  nameplateFontSlider:SetPoint("LEFT", nameplateFontDropdown, "RIGHT", 220, 0)

  local nameplateNameLength = newCheckbox(
    "Abbreviate Unit Names",
    "Abbreviate long NPC names on nameplates.",
    EUIDB.nameplateNameLength > 0,
    function(value)
      if value == true then
        EUIDB.nameplateNameLength = 20
      else
        EUIDB.nameplateNameLength = 0
      end
    end,
    nameplateFont,
    EUI_Nameplates
  )
  nameplateNameLength:SetPoint("TOPLEFT", nameplateFont, "BOTTOMLEFT", 0, -50)

  local nameplateHideServerNames = newCheckbox(
    "Hide Server Names (Must rezone to see change).",
    "Hide server names for players from different servers to reduce clutter.",
    EUIDB.nameplateHideServerNames,
    function(value)
      EUIDB.nameplateHideServerNames = value
    end,
    nameplateNameLength,
    EUI_Nameplates
  )

  local nameplateFriendlyNamesClassColor = newCheckbox(
    "Class Color Friendly Names",
    "Colors friendly players' names on their nameplates.",
    EUIDB.nameplateFriendlyNamesClassColor,
    function(value)
      EUIDB.nameplateFriendlyNamesClassColor = value
    end,
    nameplateHideServerNames,
    EUI_Nameplates
  )

  local nameplateFriendlySmall = newCheckbox(
    "Smaller Friendly Nameplates",
    "Reduce size of friendly nameplates to more easily distinguish friend from foe",
    EUIDB.nameplateFriendlySmall,
    function(value)
      EUIDB.nameplateFriendlySmall = value
      SetFriendlyNameplateSize()
    end,
    nameplateFriendlyNamesClassColor,
    EUI_Nameplates
  )

  local nameplateShowLevel = newCheckbox(
    "Show Level",
    "Show player/mob level on nameplate",
    EUIDB.nameplateShowLevel,
    function(value)
      EUIDB.nameplateShowLevel = value
    end,
    nameplateFriendlySmall,
    EUI_Nameplates
  )

  local nameplateShowHealth = newCheckbox(
    "Show Health Percentage",
    "Show percentages of health on nameplates",
    EUIDB.nameplateHealthPercent,
    function(value)
      EUIDB.nameplateHealthPercent = value
    end,
    nameplateShowLevel,
    EUI_Nameplates
  )

  local nameplateTotems = newCheckbox(
    "Show icon above Totems, Warbanner, Psyfied, and Demonic Tyrant",
    "Show icon above key NPCs",
    EUIDB.nameplateTotems,
    function(value)
      EUIDB.nameplateTotems = value
    end,
    nameplateShowHealth,
    EUI_Nameplates
  )

  local arenaNumbers = newCheckbox(
    "Show Arena Numbers on nameplates in arenas",
    "Show Arena number (i.e. 1, 2, 3 etc) on top of nameplates in arenas instead of player names to assist with macro use awareness",
    EUIDB.arenaNumbers,
    function(value)
      EUIDB.arenaNumbers = value
    end,
    nameplateTotems,
    EUI_Nameplates
  )

  local nameplateHideCastText = newCheckbox(
    "Hide Nameplate Cast Text",
    "Hide cast text from nameplate castbars.",
    EUIDB.nameplateHideCastText,
    function(value)
      EUIDB.nameplateHideCastText = value
    end,
    arenaNumbers,
    EUI_Nameplates
  )

  local nameplateHideFriendlyHealthbars = newCheckbox(
    "Hide Friendly Nameplate Health Bars",
    "Hide health bars for friendly players.",
    EUIDB.nameplateHideFriendlyHealthbars,
    function(value)
      EUIDB.nameplateHideFriendlyHealthbars = value
    end,
    nameplateHideCastText,
    EUI_Nameplates
  )

  local nameplateHideClassificationIcon = newCheckbox(
    "Hide Nameplate Classification Icon",
    "Hide the classification icon (e.g. elite, rare) on nameplates.",
    EUIDB.nameplateHideClassificationIcon,
    function(value)
      EUIDB.nameplateHideClassificationIcon = value
    end,
    nameplateHideFriendlyHealthbars,
    EUI_Nameplates
  )

  local nameplateFriendlyClickthrough = newCheckbox(
    "Friendly Nameplate Clickthrough",
    "Allow clicking through friendly nameplates to interact with objects behind them.",
    EUIDB.nameplateFriendlyClickthrough,
    function(value)
      EUIDB.nameplateFriendlyClickthrough = value
      C_NamePlate.SetNamePlateFriendlyClickThrough(value)
    end,
    nameplateHideClassificationIcon,
    EUI_Nameplates
  )

  local nameplateColorInterrupt = newCheckbox(
    "Color Castbars by Interrupt Availability",
    "Color castbars based upon interrupt availability. This allows you to track your interrupt cooldown without having to look elsewhere.",
    EUIDB.nameplateCastbarColorInterrupt,
    function(value)
      EUIDB.nameplateCastbarColorInterrupt = value
    end,
    nameplateFriendlyClickthrough,
    EUI_Nameplates
  )

  function DisableNameplateSettings()
    nameplateFontDropdown:Disable()
    nameplateFontSlider:Disable()
    nameplateNameLength:Disable()
    nameplateHideServerNames:Disable()
    nameplateFriendlyNamesClassColor:Disable()
    nameplateFriendlySmall:Disable()
    nameplateShowLevel:Disable()
    nameplateShowHealth:Disable()
    nameplateTotems:Disable()
    arenaNumbers:Disable()
    nameplateHideCastText:Disable()
    nameplateHideFriendlyHealthbars:Disable()
    nameplateHideClassificationIcon:Disable()
    nameplateFriendlyClickthrough:Disable()
    nameplateColorInterrupt:Disable()
  end

  function EnableNameplateSettings()
    nameplateFontDropdown:Enable()
    nameplateFontSlider:Enable()
    nameplateNameLength:Enable()
    nameplateHideServerNames:Enable()
    nameplateFriendlyNamesClassColor:Enable()
    nameplateFriendlySmall:Enable()
    nameplateShowLevel:Enable()
    nameplateShowHealth:Enable()
    nameplateTotems:Enable()
    arenaNumbers:Enable()
    nameplateHideCastText:Enable()
    nameplateHideFriendlyHealthbars:Enable()
    nameplateHideClassificationIcon:Enable()
    nameplateFriendlyClickthrough:Enable()
    nameplateColorInterrupt:Enable()
  end

  if C_AddOns.IsAddOnLoaded('BetterBlizzPlates') then
    DisableNameplateSettings()
    skinNameplates.tooltip = "Disabled due to addon BetterBlizzPlates"
    skinNameplates:Disable()
  elseif not EUIDB.skinNameplates then
    DisableNameplateSettings()
  else
    EnableNameplateSettings()
  end

  --------------
  -- Tooltips --
  --------------
  local EUI_Tooltips = makePanel("EUI_Tooltips", EUI.panel, "Tooltips")

  local tooltipText = EUI_Tooltips:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  tooltipText:SetText("Tooltips")
  tooltipText:SetPoint("TOPLEFT", 16, -16)

  local enhanceTooltips = newCheckbox(
    "Enhance Tooltips",
    "Enable enhanced tooltips with additional information.",
    EUIDB.enhanceTooltips,
    function(value)
      EUIDB.enhanceTooltips = value
      if value then
        EnableTooltipSettings()
      else
        DisableTooltipSettings()
      end
    end,
    tooltipText,
    EUI_Tooltips
  )
  enhanceTooltips:SetPoint("TOPLEFT", tooltipText, "BOTTOMLEFT", 0, -16)

  local tooltipAnchor, tooltipAnchorDropdown = newDropdown(
    "Cursor Anchor (anchor tooltips to cursor out of combat)",
    { ["ANCHOR_CURSOR_LEFT"] = "Bottom Right", ["ANCHOR_CURSOR_RIGHT"] = "Bottom Left", ['DEFAULT'] = 'Disabled' },
    EUIDB.tooltipAnchor,
    100,
    function(value)
      EUIDB.tooltipAnchor = value
    end,
    EUI_Tooltips
  )
  tooltipAnchor:SetPoint("TOPLEFT", enhanceTooltips, "BOTTOMLEFT", 0, -16)

  local tooltipSpecAndIlvl = newCheckbox(
    "Show Player Spec and Item Level",
    "Show item level in tooltips.",
    EUIDB.tooltipSpecAndIlvl,
    function(value)
      EUIDB.tooltipSpecAndIlvl = value
    end,
    tooltipAnchorDropdown,
    EUI_Tooltips
  )

  local showMount = newCheckbox(
    "Show Mount Information",
    "Show mount information in tooltips.",
    EUIDB.tooltipShowMount,
    function(value)
      EUIDB.tooltipShowMount = value
    end,
    tooltipSpecAndIlvl,
    EUI_Tooltips
  )

  local classColoredName = newCheckbox(
    "Class Colored Names",
    "Color player names in tooltips by class.",
    EUIDB.tooltipClassColoredName,
    function(value)
      EUIDB.tooltipClassColoredName = value
    end,
    showMount,
    EUI_Tooltips
  )

  local showMythicPlus = newCheckbox(
    "Show Mythic+ Information",
    "Show Mythic+ information in player tooltips.",
    EUIDB.tooltipShowMythicPlus,
    function(value)
      EUIDB.tooltipShowMythicPlus = value
    end,
    classColoredName,
    EUI_Tooltips
  )

  local tooltipHideHealthBar = newCheckbox(
    "Hide Health Bar",
    "Hide the health bar in tooltips.",
    EUIDB.tooltipHideHealthBar,
    function(value)
      EUIDB.tooltipHideHealthBar = value
    end,
    showMythicPlus,
    EUI_Tooltips
  )

  function DisableTooltipSettings()
    tooltipAnchorDropdown:Disable()
    tooltipSpecAndIlvl:Disable()
    showMount:Disable()
    classColoredName:Disable()
    showMythicPlus:Disable()
    tooltipHideHealthBar:Disable()
  end

  function EnableTooltipSettings()
    tooltipAnchorDropdown:Enable()
    tooltipSpecAndIlvl:Enable()
    showMount:Enable()
    classColoredName:Enable()
    showMythicPlus:Enable()
    tooltipHideHealthBar:Enable()
  end

  if
    C_AddOns.IsAddOnLoaded('TinyTooltip')
    or C_AddOns.IsAddOnLoaded('TipTac')
  then
    DisableTooltipSettings()
    enhanceTooltips.tooltip = "Disabled due to addon TinyTooltip or TipTac"
    enhanceTooltips:Disable()
  elseif not EUIDB.enhanceTooltips then
    DisableTooltipSettings()
  end

  ----------
  -- Misc --
  ----------
  local EUI_Misc = makePanel("EUI_Misc", EUI.panel, "Misc")

  local miscSectionText = EUI_Misc:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  miscSectionText:SetText("Miscellaneous")
  miscSectionText:SetPoint("TOPLEFT", 16, -16)

  local hideHotkeys = newCheckbox(
    "Hide Hotkeys on Action Bars",
    "Hides keybinding text on your action bar buttons.",
    EUIDB.hideHotkeys,
    function(value)
      EUIDB.hideHotkeys = value
    end,
    miscSectionText,
    EUI_Misc
  )

  local hideMacroText = newCheckbox(
    "Hide Macro Text on Action Bars",
    "Hides macro text on your action bar buttons.",
    EUIDB.hideMacroText,
    function(value)
      EUIDB.hideMacroText = value
    end,
    hideHotkeys,
    EUI_Misc
  )

  local hideMicroMenu = newCheckbox(
    'Hide Micro Menu',
    'Hides the micro menu, preserving the queue status icon',
    EUIDB.hideMicroMenu,
    function(value)
      EUIDB.hideMicroMenu = value
      SetMicroMenuVisibility()
    end,
    hideMacroText,
    EUI_Misc
  )

  local hideBagBar = newCheckbox(
    'Hide Bag Bar',
    'Hides the bag bar',
    EUIDB.hideBagBar,
    function(value)
      EUIDB.hideBagBar = value
      SetBagBarVisibility()
    end,
    hideMicroMenu,
    EUI_Misc
  )

  local autoSellGrey = newCheckbox(
    "Auto Sell Grey Items",
    "Automatically sell grey items when visiting a vendor.",
    EUIDB.autoSellGrey,
    function(value)
      EUIDB.autoSellGrey = value
    end,
    hideBagBar,
    EUI_Misc
  )

  local autoRepairOptions = newDropdown(
    "Auto Repair",
    { ["Off"] = "Off", ["Personal"] = "Personal", ["Guild"] = "Guild" },
    EUIDB.autoRepair,
    80,
    function(value)
      EUIDB.autoRepair = value
    end,
    autoSellGrey
  )
  autoRepairOptions:SetPoint("TOPLEFT", autoSellGrey, "BOTTOMRIGHT", -20, -6)

  local chatOnTop = newCheckbox(
    "Chat Edit Box on Top",
    "Moves the chat edit box to the top of the chat frame.",
    EUIDB.chatTop,
    function(value)
      EUIDB.chatTop = value
    end,
    autoRepairOptions,
    EUI_Misc
  )
  chatOnTop:SetPoint("TOPLEFT", autoRepairOptions, "BOTTOMLEFT", 0, -48)

  local chatFont, chatFontDropdown = newDropdown(
    "Chat Font",
    LSM_FONTS,
    EUIDB.chatFont,
    200,
    function(value)
      EUIDB.chatFont = value
    end,
    chatOnTop
  )
  chatFont:SetPoint("TOPLEFT", chatOnTop, "BOTTOMLEFT", 0, -6)

  local chatFontSize = newSlider(
    "EUI_ChatFontSizeSlider",
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "chatFontSize",
    8,
    24,
    1,
    "Font size for Chat",
    chatFontDropdown,
    EUI_Misc
  )
  chatFontSize:ClearAllPoints()
  chatFontSize:SetPoint("LEFT", chatFontDropdown, "RIGHT", 220, 0)

  local partyMarkerText = EUI_Misc:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  partyMarkerText:SetText("Party Markers")
  partyMarkerText:SetPoint("TOPLEFT", chatFont, "BOTTOMLEFT", 0, -48)

  local partyMarker = newCheckbox(
    "Show Party Markers",
    "Show markers for your party members on their nameplates.",
    EUIDB.partyMarker,
    function(value)
      EUIDB.partyMarker = value
    end,
    partyMarkerText,
    EUI_Misc
  )

  local partyMarkerHealer = newCheckbox(
    "Show Healer Markers",
    "Show a specific marker for healers in your party.",
    EUIDB.partyMarkerHealer,
    function(value)
      EUIDB.partyMarkerHealer = value
    end,
    partyMarker,
    EUI_Misc
  )

  -----------
  -- CVars --
  -----------
  local EUI_CVars = makePanel("EUI_CVars", EUI.panel, "CVars")

  local cVarsSectionText = EUI_CVars:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  cVarsSectionText:SetText("CVars")
  cVarsSectionText:SetPoint("TOPLEFT", 16, -16)

  local classColor = newCheckbox(
    "Class Color in Raid and Arena Frames",
    "Enable class coloring in raid frames, raid-style party frames, and arena frames.",
    EUIDB.cUFClassColoredHealth,
    function(value)
      EUIDB.cUFClassColoredHealth = value
    end,
    cVarsSectionText,
    EUI_CVars
  )

  local cUFDisplayPowerBars = newCheckbox(
    "Display Power Bars",
    "Enable power bars in raid and arena frames.",
    EUIDB.cUFDisplayPowerBars,
    function(value)
      EUIDB.cUFDisplayPowerBars = value
      if not value then
        CUFPowerBarsHealerOnly:Disable()
      else
        CUFPowerBarsHealerOnly:Enable()
      end
    end,
    classColor,
    EUI_CVars
  )

  CUFPowerBarsHealerOnly = newCheckbox(
    "Healer Power Bars Only",
    "Only show power bars for healers in raid and arena frames.",
    EUIDB.cUFPowerBarsHealerOnly,
    function(value)
      EUIDB.cUFPowerBarsHealerOnly = value
    end,
    cUFDisplayPowerBars,
    EUI_CVars
  )
  CUFPowerBarsHealerOnly:ClearAllPoints()
  CUFPowerBarsHealerOnly:SetPoint("LEFT", cUFDisplayPowerBars, "RIGHT", 130, 0)

  if not EUIDB.cUFDisplayPowerBars then
    CUFPowerBarsHealerOnly:Disable()
  end

  local largerNameplates = newCheckbox(
    "Larger Nameplates",
    "Enable larger nameplates for better visibility.",
    EUIDB.largerNameplates,
    function(value)
      EUIDB.largerNameplates = value
    end,
    cUFDisplayPowerBars,
    EUI_CVars
  )

  local showAllNameplates = newCheckbox(
    "Always Show Nameplates",
    "Show nameplates for all units, not just ones in combat.",
    EUIDB.showAllNameplates,
    function(value)
      EUIDB.showAllNameplates = value
      C_CVar.SetCVar("nameplateShowAll", value and 1 or 0)
    end,
    largerNameplates,
    EUI_CVars
  )

  local nameplateResourceOnTarget = newCheckbox(
    "Show Resource on Target Nameplate",
    "Show the special resource (holy power, combo points, chi, etc) on the nameplate of your current target.",
    EUIDB.nameplateResourceOnTarget,
    function(value)
      EUIDB.nameplateResourceOnTarget = value
      C_CVar.SetCVar("nameplateResourceOnTarget", value and 1 or 0)
    end,
    showAllNameplates,
    EUI_CVars
  )

  local nameplateShowFriends = newCheckbox(
    "Show Friendly Nameplates",
    "Show Nameplates for Friendly Units.",
    EUIDB.nameplateShowFriends,
    function(value)
      EUIDB.nameplateShowFriends = value
      C_CVar.SetCVar("nameplateShowFriends", value and 1 or 0)
    end,
    nameplateResourceOnTarget,
    EUI_CVars
  )

  local nameplateShowEnemyMinions = newCheckbox(
    "Show Enemy Minions",
    "Show Nameplates for Enemy Minions (pets, guardians, and totems).",
    EUIDB.nameplateShowEnemyMinions,
    function(value)
      EUIDB.nameplateShowEnemyMinions = value
      C_CVar.SetCVar("nameplateShowEnemyMinions", value and 1 or 0)
    end,
    nameplateShowFriends,
    EUI_CVars
  )

  --------------------
  -- Reload Buttons --
  --------------------
  local resetDefaults = CreateFrame("Button", "resettodefaults", EUI.panel, "UIPanelButtonTemplate")
  resetDefaults:SetPoint("BOTTOMLEFT", EUI.panel, "BOTTOMLEFT", 10, 10)
  resetDefaults:SetSize(120,22)
  resetDefaults:SetText("Reset to Defaults")
  resetDefaults:SetScript("OnClick", function()
    EUIDB = copyTable(EUIDBDefaults)
    ReloadUI()
  end)

  addReloadButton(EUI.panel)
  addReloadButton(EUI_Nameplates)
  addReloadButton(EUI_Tooltips)
  addReloadButton(EUI_Misc)
  addReloadButton(EUI_CVars)

  -------------------
  -- Slash Command --
  -------------------
  SLASH_eui1 = "/eui"

  SlashCmdList["eui"] = function()
    openEuiConfig()
  end

  ----------------------
  -- Game Menu Button --
  ----------------------
  local function EmsUIGameMenuButton(self)
    self:AddSection()
    self:AddButton("Em's UI", openEuiConfig)
  end
  hooksecurefunc(GameMenuFrame, "InitButtons", EmsUIGameMenuButton)
end

OnPlayerLogin(setupEuiOptions)
