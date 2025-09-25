OnPlayerLogin(function()
  StatsFrame = CreateFrame("Frame", "StatsFrame", UIParent)
  StatsFrame:ClearAllPoints()

  local layout = GetDBLayout()
  StatsFrame:SetPoint(layout.statsframe.point, UIParent, layout.statsframe.point, layout.statsframe.x, layout.statsframe.y)

  local fontSize = 13
  local color = GetUnitHealthColor("player")

  local function status()
    local function getFPS() return "|c00ffffff" .. floor(GetFramerate()) .. "|r fps" end

    local function getLatency() return "|c00ffffff" .. select(4, GetNetStats()) .. "|r ms" end

    local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    local function getMovementSpeed()
      local speed = 0
      if isGliding then
        speed = forwardSpeed and (forwardSpeed / BASE_MOVEMENT_SPEED * 100)
      else
        speed = (GetUnitSpeed("player") / BASE_MOVEMENT_SPEED * 100)
      end

      return "|c00ffffff" .. string.format("%d", speed) .. "%|r speed"
    end

    local result = {}
    table.insert(result, getFPS())
    table.insert(result, getLatency())

    if EUIDB.enableStatsSpeed then
      table.insert(result, getMovementSpeed())
    end

    return table.concat(result, " ")
  end

  StatsFrame:SetWidth(50)
  StatsFrame:SetHeight(fontSize)
  StatsFrame.text = StatsFrame:CreateFontString(nil, "BACKGROUND")
  StatsFrame.text:SetPoint("CENTER", StatsFrame)
  StatsFrame.text:SetFont(EUIDB.font, fontSize, "THINOUTLINE")
  StatsFrame.text:SetShadowOffset(1, -1)
  StatsFrame.text:SetShadowColor(0, 0, 0)
  StatsFrame.text:SetTextColor(color.r, color.g, color.b)

  local lastUpdate = 0

  local function update(self, elapsed)
    if not EUIDB.enableStatsFrame then
      if self:IsShown() then
        self:Hide()
      end
      return
    end

    lastUpdate = lastUpdate + elapsed
    if lastUpdate > 0.2 then
      lastUpdate = 0
      self.text:SetText(status())
      self:SetWidth(self.text:GetStringWidth())
      self:SetHeight(self.text:GetStringHeight())
    end
  end

  StatsFrame:SetScript("OnUpdate", update)
end)
