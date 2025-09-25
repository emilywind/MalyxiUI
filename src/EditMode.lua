OnPlayerLogin(function()
  local LEM = LibStub('LibEditMode')

  local inQueue = false

  -- Queue Status Icon
  ---@param layoutName string
  ---@param point string
  ---@param x number
  ---@param y number
  local function queueIconPos(_, layoutName, point, x, y)
    local layout = GetDBLayout(layoutName)

    layout.queueicon.point = point
    layout.queueicon.x = x
    layout.queueicon.y = y
  end

  LEM:AddFrame(QueueStatusButton, queueIconPos)

  LEM:RegisterCallback('enter', function()
    if QueueStatusButton:IsVisible() then
      inQueue = true
    else
      inQueue = false
    end
    QueueStatusButton:Show()
  end)

  LEM:RegisterCallback('exit', function()
    if not inQueue then
      QueueStatusButton:Hide()
    end
  end)

  hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
    if C_AddOns.IsAddOnLoaded("EditModeExpanded") then return end

    local layout = GetDBLayout()

    QueueStatusButton:SetParent(UIParent)
    QueueStatusButton:SetFrameLevel(1)
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint(layout.queueicon.point, UIParent, layout.queueicon.point, layout.queueicon.x, layout.queueicon.y)
  end)

  ---@param layoutName string
  ---@param point string
  ---@param x number
  ---@param y number
  local function statsFramePos(_, layoutName, point, x, y)
    local layout = GetDBLayout(layoutName)

    layout.statsframe.point = point
    layout.statsframe.x = x
    layout.statsframe.y = y
  end

  LEM:AddFrame(StatsFrame, statsFramePos)

  LEM:RegisterCallback('layout',
    ---@param layoutName string
    function(layoutName)
      local layout = GetDBLayout(layoutName)
      QueueStatusButton:ClearAllPoints()
      QueueStatusButton:SetPoint(layout.queueicon.point, UIParent, layout.queueicon.point, layout.queueicon.x,
        layout.queueicon.y)
      StatsFrame:ClearAllPoints()
      StatsFrame:SetPoint(layout.statsframe.point, UIParent, layout.statsframe.point, layout.statsframe.x,
        layout.statsframe.y)
    end
  )
end)
