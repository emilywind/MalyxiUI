OnPlayerLogin(function()
  local LEM = LibStub('LibEditMode')

  local db = EUIDB
  local inQueue = false

  -- Queue Status Icon
  ---@param layoutName string
  ---@param point string
  ---@param x number
  ---@param y number
  local function queueIconPos(_, layoutName, point, x, y)
    db.queueicon.point = point
    db.queueicon.x = x
    db.queueicon.y = y
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
    QueueStatusButton:SetPoint(db.queueicon.point, UIParent, db.queueicon.point, db.queueicon.x, db.queueicon.y)
  end)

  hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
    if C_AddOns.IsAddOnLoaded("EditModeExpanded") then return end

    QueueStatusButton:SetParent(UIParent)
    QueueStatusButton:SetFrameLevel(1)
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint(db.queueicon.point, UIParent, db.queueicon.point, db.queueicon.x, db.queueicon.y)
  end)

  ---@param layoutName string
  ---@param point string
  ---@param x number
  ---@param y number
  local function statsFramePos(_, layoutName, point, x, y)
    db.statsframe.point = point
    db.statsframe.x = x
    db.statsframe.y = y
  end

  LEM:AddFrame(StatsFrame, statsFramePos)
end)
