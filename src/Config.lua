local LSM = LibStub("LibSharedMedia-3.0")

-- This table defines the addon's default settings:
local name, EUI = ...
EUIDBDefaults = {
  darkMode = true,

  hideHotkeys = false,
  hideMacroText = false,
  arenaNumbers = false,
  hideMicroMenu = false,
  hideBagBar = false,
  hideArenaFrames = true,

  healthBarTex = EUI_TEXTURES.healthBar,
  powerBarTex = EUI_TEXTURES.powerBar,

  frameColor = DEFAULT_FRAME_COLOUR,

  hideAltPower = false,
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

  -- Nameplate Settings
  skinNameplates = true,
  nameplateNameFontSize = 9,
  nameplateHideServerNames = true,
  nameplateNameLength = 20,
  nameplateFriendlyNamesClassColor = true,
  nameplateFriendlySmall = true,
  nameplateHideCastText = false,
  nameplateShowLevel = true,
  nameplateHealthPercent = true,
  nameplateTotems = true,
  nameplateHideFriendlyHealthbars = true,

  portraitStyle = "3D", -- 3D, 2D, or class (for class icons)
  classPortraitPack = EUI_TEXTURES.classCircles,

  -- PvP Settings
  tabBinder = true,
  dampeningDisplay = true,
  hideObjectiveTracker = true,

  queueicon = {
    point = 'TOPRIGHT',
    x = -300,
    y = 0,
  },
}

-- This function copies values from one table into another
local function copyTable(src, dst)
  -- If no source (defaults) is specified, return an empty table:
  if type(src) ~= "table" then return {} end
  -- If no target (saved variable) is specified, create a new table:
  if type(dst) ~= "table" then dst = {} end
  -- Loop through the source (defaults):
  for k, v in pairs(src) do
    -- If the value is a sub-table:
    if type(v) == "table" then
      -- Recursively call the function:
      dst[k] = copyTable(v, dst[k])
    -- Or if the default value type doesn't match the existing value type:
    elseif type(v) ~= type(dst[k]) then
      -- Overwrite the existing value with the default one:
      dst[k] = v
    end
  end
  -- Return the destination table:
  return dst
end

local function euiDefaults()
  -- Copy the values from the defaults table into the saved variables table
  -- if it exists, and assign the result to the saved variable:
  EUIDB = copyTable(EUIDBDefaults, EUIDB)
end

local function resetToDefaults()
  EUIDB = {}
  EUIDB = copyTable(EUIDBDefaults, EUIDB)
end

OnPlayerLogin(euiDefaults)

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

  local function newCheckbox(label, description, initialValue, onChange, relativeEl, frame)
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
      check:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -8)
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

    return dropdownText, dropdown
  end

  local function newSlider(frameName, label, configVar, min, max, relativeEl, frame, onChanged)
    local slider = CreateFrame("Slider", frameName, frame, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValue(EUIDB[configVar])
    slider:SetValueStep(1)
    slider:SetWidth(110)
    local textFrame = (frameName .. 'Text')
    slider:SetScript("OnValueChanged", function(_, v)
      v = floor(v)
      _G[textFrame]:SetFormattedText(label, v)
      EUIDB[configVar] = v
      if onChanged ~= nil and type(onChanged) == "function" then
        onChanged(v)
      end
    end)
    _G[(frameName .. 'Low')]:SetText(min)
    _G[(frameName .. 'High')]:SetText(max)
    _G[textFrame]:SetFormattedText(label, EUIDB[configVar])
    slider:SetPoint("TOPLEFT", relativeEl, "BOTTOMLEFT", 0, -24)

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

  local portraitSelect, portraitDropdown = newDropdown(
    "Portrait Style",
    {["3D"] = "3D", ["class"] = "Class", ["default"] = "Default"},
    EUIDB.portraitStyle,
    50,
    function(value)
      EUIDB.portraitStyle = value
    end
  )
  portraitSelect:SetPoint("TOPLEFT", euiTitle, "BOTTOMLEFT", 0, -16)

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

  local darkMode = newCheckbox(
    "Dark Mode",
    "Dark mode for action bars, objective tracker, and other HUD elements.",
    EUIDB.darkMode,
    function(value)
      EUIDB.darkMode = value
    end,
    enableDamageFont
  )

  local pvpText = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  pvpText:SetText("PvP")
  pvpText:SetPoint("TOPLEFT", darkMode, "BOTTOMLEFT", 0, -16)

  local statusBarChooser = newDropdown(
    "Status Bar Texture (Raid Frames and Nameplates)",
    LSM_STATUSBAR,
    EUIDB.healthBarTex,
    200,
    function(value)
      EUIDB.healthBarTex = value
      EUIDB.powerBarTex = value -- Sync power bar texture with health bar texture
    end,
    darkMode
  )
  statusBarChooser:SetPoint("LEFT", pvpText, "RIGHT", 295, 0)

  local dampeningDisplay = newCheckbox(
    "Dampening Display",
    "Display Dampening % under remaining time at the top of the screen in arenas.",
    EUIDB.dampeningDisplay,
    function(value)
      EUIDB.dampeningDisplay = value
    end,
    pvpText
  )

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

  local nameplateFontSlider = newSlider(
    "EUI_NameplateFontSlider",
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "nameplateNameFontSize",
    6,
    20,
    skinNameplates,
    EUI_Nameplates
  )

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
    nameplateFontSlider,
    EUI_Nameplates
  )

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
      SetFriendlyNameplateSize(true)
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

  function DisableNameplateSettings()
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
  end

  function EnableNameplateSettings()
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

  function DisableTooltipSettings()
    tooltipAnchorDropdown.disabled = true
    tooltipSpecAndIlvl:Disable()
    showMount:Disable()
    classColoredName:Disable()
    showMythicPlus:Disable()
  end

  function EnableTooltipSettings()
    tooltipAnchorDropdown.disabled = false
    tooltipSpecAndIlvl:Enable()
    showMount:Enable()
    classColoredName:Enable()
    showMythicPlus:Enable()
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

  ------------
  -- Hiding --
  ------------
  local EUI_Hiding = makePanel("EUI_Hiding", EUI.panel, "Hiding")

  local hidingText = EUI_Hiding:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  hidingText:SetText("Hiding")
  hidingText:SetPoint("TOPLEFT", 16, -16)

  local hideHotkeys = newCheckbox(
    "Hide Hotkeys on Action Bars",
    "Hides keybinding text on your action bar buttons.",
    EUIDB.hideHotkeys,
    function(value)
      EUIDB.hideHotkeys = value
    end,
    hidingText,
    EUI_Hiding
  )

  local hideMacroText = newCheckbox(
    "Hide Macro Text on Action Bars",
    "Hides macro text on your action bar buttons.",
    EUIDB.hideMacroText,
    function(value)
      EUIDB.hideMacroText = value
    end,
    hideHotkeys,
    EUI_Hiding
  )

  local hideAltPower = newCheckbox(
    "Hide Alt Power (Holy Power, Combo Points, etc under Player frame)",
    "Hides alt power bars on character frame such as combo points or holy power to clean it up, when preferring WeakAura or etc.",
    EUIDB.hideAltPower,
    function(value)
      EUIDB.hideAltPower = value
    end,
    hideMacroText,
    EUI_Hiding
  )

  local hideMicroMenu = newCheckbox(
    'Hide Micro Menu',
    'Hides the micro menu, preserving the queue status icon',
    EUIDB.hideMicroMenu,
    function(value)
      EUIDB.hideMicroMenu = value
      SetMicroMenuVisibility()
    end,
    hideAltPower,
    EUI_Hiding
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
    EUI_Hiding
  )

  -------------------
  --Reload Buttons --
  -------------------
  local resetDefaults = CreateFrame("Button", "resettodefaults", EUI.panel, "UIPanelButtonTemplate")
  resetDefaults:SetPoint("BOTTOMLEFT", EUI.panel, "BOTTOMLEFT", 10, 10)
  resetDefaults:SetSize(120,22)
  resetDefaults:SetText("Reset to Defaults")
  resetDefaults:SetScript("OnClick", function()
    resetToDefaults()
    ReloadUI()
  end)

  addReloadButton(EUI.panel)
  addReloadButton(EUI_Hiding)
  addReloadButton(EUI_Nameplates)
  addReloadButton(EUI_Tooltips)

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
