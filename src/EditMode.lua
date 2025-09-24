OnPlayerLogin(function()
  local LEM = LibStub('LibEditMode')

  local inQueue = false

  ---@param layoutName? string
  ---@return table
  local function getLayoutDB(layoutName)
    layoutName = layoutName or EditModeManagerFrame:GetActiveLayoutInfo().layoutName
    local layout = EUIDB.layouts[layoutName]

    if not layout then
      layout = CopyTable(EUIDB.defaultLayout)
      EUIDB.layouts[layoutName] = layout
    end

    return layout
  end

  -- Queue Status Icon
  ---@param layoutName string
  ---@param point string
  ---@param x number
  ---@param y number
  local function queueIconPos(_, layoutName, point, x, y)
    local layout = getLayoutDB(layoutName)

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

  LEM:RegisterCallback('layout',
  ---@param layoutName string
  function(layoutName)
    local layout = getLayoutDB()
    QueueStatusButton:SetPoint(layout.queueicon.point, UIParent, layout.queueicon.point, layout.queueicon.x, layout.queueicon.y)
  end)

  hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
    if C_AddOns.IsAddOnLoaded("EditModeExpanded") then return end

    local layout = getLayoutDB()

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
    local layout = getLayoutDB(layoutName)

    layout.statsframe.point = point
    layout.statsframe.x = x
    layout.statsframe.y = y
  end

  LEM:AddFrame(StatsFrame, statsFramePos)
end)
