SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"

AddonDir = "Interface\\AddOns\\EmsUI"
MediaDir = AddonDir.."\\media"
FontsDir = MediaDir.."\\fonts"
TextureDir = MediaDir.."\\textures"

COLOR_DARK = CreateColorFromHexString('ff4d4d4d')
COLOR_BLACK = CreateColorFromHexString('ff000000')
COLOR_WHITE = CreateColorFromHexString('ffffffff')
COLOR_LIGHT = CreateColorFromHexString('ffcccccc')
COLOR_GREEN = CreateColorFromHexString('ff00ff00')
COLOR_RED = CreateColorFromHexString('ffff0000')
COLOR_GREY = CreateColorFromHexString('ff808080')
COLOR_BORDER = CreateColorFromHexString('ff1a1a1a')
COLOR_CASTBAR_NO_INTERRUPT = CreateColorFromHexString('ffff0004')
COLOR_CASTBAR_DELAYED_INTERRUPT = CreateColorFromHexString('ffff7aa5')

EUI_TEXTURES = {
  buttons = {
    normal = TextureDir.."\\buttons\\button-normal.tga",
    pushed = TextureDir.."\\buttons\\button-pressed.tga",
    checked = TextureDir.."\\buttons\\button-checked.tga",
  },

  tooltipBorder = TextureDir.."\\tooltip-border.tga",

  roundedBorder = TextureDir.."\\rounded-border.tga",

  statusBar = TextureDir.."\\blizz-inspired.tga",

  classCircles = TextureDir.."\\class\\fabledrealm",

  circleTexture = TextureDir.."\\Portrait-ModelBack.tga",
  portraitModelFront = TextureDir.."\\portrait-modelfront.tga",

  minimap = {
    dungeonDifficulty = TextureDir.."\\minimap\\UI-DungeonDifficulty-Button.tga"
  },

  lfg = {
    portraitRoles = TextureDir.."\\lfgframe\\UI-LFG-ICON-PORTRAITROLES.tga",
    roles = TextureDir.."\\lfgframe\\UI-LFG-ICON-ROLES.tga"
  },
}

FABLED_CLASS_CIRCLES_DATA = {
  class = {
		path = [[Interface\AddOns\EmsUI\media\textures\class\]],
		styles = {
			fabled = {
				name = 'Fabled',
				artist = 'Royroyart',
				site = 'https://www.fiverr.com/royyanikhwani',
			},
			fabledrealm = {
				name = 'Fabled Realm',
				artist = 'Handclaw',
				site = 'https://handclaw.artstation.com/',
			},
			fabledpixels = {
				name = 'Fabled Pixels',
				artist = 'Dragumagu',
				site = 'https://www.artstation.com/dragumagu',
			},
		},
    WARRIOR	= {
      texString = '0:128:0:128',
      texCoords = { 0, 0, 0, 0.125, 0.125, 0, 0.125, 0.125 },
    },
    MAGE = {
      texString = '128:256:0:128',
      texCoords = { 0.125, 0, 0.125, 0.125, 0.25, 0, 0.25, 0.125 },
    },
    ROGUE = {
      texString = '256:384:0:128',
      texCoords = { 0.25, 0, 0.25, 0.125, 0.375, 0, 0.375, 0.125 },
    },
      DRUID = {
      texString = '384:512:0:128',
      texCoords = { 0.375, 0, 0.375, 0.125, 0.5, 0, 0.5, 0.125 },
    },
    EVOKER = {
      texString = '512:640:0:128',
      texCoords = { 0.5, 0, 0.5, 0.125, 0.625, 0, 0.625, 0.125 },
    },
    HUNTER = {
      texString = '0:128:128:256',
      texCoords = { 0, 0.125, 0, 0.25, 0.125, 0.125, 0.125, 0.25 },
    },
    SHAMAN = {
      texString = '128:256:128:256',
      texCoords = { 0.125, 0.125, 0.125, 0.25, 0.25, 0.125, 0.25, 0.25 },
    },
    PRIEST = {
      texString = '256:384:128:256',
      texCoords = { 0.25, 0.125, 0.25, 0.25, 0.375, 0.125, 0.375, 0.25 },
    },
    WARLOCK = {
      texString = '384:512:128:256',
      texCoords = { 0.375, 0.125, 0.375, 0.25, 0.5, 0.125, 0.5, 0.25 },
    },
    PALADIN = {
      texString = '0:128:256:384',
      texCoords = { 0, 0.25, 0, 0.375, 0.125, 0.25, 0.125, 0.375 },
    },
    DEATHKNIGHT = {
      texString = '128:256:256:384',
      texCoords = { 0.125, 0.25, 0.125, 0.375, 0.25, 0.25, 0.25, 0.375 },
    },
    MONK = {
      texString = '256:384:256:384',
      texCoords = { 0.25, 0.25, 0.25, 0.375, 0.375, 0.25, 0.375, 0.375 },
    },
    DEMONHUNTER = {
      texString = '384:512:256:384',
      texCoords = { 0.375, 0.25, 0.375, 0.375, 0.5, 0.25, 0.5, 0.375 },
    },
  },
}

HEALER_SPECS = {
  [105]  = true, --> druid resto
  [270]  = true, --> monk mw
  [65]   = true, --> paladin holy
  [256]  = true, --> priest disc
  [257]  = true, --> priest holy
  [264]  = true, --> shaman resto
  [1468] = true, --> preservation evoker
}

CLASS_PORTRAIT_PACKS = {}
local classInfo = FABLED_CLASS_CIRCLES_DATA.class

for iconStyle, data in next, classInfo.styles do
  CLASS_PORTRAIT_PACKS[format('%s%s', classInfo.path, iconStyle)] = format('%s (by %s)', data.name, data.artist)
end

---@param unit UnitToken
---@return ColorMixin|nil
local function GetUnitClassColor(unit)
  if not unit or not UnitIsPlayer(unit) then return end

  local class = select(2, UnitClass(unit))

  local color = RAID_CLASS_COLORS[class]
  if not color then return end

  return CreateColorFromHexString(color.colorStr)
end

---@param unit UnitToken
---@return ColorMixin
function GetFrameColor(unit)
  local classColor = unit and GetUnitClassColor(unit)

  if EUIDB.classColoredUnitFrames and classColor then
    return classColor
  elseif EUIDB.uiMode == 'black' then
    return COLOR_BLACK
  elseif EUIDB.uiMode == 'dark' then
    return COLOR_DARK
  elseif EUIDB.uiMode == 'light' then
    return COLOR_LIGHT
  else
    return COLOR_WHITE
  end
end

---@param events string[]
---@param callback fun(self: Frame, event: string, ...: any)
---@return Frame
function OnEvents(events, callback)
  local frame = CreateFrame("Frame")
  for _, event in ipairs(events) do
    frame:RegisterEvent(event)
  end
  frame:SetScript("OnEvent", callback)
  return frame
end

---@param event string
---@param callback fun(self: Frame, event: string, ...: any)
---@return Frame
function OnEvent(event, callback)
  return OnEvents({ event }, callback)
end

---@param callback fun(self: Frame, event: string, ...: any)
---@return Frame
function OnPlayerLogin(callback)
  return OnEvent("PLAYER_LOGIN", callback)
end

EUI_FONTS = {
  Andika = FontsDir.."\\Andika.ttf",
  Fira = FontsDir.."\\FiraSans.ttf",
  SourceSans = FontsDir.."\\SourceSans3.ttf",
  Marmelad = FontsDir.."\\Marmelad.ttf",
  Bangers = FontsDir.."\\Bangers-Regular.ttf",
}

EUI_DAMAGE_FONT = FontsDir.."\\Bangers-Regular.ttf"

---@param ic Texture
function StyleIcon(ic)
  ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

EUI_BACKDROP = {
  edgeFile = EUI_TEXTURES.tooltipBorder,
  tileEdge = true,
  edgeSize = 10,
}

---@param b Button|Texture
---@param frame? Frame
---@return Texture
function ApplyEuiBackdrop(b, frame)
  if b.euiBorder then return b.euiBorder end

  frame = frame or CreateFrame("Frame", nil, b)

  local name = b:GetName()
  local icon = b.icon or b.Icon or (name and _G[name.."Icon"]) or b
  StyleIcon(icon)

  local border = frame:CreateTexture()
  border:SetDrawLayer("OVERLAY")
  border:SetTexture(EUI_TEXTURES.roundedBorder)
  border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
  border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
  SetEuiBorderColor(border)
  b.euiBorder = border

  return border
end

---@param border Texture
---@param color? ColorMixin
function SetEuiBorderColor(border, color)
  color = color or COLOR_BORDER

  if border.SetVertexColor then
    SetVertexColor(border, color)
  else
    border:SetBackdropBorderColor(color:GetRGBA())
  end
end

---@param texture Texture
---@return ColorMixin
function GetVertexColor(texture)
  return CreateColor(texture:GetVertexColor())
end

---@param texture Texture
---@param color ColorMixin
function SetVertexColor(texture, color)
  texture:SetVertexColor(color:GetRGBA())
end

---@param bar StatusBar
---@param color ColorMixin
function SetStatusBarColor(bar, color)
  bar:SetStatusBarColor(color:GetRGBA())
end

---@param textObject FontString
---@param size? number
---@param outlinestyle? string
function SetDefaultFont(textObject, size, outlinestyle)
  if not textObject then return end
  local currSize = select(2, textObject:GetFont())

  textObject:SetFont(EUIDB.font, size or currSize, outlinestyle or "THINOUTLINE")
end

---@param textObject FontString
---@param font string
---@param size? number
---@param flags? string
---@param color? ColorMixin
function ModifyFont(textObject, font, size, flags, color)
  if color then
    textObject:SetTextColor(color:GetRGBA())
  end
  local fontFile, currSize = textObject:GetFont()
  textObject:SetFont(font or fontFile, size or currSize, flags or "THINOUTLINE")
end

---@param bar StatusBar
function SkinStatusBar(bar)
  if not bar then return end

  if bar.BorderMid then
    bar.BorderMid:SetAlpha(0)
    bar.BorderLeft:SetAlpha(0)
    bar.BorderRight:SetAlpha(0)
  end

  bar:SetStatusBarTexture("ui-castingbar-tier4-empower-2x")
  SetVertexColor(bar:GetStatusBarTexture(), CreateColor(0.8, 0, 0))

  if bar.BarBG then
    bar.BarBG:Hide()
    bar.BarFrame:Hide()
  end

  local background = bar.background
  if not background then
    background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAtlas('UI-CastingBar-Background')
    background:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
    background:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
    bar.background = background
  end

  ApplyUIMode(background)

  -- Border
  local border = bar.border
  if not border then
    border = bar:CreateTexture(nil, "BACKGROUND")
    border:SetAtlas('UI-CastingBar-Frame')
    border:SetPoint("TOPLEFT", bar, "TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 3, -3)
    bar.border = border
  end

  ApplyUIMode(border)
end

---@param name string
---@param frame Frame
---@param onUpdate fun(self: StatusBar, elapsed: number)
---@return StatusBar
function CreateTimerBar(name, frame, onUpdate)
  local timerBar = CreateFrame("StatusBar", name, frame)
  timerBar:SetFrameLevel(10) -- Ensure it appears above the popup
  timerBar:SetPoint("TOP", frame, "BOTTOM", 0, -5)
  timerBar:SetSize(194, 14)

  SkinStatusBar(timerBar)

  timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
  timerBar.Text:SetFontObject(GameFontHighlight)
  timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")

  timerBar:SetScript("OnUpdate", onUpdate)

  return timerBar
end

---@param guid string
---@return number|nil
function GetNPCIDFromGUID(guid)
  return tonumber(guid:match("%-([0-9]+)%-%x+$"))
end

---@param unit UnitToken
---@return table
function GetUnitInfo(unit)
  local info = {
    id = unit,
    exists = unit and UnitExists(unit),
  }

  if not info.exists then return info end

  local className, classFileName, classID = UnitClass(unit)

  info.guid = UnitGUID(unit)
  info.name = UnitName(unit)
  info.level = UnitEffectiveLevel(unit)
  info.isWildBattlePet = UnitIsWildBattlePet(unit)
  info.isSelf = UnitIsUnit("player", unit)
  info.isTarget = UnitIsUnit("target", unit)
  info.isFocus = UnitIsUnit("focus", unit)
  info.isPet = UnitIsUnit("pet", unit)
  info.isPlayer = UnitIsPlayer(unit)

  local name, realm = UnitName(unit)
  info.name = name
  info.realm = realm

  info.isNpc = not info.isPlayer
  info.npcID = info.isNpc and GetNPCIDFromGUID(info.guid) or nil
  info.className = info.isPlayer and className or nil
  info.classFileName = info.isPlayer and classFileName or nil
  info.classID = info.isPlayer and classID or nil
  info.reaction = UnitReaction(unit, "player")
  info.isEnemy = (info.reaction and info.reaction < 4) and not info.isSelf
  info.isNeutral = (info.reaction and info.reaction == 4) and not info.isSelf
  info.isFriend = (info.reaction and info.reaction >= 5) and not info.isSelf
  info.sex = UnitSex(unit)
  info.tapDenied = UnitIsTapDenied(unit)
  info.playerControlled = UnitPlayerControlled(unit)
  info.classification = UnitClassification(unit) -- elite, rare, rareelite, worldboss
  info.inCombat = UnitAffectingCombat(unit)
  info.race = UnitRace(unit)
  info.family = UnitCreatureFamily(unit)
  info.type = UnitCreatureType(unit)
  info.isConnected = UnitIsConnected(unit)
  info.isVisible = UnitIsVisible(unit)
  info.isInParty = UnitInParty(unit)
  info.canAttack = UnitCanAttack("player", unit)

  return info
end

---@param unit UnitToken
---@return ColorMixin
function GetUnitHealthColor(unit)
  local unitInfo = GetUnitInfo(unit)
  local classColor = GetUnitClassColor(unit)

  if classColor then
    return classColor
  else
    if unitInfo.exists then
      local reactionColor = FACTION_BAR_COLORS[unitInfo.reaction]
      if reactionColor then return reactionColor end
    end

    return CreateColor(GameTooltip_UnitColor(unit))
  end
end

---@param frame Frame
---@return UnitToken
function GetNameplateUnit(frame)
  return frame.displayedUnit or frame.unit
end

---@param frame Frame
---@return table
function GetNameplateUnitInfo(frame)
  local unit = GetNameplateUnit(frame)

  return GetUnitInfo(unit)
end

---@param unit UnitToken
---@return Frame|nil
function GetSafeNameplate(unit)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())

  return (nameplate and nameplate.UnitFrame) or nil
end

function GetInstanceData()
  local inInstance, instanceType = IsInInstance()
  local isInArena = inInstance and (instanceType == "arena")
  local isInBg = inInstance and (instanceType == "pvp")
  local isInPvP = isInBg or isInArena
  local isInPvE = inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")

  return {
    isInPvP = isInPvP,
    isInBg = isInBg,
    isInArena = isInArena,
    isInPvE = isInPvE
  }
end

---@param s string
---@return string, integer
function Trim(s)
  if not s then return '', 0 end

  return s:gsub("^%s*(.-)%s*$", "%1")
end

--- Sets a CVar and saves it to EUIDB
---@param cvarName string
---@param value boolean|number|string|nil
---@param settingNil? boolean If true, allows setting nil value to the CVar
---@return boolean
function EUISetCVar(cvarName, value, settingNil)
  if value == nil and not settingNil then
    value = EUIDB[cvarName]
  else
    EUIDB[cvarName] = value
  end

  return C_CVar.SetCVar(cvarName, (value == true and 1) or (value == false and 0) or value)
end

---@param func fun(frame: Frame)
function DoToNameplates(func)
  for _, frame in pairs(C_NamePlate.GetNamePlates()) do
    if frame.UnitFrame then
      func(frame.UnitFrame)
    end
  end
end

---@param destTable table
---@param srcTable table
function PushTableIntoTable(destTable, srcTable)
  for k, v in pairs(srcTable) do
    destTable[k] = v
  end
end
