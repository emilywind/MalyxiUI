local LSM = LibStub("LibSharedMedia-3.0")

local name, EUI = ...
EUIDBDefaults = {
  uiMode = 'dark', -- 'dark', 'light', 'black', or 'blizzard'
  classColoredUnitFrames = true,
  cUFClassColoredHealth = true,
  cUFDisplayPowerBars = true,
  cUFPowerBarsHealerOnly = true,

  autoLootDefault = true,
  fasterLoot = true,

  hideHotkeys = false,
  hideMacroText = false,
  arenaNumbers = false,
  hideMicroMenu = false,
  hideBagBar = false,
  hideArenaFrames = false,

  statusBarTex = EUI_TEXTURES.statusBar,

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
  tooltipShowSpellIds = false, -- Show spell IDs in spell tooltips
  tooltipShowNpcID = false, -- Show NPC ID in unit tooltips

  -- Nameplate Settings
  skinNameplates = true,
  nameplateCombatIndicator = 'food', -- 'none', 'food', or 'sap'
  nameplateFont = EUI_FONTS.Andika,
  nameplateNameFontSize = 16,
  nameplateHideServerNames = true,
  nameplateAbbrevNames = true,
  nameplateFriendlyNamesClassColor = true,
  nameplateFriendlySmall = true,
  nameplateHideCastText = false,
  nameplateShowLevel = true,
  nameplateHealthPercent = true,
  nameplateTotemIndicators = 'important', -- 'all', 'important', or 'none'
  nameplateHideClassificationIcon = true,
  nameplateHideFriendlyHealthbars = true,
  nameplateHideFriendlyCastbars = true,
  nameplateFriendlyClickthrough = true,
  nameplateCastbarColorInterrupt = true,
  nameplateShowTargetText = true,
  nameplatePetIndicator = true,
  nameplateFadeSecondaryPets = true,
 -- Nameplate CVars
  nameplateResourceOnTarget = true,
  nameplateShowAll = true,
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

---@param src table
---@param dst? table
---@return table
local function copyTable(src, dst)
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

---@param table table
---@return table
local function tableToWowDropdown(table)
  local wowTable = {}
  for k, v in pairs(table) do
    wowTable[v] = k
  end

  return wowTable
end

---@param frameName string
---@param mainpanel Frame
---@param panelName string
---@return Frame
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

  ---@param label string
  ---@param description string
  ---@param configVar string
  ---@param relativeEl Frame
  ---@param frame Frame
  ---@param onChange? fun(value: boolean, initialValue: boolean)
  ---@param point1? string
  ---@param point2? string
  ---@param x? number
  ---@param y? number
  ---@return CheckButton
  local function newCheckbox(label, description, configVar, relativeEl, frame, onChange, point1, point2, x, y)
    local initialValue = EUIDB[configVar]
    local check = CreateFrame("CheckButton", "EUICheck" .. label, frame, "ChatConfigCheckButtonTemplate") ---@cast check CheckButton
    check:SetScript("OnClick",
    ---@param self CheckButton
    function(self)
      local tick = self:GetChecked()
      EUIDB[configVar] = tick
      if onChange then onChange(tick, initialValue) end
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
    check:SetPoint(point1 or "TOPLEFT", relativeEl, point2 or "BOTTOMLEFT", x or 0, y or -8)

    return check
  end

  ---@param label string
  ---@param options table
  ---@param configVar string
  ---@param width number
  ---@param frame Frame
  ---@param onChange? fun(value: any)
  local function newDropdown(label, options, configVar, width, frame, onChange)
    local dropdownText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownText:SetText(label)
    local initialValue = EUIDB[configVar]

    local dropdown = CreateFrame("Frame", "EUIDropdown" .. label, frame, "UIDropdownMenuTemplate")
    local disabled = false
    _G[dropdown:GetName() .. "Middle"]:SetWidth(width)
    dropdown:SetPoint("TOPLEFT", dropdownText, "BOTTOMLEFT", 0, -8)
    local displayText = _G[dropdown:GetName() .. "Text"]
    displayText:SetText(options[initialValue])

    dropdown.initialize = function()
      local selected, info = displayText:GetText(), {}
      info.func = function(v)
        displayText:SetText(v:GetText())
        EUIDB[configVar] = v.value
        if onChange then onChange(v.value) end
      end
      for value, key in pairs(options) do
        info.text = key
        info.value = value
        info.checked = info.text == selected

        info.disabled = disabled

        UIDropDownMenu_AddButton(info)
      end
    end

    dropdown.Disable = function()
      disabled = true
    end

    dropdown.Enable = function()
      disabled = false
    end

    return dropdownText, dropdown
  end

  ---@param label string
  ---@param configVar string
  ---@param min number
  ---@param max number
  ---@param valueStep number
  ---@param tooltip string
  ---@param relativeEl Frame
  ---@param frame Frame
  ---@param onChanged? fun(value: any)
  ---@return Slider
  local function newSlider(label, configVar, min, max, valueStep, tooltip, relativeEl, frame, onChanged)
    local function onValueChanged(self, value)
      self.Text:SetFormattedText(label, value)
      EUIDB[configVar] = value
      if onChanged ~= nil and type(onChanged) == "function" then
        onChanged(value)
      end
    end
    local slider = CreateFrame("Slider", "EUISlider" .. label, frame, "OptionsSliderTemplate") ---@cast slider Slider
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

  ---@param frame Frame
  ---@return Button
  local function addReloadButton(frame)
    local reload = CreateFrame("Button", "reload", frame, "UIPanelButtonTemplate") ---@cast reload Button
    reload:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    reload:SetSize(100,22)
    reload:SetText("Reload")
    reload:SetScript("OnClick", function()
      ReloadUI()
    end)
    reload:Hide()

    return reload
  end

  local version = C_AddOns.GetAddOnMetadata("EmsUI", "Version")

  local euiTitle = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
  euiTitle:SetPoint("TOPLEFT", 16, -16)
  euiTitle:SetText("Em's UI ("..version..")")

  local uiModeChooser, uiModeDropdown = newDropdown(
    "UI Mode",
    { ["blizzard"] = "Blizzard", ["dark"] = "Dark", ["light"] = "Light", ["black"] = "Black" },
    "uiMode",
    80,
    EUI.panel,
    function()
      StyleActionBars()
      ApplyStaticUIMode()
      SkinVigorBar()
    end
  )
  uiModeChooser:SetPoint("TOPLEFT", euiTitle, "BOTTOMLEFT", 0, -16)

  local classColoredUnitFrames = newCheckbox(
    "Class Colored Unit Frame Borders",
    "Color unit frame borders by class for players.",
    "classColoredUnitFrames",
    uiModeDropdown,
    EUI.panel,
    nil,
    "LEFT",
    "RIGHT",
    100,
    0
  )

  local portraitSelect, portraitDropdown = newDropdown(
    "Portrait Style",
    {["3D"] = "3D", ["class"] = "Class", ["default"] = "Default"},
    "portraitStyle",
    60,
    EUI.panel,
    RefreshEUIPortraits
  )
  portraitSelect:SetPoint("TOPLEFT", uiModeDropdown, "BOTTOMLEFT", 0, -16)

  local classPortraitPack = newDropdown(
    "Class Portrait Pack",
    CLASS_PORTRAIT_PACKS,
    "classPortraitPack",
    200,
    EUI.panel,
    RefreshEUIPortraits
  )
  classPortraitPack:SetPoint("LEFT", portraitSelect, "RIGHT", 50, 0)

  local lootSpecDisplay = newCheckbox(
    "Display Loot Spec Indicator",
    "Display loot spec icon in your player portrait.",
    "lootSpecDisplay",
    portraitSelect,
    EUI.panel,
    UpdateLootSpecDisplay
  )
  lootSpecDisplay:SetPoint("TOPLEFT", portraitDropdown, "BOTTOMLEFT", 0, -16)

  local enableFont = newCheckbox(
    "Use Custom Font",
    "Use custom font. Can be set in the dropdown to the right.",
    "enableFont",
    lootSpecDisplay,
    EUI.panel,
    function(value)
      UpdateFontChooser()
      UpdateFonts()
      if not value then
        Main_Reload:Show()
      else
        Main_Reload:Hide()
      end
    end
  )

  local fontChooser, fontDropdown = newDropdown(
    "Font",
    LSM_FONTS,
    "font",
    200,
    EUI.panel,
    UpdateFonts
  )
  fontChooser:SetPoint("LEFT", lootSpecDisplay, "RIGHT", 300, 0)

  function UpdateFontChooser()
    if EUIDB.enableFont then
      fontDropdown:Enable()
    else
      fontDropdown:Disable()
    end
  end
  UpdateFontChooser()

  local enableDamageFont = newCheckbox(
    "Use Custom Damage Font**",
    "Use a custom font for damage numbers. Can be set in the dropdown to the right.\n\n**Change requires relogging.",
    "enableDamageFont",
    enableFont,
    EUI.panel,
    UpdateDamageFontChooser
  )

  local damageFontChooser, damageFontDropdown = newDropdown(
    "Damage Font (Change requires relog)",
    LSM_FONTS,
    "damageFont",
    200,
    EUI.panel
  )
  damageFontChooser:SetPoint("LEFT", enableDamageFont, "RIGHT", 300, 0)

  function UpdateDamageFontChooser()
    if EUIDB.enableDamageFont then
      damageFontDropdown:Enable()
    else
      damageFontDropdown:Disable()
    end
  end
  UpdateDamageFontChooser()

  local pvpText = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  pvpText:SetText("PvP")
  pvpText:SetPoint("TOPLEFT", enableDamageFont, "BOTTOMLEFT", 0, -16)

  local dampeningDisplay = newCheckbox(
    "Dampening Display",
    "Display Dampening % under remaining time at the top of the screen in arenas.",
    "dampeningDisplay",
    pvpText,
    EUI.panel
  )

  local statusBarChooser = newDropdown(
    "Status Bar Texture (Raid Frames and Nameplates)",
    LSM_STATUSBAR,
    "statusBarTex",
    200,
    EUI.panel,
    function()
      RefreshNameplates()
      UpdateAllCompactUnitFrames()
    end
  )
  statusBarChooser:SetPoint("LEFT", dampeningDisplay, "RIGHT", 300, 0)

  local tabBinder = newCheckbox(
    "Tab Binder",
    "Tab-target only between players in Arenas and BGs.",
    "tabBinder",
    dampeningDisplay,
    EUI.panel
  )

  local hideArenaFrames = newCheckbox(
    "Hide Blizzard Arena Frames",
    "Hides the default arena frames in arenas, in favour of Gladius, sArena, or etc",
    "hideArenaFrames",
    tabBinder,
    EUI.panel,
    HideArenaFrames
  )

  local hideObjectiveTracker = newCheckbox(
    "Hide Objective Tracker in Battlegrounds",
    "Hide the Quest Objective Tracker in Battlegrounds to reduce clutter.",
    "hideObjectiveTracker",
    hideArenaFrames,
    EUI.panel
  )

  local miscText = EUI.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  miscText:SetText("Misc")
  miscText:SetPoint("TOPLEFT", hideObjectiveTracker, "BOTTOMLEFT", 0, -16)

  local castBarScale = newSlider(
    "Castbar Scale: %.1f",
    "castBarScale",
    1,
    2,
    0.1,
    "Set scale for Target and Focus cast bars",
    miscText,
    EUI.panel
  )

  local enableStatsFrame = newCheckbox(
    "Enable Stats Frame",
    "Enable the stats frame that shows FPS, latency, and movement speed.",
    "enableStatsFrame",
    castBarScale,
    EUI.panel,
    function(value)
      UpdateStatsSpeed()
      if value then
        StatsFrame:Show()
      else
        StatsFrame:Hide()
      end
    end
  )

  local enableStatsSpeed = newCheckbox(
    "Show Movement Speed",
    "Show movement speed percentage in the stats frame.",
    "enableStatsSpeed",
    enableStatsFrame,
    EUI.panel,
    nil,
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

  -- Create a ScrollFrame and a child frame to hold your content
  local scrollFrame = CreateFrame("ScrollFrame", "MyConfigScrollFrame", EUI_Nameplates, "UIPanelScrollFrameTemplate")
  scrollFrame:SetSize(640, 600)
  scrollFrame:SetPoint("TOPLEFT", EUI_Nameplates, "TOPLEFT", 0, 0)

  local Nameplate_Content = CreateFrame("Frame", nil, scrollFrame)
  Nameplate_Content:SetSize(640, 900) -- Height should fit all your content
  scrollFrame:SetScrollChild(Nameplate_Content)

  local nameplateText = Nameplate_Content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  nameplateText:SetText("Nameplates")
  nameplateText:SetPoint("TOPLEFT", 16, -16)

  local skinNameplates = newCheckbox(
    "Enhance Nameplates",
    "Enable the customisation options below for nameplates.",
    "skinNameplates",
    nameplateText,
    Nameplate_Content,
    function(value, initialValue)
      if value ~= initialValue then
        Nameplate_Reload:Show()
      else
        Nameplate_Reload:Hide()
      end
      if value then
        EnableNameplateSettings()
      else
        DisableNameplateSettings()
      end
    end
  )

  local nameplateFont, nameplateFontDropdown = newDropdown(
    "Nameplate Font",
    LSM_FONTS,
    "nameplateFont",
    200,
    Nameplate_Content,
    RefreshNameplates
  )
  nameplateFont:SetPoint("TOPLEFT", skinNameplates, "BOTTOMLEFT", 0, -4)

  local nameplateFontSlider = newSlider(
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "nameplateNameFontSize",
    6,
    24,
    1,
    "Font size for Nameplate Names",
    nameplateFontDropdown,
    Nameplate_Content,
    RefreshNameplates
  )
  nameplateFontSlider:ClearAllPoints()
  nameplateFontSlider:SetPoint("LEFT", nameplateFontDropdown, "RIGHT", 220, 0)

  local nameplateAbbrevNames = newCheckbox(
    "Abbreviate Unit Names",
    "Abbreviate long NPC names on nameplates.",
    "nameplateAbbrevNames",
    nameplateFont,
    Nameplate_Content
  )
  nameplateAbbrevNames:SetPoint("TOPLEFT", nameplateFont, "BOTTOMLEFT", 0, -50)

  local nameplateHideServerNames = newCheckbox(
    "Hide Server Names (Must rezone to see change).",
    "Hide server names for players from different servers to reduce clutter.",
    "nameplateHideServerNames",
    nameplateAbbrevNames,
    Nameplate_Content
  )

  local nameplateFriendlyNamesClassColor = newCheckbox(
    "Class Color Friendly Names",
    "Colors friendly players' names on their nameplates.",
    "nameplateFriendlyNamesClassColor",
    nameplateHideServerNames,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateFriendlySmall = newCheckbox(
    "Smaller Friendly Nameplates",
    "Reduce size of friendly nameplates to more easily distinguish friend from foe",
    "nameplateFriendlySmall",
    nameplateFriendlyNamesClassColor,
    Nameplate_Content,
    SetFriendlyNameplateSize
  )

  local nameplateShowLevel = newCheckbox(
    "Show Level",
    "Show player/mob level on nameplate",
    "nameplateShowLevel",
    nameplateFriendlySmall,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateShowHealth = newCheckbox(
    "Show Health Percentage",
    "Show percentages of health on nameplates",
    "nameplateHealthPercent",
    nameplateShowLevel,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateTotemIndicators, nameplateTotemIndicatorsDropdown = newDropdown(
    "Totem/Important Pet (Psyfiend, Demonic Tyrant, etc.) Indicators",
    { ["none"] = "None", ["all"] = "All", ["important"] = "Important" },
    "nameplateTotemIndicators",
    120,
    Nameplate_Content,
    UpdateTotemIndicatorSetting
  )
  nameplateTotemIndicators:SetPoint("TOPLEFT", nameplateShowHealth, "BOTTOMLEFT", 0, -16)

  local arenaNumbers = newCheckbox(
    "Show Arena Numbers on nameplates in arenas",
    "Show Arena number (i.e. 1, 2, 3 etc) on top of nameplates in arenas instead of player names to assist with macro use awareness",
    "arenaNumbers",
    nameplateTotemIndicators,
    Nameplate_Content,
    RefreshNameplates
  )
  arenaNumbers:ClearAllPoints()
  arenaNumbers:SetPoint("TOPLEFT", nameplateTotemIndicators, "BOTTOMLEFT", 0, -48)

  local nameplateHideCastText = newCheckbox(
    "Hide Nameplate Cast Text",
    "Hide cast text from nameplate castbars.",
    "nameplateHideCastText",
    arenaNumbers,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateHideFriendlyHealthbars = newCheckbox(
    "Hide Friendly Nameplate Health Bars",
    "Hide health bars for friendly players.",
    "nameplateHideFriendlyHealthbars",
    nameplateHideCastText,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateHideFriendlyCastbars = newCheckbox(
    "Hide Friendly Nameplate Cast Bars",
    "Hide cast bars for friendly players.",
    "nameplateHideFriendlyCastbars",
    nameplateHideFriendlyHealthbars,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateHideClassificationIcon = newCheckbox(
    "Hide Nameplate Classification Icon",
    "Hide the classification icon (e.g. elite, rare) on nameplates.",
    "nameplateHideClassificationIcon",
    nameplateHideFriendlyCastbars,
    Nameplate_Content,
    RefreshNameplates
  )


  local nameplateFriendlyClickthrough = newCheckbox(
    "Friendly Nameplate Clickthrough",
    "Allow clicking through friendly nameplates to interact with objects behind them.",
    "nameplateFriendlyClickthrough",
    nameplateHideClassificationIcon,
    Nameplate_Content,
    function(value)
      C_NamePlate.SetNamePlateFriendlyClickThrough(value)
    end
  )

  local nameplateColorInterrupt = newCheckbox(
    "Color Castbars by Interrupt Availability",
    "Color castbars based upon interrupt availability. This allows you to track your interrupt cooldown without having to look elsewhere.",
    "nameplateCastbarColorInterrupt",
    nameplateFriendlyClickthrough,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateShowTargetText = newCheckbox(
    "Show Target Text on Nameplates",
    "Show the target of the current cast on nameplates.",
    "nameplateShowTargetText",
    nameplateColorInterrupt,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplatePetIndicator = newCheckbox(
    "Show Pet Indicator on Nameplates",
    "Show an icon on nameplates to indicate primary/important pets.",
    "nameplatePetIndicator",
    nameplateShowTargetText,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateFadeSecondaryPets = newCheckbox(
    "Fade Secondary Pets",
    "Fade the nameplates of secondary pets (e.g., second BM Hunter pet, Warlock minions).",
    "nameplateFadeSecondaryPets",
    nameplatePetIndicator,
    Nameplate_Content,
    RefreshNameplates
  )

  local nameplateCombatIndicator, nameplateCombatIndicatorDropdown = newDropdown(
    "Nameplate Combat Indicator",
    { ["none"] = "None", ["food"] = "Food", ["sap"] = "Sap" },
    "nameplateCombatIndicator",
    80,
    Nameplate_Content,
    RefreshNameplates
  )
  nameplateCombatIndicator:SetPoint("TOPLEFT", nameplateFadeSecondaryPets, "BOTTOMLEFT", 0, -4)

  local partyMarkerText = Nameplate_Content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  partyMarkerText:SetText("Party Markers")
  partyMarkerText:SetPoint("TOPLEFT", nameplateCombatIndicator, "BOTTOMLEFT", 0, -48)

  local partyMarker = newCheckbox(
    "Show Party Markers",
    "Show markers for your party members on their nameplates.",
    "partyMarker",
    partyMarkerText,
    Nameplate_Content,
    RefreshNameplates
  )

  local partyMarkerHealer = newCheckbox(
    "Show Healer Markers",
    "Show a specific marker for healers in your party.",
    "partyMarkerHealer",
    partyMarker,
    Nameplate_Content,
    RefreshNameplates
  )

  local partyMarkerHideRaidmarker = newCheckbox(
    "Hide Default Party Raid Markers",
    "Hide the default raid markers above party members' heads.",
    "partyMarkerHideRaidmarker",
    partyMarkerHealer,
    Nameplate_Content,
    RefreshNameplates
  )

  function DisableNameplateSettings()
    nameplateFontDropdown:Disable()
    nameplateFontSlider:Disable()
    nameplateAbbrevNames:Disable()
    nameplateHideServerNames:Disable()
    nameplateFriendlyNamesClassColor:Disable()
    nameplateFriendlySmall:Disable()
    nameplateShowLevel:Disable()
    nameplateShowHealth:Disable()
    nameplateTotemIndicatorsDropdown:Disable()
    arenaNumbers:Disable()
    nameplateHideCastText:Disable()
    nameplateHideFriendlyHealthbars:Disable()
    nameplateHideClassificationIcon:Disable()
    nameplateFriendlyClickthrough:Disable()
    nameplateColorInterrupt:Disable()
    nameplateShowTargetText:Disable()
    nameplatePetIndicator:Disable()
    nameplateFadeSecondaryPets:Disable()
    nameplateCombatIndicatorDropdown:Disable()
    partyMarker:Disable()
    partyMarkerHealer:Disable()
    partyMarkerHideRaidmarker:Disable()
  end

  function EnableNameplateSettings()
    nameplateFontDropdown:Enable()
    nameplateFontSlider:Enable()
    nameplateAbbrevNames:Enable()
    nameplateHideServerNames:Enable()
    nameplateFriendlyNamesClassColor:Enable()
    nameplateFriendlySmall:Enable()
    nameplateShowLevel:Enable()
    nameplateShowHealth:Enable()
    nameplateTotemIndicatorsDropdown:Enable()
    arenaNumbers:Enable()
    nameplateHideCastText:Enable()
    nameplateHideFriendlyHealthbars:Enable()
    nameplateHideClassificationIcon:Enable()
    nameplateFriendlyClickthrough:Enable()
    nameplateColorInterrupt:Enable()
    nameplateShowTargetText:Enable()
    nameplatePetIndicator:Enable()
    nameplateFadeSecondaryPets:Enable()
    nameplateCombatIndicatorDropdown:Enable()
    partyMarker:Enable()
    partyMarkerHealer:Enable()
    partyMarkerHideRaidmarker:Enable()
  end

  if not EUIDB.skinNameplates then
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
    "enhanceTooltips",
    tooltipText,
    EUI_Tooltips,
    function(value, initialValue)
      if value ~= initialValue then
        Tooltips_Reload:Show()
      else
        Tooltips_Reload:Hide()
      end
      if value then
        EnableTooltipSettings()
      else
        DisableTooltipSettings()
      end
    end
  )
  enhanceTooltips:SetPoint("TOPLEFT", tooltipText, "BOTTOMLEFT", 0, -16)

  local tooltipAnchor, tooltipAnchorDropdown = newDropdown(
    "Cursor Anchor (anchor tooltips to cursor out of combat)",
    { ["ANCHOR_CURSOR_LEFT"] = "Bottom Right", ["ANCHOR_CURSOR_RIGHT"] = "Bottom Left", ['DEFAULT'] = 'Disabled' },
    "tooltipAnchor",
    100,
    EUI_Tooltips
  )
  tooltipAnchor:SetPoint("TOPLEFT", enhanceTooltips, "BOTTOMLEFT", 0, -16)

  local tooltipSpecAndIlvl = newCheckbox(
    "Show Player Spec and Item Level",
    "Show item level in tooltips.",
    "tooltipSpecAndIlvl",
    tooltipAnchorDropdown,
    EUI_Tooltips
  )

  local showMount = newCheckbox(
    "Show Mount Information",
    "Show mount information in tooltips.",
    "tooltipShowMount",
    tooltipSpecAndIlvl,
    EUI_Tooltips
  )

  local classColoredName = newCheckbox(
    "Class Colored Names",
    "Color player names in tooltips by class.",
    "tooltipClassColoredName",
    showMount,
    EUI_Tooltips
  )

  local showMythicPlus = newCheckbox(
    "Show Mythic+ Information",
    "Show Mythic+ information in player tooltips.",
    "tooltipShowMythicPlus",
    classColoredName,
    EUI_Tooltips
  )

  local tooltipHideHealthBar = newCheckbox(
    "Hide Health Bar",
    "Hide the health bar in tooltips.",
    "tooltipHideHealthBar",
    showMythicPlus,
    EUI_Tooltips
  )

  local tooltipShowSpellIds = newCheckbox(
    "Show Spell IDs",
    "Show spell IDs in tooltips.",
    "tooltipShowSpellIds",
    tooltipHideHealthBar,
    EUI_Tooltips
  )

  local tooltipShowNpcID = newCheckbox(
    "Show NPC ID",
    "Show NPC ID in tooltips.",
    "tooltipShowNpcID",
    tooltipShowSpellIds,
    EUI_Tooltips
  )

  function DisableTooltipSettings()
    tooltipAnchorDropdown:Disable()
    tooltipSpecAndIlvl:Disable()
    showMount:Disable()
    classColoredName:Disable()
    showMythicPlus:Disable()
    tooltipHideHealthBar:Disable()
    tooltipShowSpellIds:Disable()
    tooltipShowNpcID:Disable()
  end

  function EnableTooltipSettings()
    tooltipAnchorDropdown:Enable()
    tooltipSpecAndIlvl:Enable()
    showMount:Enable()
    classColoredName:Enable()
    showMythicPlus:Enable()
    tooltipHideHealthBar:Enable()
    tooltipShowSpellIds:Enable()
    tooltipShowNpcID:Enable()
  end

  if not EUIDB.enhanceTooltips then
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
    "hideHotkeys",
    miscSectionText,
    EUI_Misc,
    StyleActionBars
  )

  local hideMacroText = newCheckbox(
    "Hide Macro Text on Action Bars",
    "Hides macro text on your action bar buttons.",
    "hideMacroText",
    hideHotkeys,
    EUI_Misc,
    StyleActionBars
  )

  local hideMicroMenu = newCheckbox(
    'Hide Micro Menu',
    'Hides the micro menu, preserving the queue status icon',
    "hideMicroMenu",
    hideMacroText,
    EUI_Misc,
    SetMicroMenuVisibility
  )

  local hideBagBar = newCheckbox(
    'Hide Bag Bar',
    'Hides the bag bar',
    "hideBagBar",
    hideMicroMenu,
    EUI_Misc,
    SetBagBarVisibility
  )

  local autoSellGrey = newCheckbox(
    "Auto Sell Grey Items",
    "Automatically sell grey items when visiting a vendor.",
    "autoSellGrey",
    hideBagBar,
    EUI_Misc
  )

  local autoRepairOptions = newDropdown(
    "Auto Repair",
    { ["Off"] = "Off", ["Personal"] = "Personal", ["Guild"] = "Guild" },
    "autoRepair",
    80,
    autoSellGrey
  )
  autoRepairOptions:SetPoint("TOPLEFT", autoSellGrey, "BOTTOMRIGHT", -20, -6)

  local chatOnTop = newCheckbox(
    "Chat Edit Box on Top",
    "Moves the chat edit box to the top of the chat frame.",
    "chatTop",
    autoRepairOptions,
    EUI_Misc,
    ReloadChats
  )
  chatOnTop:SetPoint("TOPLEFT", autoRepairOptions, "BOTTOMLEFT", 0, -48)

  local chatFont, chatFontDropdown = newDropdown(
    "Chat Font",
    LSM_FONTS,
    "chatFont",
    200,
    chatOnTop,
    ReloadChats
  )
  chatFont:SetPoint("TOPLEFT", chatOnTop, "BOTTOMLEFT", 0, -6)

  local chatFontSize = newSlider(
    FONT_SIZE.." "..FONT_SIZE_TEMPLATE,
    "chatFontSize",
    8,
    24,
    1,
    "Font size for Chat",
    chatFontDropdown,
    EUI_Misc,
    ReloadChats
  )
  chatFontSize:ClearAllPoints()
  chatFontSize:SetPoint("LEFT", chatFontDropdown, "RIGHT", 220, 0)

  local fasterLoot = newCheckbox(
    "Enable Faster Autoloot",
    "Enable faster autolooting of items. May cause the loot window not to appear.",
    "fasterLoot",
    chatFont,
    EUI_Misc
  )
  fasterLoot:ClearAllPoints()
  fasterLoot:SetPoint("TOPLEFT", chatFont, "BOTTOMLEFT", 0, -48)

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
    "cUFClassColoredHealth",
    cVarsSectionText,
    EUI_CVars,
    UpdateCUFCVars
  )

  local cUFDisplayPowerBars = newCheckbox(
    "Display Power Bars",
    "Enable power bars in raid and arena frames.",
    "cUFDisplayPowerBars",
    classColor,
    EUI_CVars,
    function(value)
      if not value then
        CUFPowerBarsHealerOnly:Disable()
      else
        CUFPowerBarsHealerOnly:Enable()
      end
      UpdateCUFCVars()
    end
  )

  CUFPowerBarsHealerOnly = newCheckbox(
    "Healer Power Bars Only",
    "Only show power bars for healers in raid and arena frames.",
    "cUFPowerBarsHealerOnly",
    cUFDisplayPowerBars,
    EUI_CVars,
    UpdateCUFCVars
  )
  CUFPowerBarsHealerOnly:ClearAllPoints()
  CUFPowerBarsHealerOnly:SetPoint("LEFT", cUFDisplayPowerBars, "RIGHT", 130, 0)

  if not EUIDB.cUFDisplayPowerBars then
    CUFPowerBarsHealerOnly:Disable()
  end

  local nameplateShowAll = newCheckbox(
    "Always Show Nameplates",
    "Show nameplates for all units, not just ones in combat.",
    "nameplateShowAll",
    cUFDisplayPowerBars,
    EUI_CVars,
    function(value)
      EUISetCVar("nameplateShowAll", value)
    end
  )

  local nameplateResourceOnTarget = newCheckbox(
    "Show Resource on Target Nameplate",
    "Show the special resource (holy power, combo points, chi, etc) on the nameplate of your current target.",
    "nameplateResourceOnTarget",
    nameplateShowAll,
    EUI_CVars,
    function(value)
      EUISetCVar("nameplateResourceOnTarget", value)
    end
  )

  local nameplateShowFriends = newCheckbox(
    "Show Friendly Nameplates",
    "Show Nameplates for Friendly Units.",
    "nameplateShowFriends",
    nameplateResourceOnTarget,
    EUI_CVars,
    function(value)
      EUISetCVar("nameplateShowFriends", value)
    end
  )

  local nameplateShowEnemyMinions = newCheckbox(
    "Show Enemy Minions",
    "Show Nameplates for Enemy Minions (pets, guardians, and totems).",
    "nameplateShowEnemyMinions",
    nameplateShowFriends,
    EUI_CVars,
    function(value)
      EUISetCVar("nameplateShowEnemyMinions", value)
    end
  )

  local autoLootDefault = newCheckbox(
    "Auto Loot",
    "Enable auto loot by default instead of having to press a key.",
    "autoLootDefault",
    nameplateShowEnemyMinions,
    EUI_CVars,
    function(value)
      EUISetCVar("autoLootDefault", value)
    end
  )

  EUISetCVar("autoLootDefault")

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

  Main_Reload = addReloadButton(EUI.panel)
  Nameplate_Reload = addReloadButton(Nameplate_Content)
  Tooltips_Reload = addReloadButton(EUI_Tooltips)

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
