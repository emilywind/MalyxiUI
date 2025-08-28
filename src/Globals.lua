SQUARE_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"
DEFAULT_FRAME_COLOUR = {
  0.3,
  0.3,
  0.3,
}

AddonDir = "Interface\\AddOns\\EmsUI"
MediaDir = AddonDir.."\\media"
FontsDir = MediaDir.."\\fonts"
TextureDir = MediaDir.."\\textures"

EUI_TEXTURES = {
  buttons = {
    normal = TextureDir.."\\buttons\\button-normal.tga",
    pushed = TextureDir.."\\buttons\\button-pressed.tga",
    checked = TextureDir.."\\buttons\\button-checked.tga",
  },

  tooltipBorder = TextureDir.."\\tooltip-border.tga",

  roundedBorder = TextureDir.."\\rounded-border.tga",

  healthBar = TextureDir.."\\blizz-inspired.tga",
  powerBar = TextureDir.."\\blizz-inspired.tga",

  classCircles = TextureDir.."\\class\\fabled",

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

CLASS_PORTRAIT_PACKS = {}
local classInfo = FABLED_CLASS_CIRCLES_DATA.class

for iconStyle, data in next, classInfo.styles do
  CLASS_PORTRAIT_PACKS[format('%s%s', classInfo.path, iconStyle)] = format('%s (by %s)', data.name, data.artist)
end

function GetFrameColour()
  if EUIDB.uiMode == 'black' then
    return 0.2, 0.2, 0.2
  elseif EUIDB.uiMode == 'dark' then
    return 0.3, 0.3, 0.3
  else
    return 0.8, 0.8, 0.8
  end
end

function OnEvents(events, callback)
  local frame = CreateFrame("Frame")
  frame:Hide()
  for _, event in ipairs(events) do
    frame:RegisterEvent(event)
  end
  frame:SetScript("OnEvent", callback)
  return frame
end

function OnEvent(event, callback)
  return OnEvents({ event }, callback)
end

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

function StyleIcon(ic)
  ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

EUI_BACKDROP = {
  edgeFile = EUI_TEXTURES.tooltipBorder,
  tileEdge = true,
  edgeSize = 10,
}

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
  border:SetVertexColor(0.1, 0.1, 0.1)
  b.euiBorder = border

  return border
end

function SetEuiBorderColor(border, r, g, b)
  if not r or not g or not b then
    r, g, b = GetFrameColour()
  end

  if border.SetVertexColor then
    border:SetVertexColor(r, g, b)
  else
    border:SetBackdropBorderColor(r, g, b)
  end
end

function SetDefaultFont(textObject, size, outlinestyle)
  if not textObject then return end
  local currSize = select(2, textObject:GetFont())
  if not size then size = currSize end
  if not outlinestyle then outlinestyle = "THINOUTLINE" end

  textObject:SetFont(EUIDB.font, size, outlinestyle)
end

function ModifyFont(textObject, font, size, flags)
  local fontFile, currSize = textObject:GetFont()
  textObject:SetFont(font or fontFile, size or currSize, flags or "THINOUTLINE")
end

function SkinStatusBar(bar)
  if not bar or bar.euiClean then return end

  if bar.BorderMid then
    bar.BorderMid:SetAlpha(0)
    bar.BorderLeft:SetAlpha(0)
    bar.BorderRight:SetAlpha(0)
  end

  bar:SetStatusBarTexture("ui-castingbar-tier4-empower-2x")
  bar:GetStatusBarTexture():SetVertexColor(0.8, 0, 0)

  if bar.BarBG then
    bar.BarBG:Hide()
    bar.BarFrame:Hide()
  end

  -- Border
  local back = bar:CreateTexture(nil, "BACKGROUND")
  back:SetTexture(4505194)
  back:SetAtlas('ui-castingbar-background')
  back:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
  back:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
  DarkenTexture(back)

  bar.back = back

  bar.euiClean = true
end

function GetUnitCharacteristics(unit)
  local reaction = UnitReaction(unit, "player")
  local isEnemy = false
  local isFriend = false
  local isNeutral = false
  local isPlayer = UnitIsPlayer(unit)

  if reaction then
    if reaction < 4 then
      isEnemy = true
    elseif reaction == 4 then
      isNeutral = true
    else
      isFriend = true
    end
  end

  return isEnemy, isFriend, isNeutral, isPlayer, reaction
end

function GetUnitClassColor(unit)
  local class = select(2, UnitClass(unit))

  return RAID_CLASS_COLORS[class]
end

CASTBAR_NO_INTERRUPT_COLOR = { 1, 0, 0.01568627543747425 }

CASTBAR_DELAYED_INTERRUPT_COLOR = { 1, 0.4784314036369324, 0.9568628072738647 }

function GetNameplateUnitInfo(frame, unit)
  unit = unit or frame.unit or frame.displayedUnit
  if not unit then return end

  local info = {}

  info.name = UnitName(unit)
  info.isSelf = UnitIsUnit("player", unit)
  info.isTarget = UnitIsUnit("target", unit)
  info.isFocus = UnitIsUnit("focus", unit)
  info.isPet = UnitIsUnit("pet", unit)
  info.isPlayer = UnitIsPlayer(unit)
  info.isNpc = not info.isPlayer
  info.unitGUID = UnitGUID(unit)
  info.class = info.isPlayer and UnitClassBase(unit) or nil
  info.reaction = UnitReaction(unit, "player")
  info.isEnemy = (info.reaction and info.reaction < 4) and not info.isSelf
  info.isNeutral = (info.reaction and info.reaction == 4) and not info.isSelf
  info.isFriend = (info.reaction and info.reaction >= 5) and not info.isSelf
  info.playerClass = select(2, UnitClass("player"))

  return info
end

local function GetLocalizedSpecs()
  local specs = {}

  for classID = 1, GetNumClasses() do
    local _, class = GetClassInfo(classID)
    local classMale = LOCALIZED_CLASS_NAMES_MALE[class]
    local classFemale = LOCALIZED_CLASS_NAMES_FEMALE[class]

    for specIndex = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
      local specID, specName = GetSpecializationInfoForClassID(classID, specIndex)

      if classMale then
        specs[string.format("%s %s", specName, classMale)] = specID
      end
      if classFemale and classFemale ~= classMale then
        specs[string.format("%s %s", specName, classFemale)] = specID
      end
    end
  end

  return specs
end

local SpecCache = {}
local ALL_SPECS = GetLocalizedSpecs()
function GetSpecID(frame)
  local unit = frame.unit or frame.displayedUnit
  if not UnitIsPlayer(unit) then
    return nil
  end

  local guid = UnitGUID(unit)
  local instanceData = GetInstanceData()

  if SpecCache[guid] and instanceData.isInPvP then
    return SpecCache[guid]
  end

  local tooltipData = C_TooltipInfo.GetUnit(unit)
  if not tooltipData or not tooltipData.guid or not tooltipData.lines then
    return nil
  end

  local tooltipGUID = tooltipData.guid
  if not tooltipGUID then return end

  for _, line in ipairs(tooltipData.lines) do
    if line and line.type == Enum.TooltipDataLineType.None and line.leftText and line.leftText ~= "" then
      local specID = ALL_SPECS[line.leftText]
      if specID then
        SpecCache[tooltipGUID] = specID
        return specID
      end
    end
  end
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

function GetUnitRecord(unit)
  local className, classFileName, classID = UnitClass(unit)

  return {
    id = unit,
    guid = UnitGUID(unit),
    isPlayer = UnitIsPlayer(unit),
    level = UnitEffectiveLevel(unit),
    isWildBattlePet = UnitIsWildBattlePet(unit),
    classID = classID,
    className = className,
    classFileName = classFileName,
    sex = UnitSex(unit),
  }
end
