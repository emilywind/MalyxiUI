-- If the camera isn't reset OnShow, it'll show the entire character instead of just the head. Silly, is it not? :D
local function resetCamera(portraitModel)
  portraitModel:SetPortraitZoom(1)
end

local function resetGUID(portraitModel)
  portraitModel.guid = nil
end

local function makePortraitBG(frame)
  frame.portraitBG = CreateFrame("Frame", nil, frame)
  frame.portraitBG:SetFrameLevel(frame:GetFrameLevel() - 1)
  frame.portraitBG:SetFrameStrata("background")
  frame.portraitBG:SetAllPoints(frame.portrait)
  local backLayer = frame.portraitBG:CreateTexture("backLayer", "BACKGROUND", nil, -1)
	backLayer:SetTexture(EUI_TEXTURES.circleTexture)
  SetVertexColor(backLayer, COLOR_BLACK)
  backLayer:SetAllPoints(frame.portraitBG)
  frame.portraitBG.backlayer = backLayer
end

local function make3DPortraitFG(frame)
  local portraitFG = CreateFrame("Frame", nil, frame)
  portraitFG:SetFrameLevel(frame:GetFrameLevel())
  portraitFG:SetFrameStrata("LOW")
  portraitFG:SetAllPoints(frame.portrait)
  portraitFG:SetPoint("TOPLEFT", frame.portrait, "TOPLEFT", 0, -1)
  portraitFG:SetPoint("BOTTOMRIGHT", frame.portrait, "BOTTOMRIGHT", 0, -1)

  local foreground = portraitFG:CreateTexture("foreLayer", "OVERLAY", nil)
  foreground:SetTexture(EUI_TEXTURES.portraitModelFront)
  SetVertexColor(foreground, COLOR_BLACK)
  foreground:SetAllPoints(portraitFG)

  portraitFG.forelayer = foreground
  frame.portraitFG = portraitFG
end

local euiPortraits = {}

local function updateEUIPortrait(frame)
  if not frame or not frame.portrait then return end

  local unit = frame.unit
  if not euiPortraits[unit] then
    euiPortraits[unit] = frame
  end
  local info = GetUnitInfo(unit)
  if not info.exists then return end

  local portraitModel = frame.portraitModel
  local portraitClass = frame.portraitClass
  local portrait = frame.portrait

  portrait:Show()

  if not frame.portraitFG then
    make3DPortraitFG(frame)
  end
  frame.portraitFG:Hide()

  if portraitModel then
    portraitModel:Hide()
  end

  if portraitClass then
    portraitClass:Hide()
  end

  if EUIDB.portraitStyle == "default" then return end

  if not frame.portraitBG then
    makePortraitBG(frame)
  end

  if EUIDB.portraitStyle == "class" and info.classFileName then
    if not portraitClass then
      local mask = portrait:GetMaskTexture(1)
      portraitClass = frame:CreateTexture(nil, "ARTWORK")
      portraitClass:SetAllPoints(portrait)
      portraitClass:AddMaskTexture(mask)
      frame.portraitClass = portraitClass
    end
    portraitClass:SetTexture(EUIDB.classPortraitPack)
    portraitClass:SetTexCoord(unpack(FABLED_CLASS_CIRCLES_DATA.class[info.classFileName].texCoords))
    portraitClass:Show()
    portrait:Hide()
  elseif EUIDB.portraitStyle == "3D" then
    if not portraitModel then
      portraitModel = CreateFrame("PlayerModel", nil, frame) -- Initialize 3D Model Container
      portraitModel:SetScript("OnShow", resetCamera)
      portraitModel:SetScript("OnHide", resetGUID)
      portraitModel.parent = frame
      portraitModel:SetFrameLevel(0)

      -- Round portraits
      local coeff = 0.14
      local xoff = coeff*portrait:GetWidth()
      local yoff = coeff*portrait:GetHeight()
      portraitModel:SetAllPoints(portrait)
      portraitModel:SetPoint("TOPLEFT", portrait,"TOPLEFT",xoff,-yoff)
      portraitModel:SetPoint("BOTTOMRIGHT",portrait,"BOTTOMRIGHT",-xoff,yoff)
      frame.portraitModel = portraitModel

      -- Add foreground mask
      make3DPortraitFG(frame)
    end

    frame.portraitFG:Show()

    if not info.guid or (unit == 'targettarget' and info.guid == portraitModel.guid) then return end -- Target of Target is spammy and needs this protection

    portraitModel.guid = info.guid

    -- The player is not in range so swap to question mark
    if not info.isVisible or not info.isConnected then
      portraitModel:ClearModel()
      portraitModel:SetModelScale(5.5)
      resetCamera(portraitModel)
      portraitModel:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
    else -- Use animated 3D portrait
      portraitModel:ClearModel()
      portraitModel:SetModelScale(1)
      portraitModel:SetUnit(frame.unit)
      resetCamera(portraitModel)
      portraitModel:SetPosition(0, 0, 0)
      portraitModel:SetAnimation(804)
    end

    portrait:Hide()
    portraitModel:Show()
  end
end

function RefreshEUIPortraits()
  for _, frame in pairs(euiPortraits) do
    updateEUIPortrait(frame)
  end
end

hooksecurefunc("UnitFramePortrait_Update", updateEUIPortrait)
