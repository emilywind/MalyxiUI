OnPlayerLogin(function()
  local LEM = LibStub('LibEditMode')

  local db = EUIDB
  local inQueue = false

  -- Queue Status Icon
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

  LEM:RegisterCallback('layout', function(layoutName)
    if db.queueicon.x == nil or db.queueicon.y == nil then return end
    QueueStatusButton:SetPoint(db.queueicon.point, UIParent, db.queueicon.point, db.queueicon.x, db.queueicon.y)
  end)

  hooksecurefunc(QueueStatusButton, "UpdatePosition", function()
    if db.queueicon.x == nil or db.queueicon.y == nil then return end

    if C_AddOns.IsAddOnLoaded("EditModeExpanded") then return end
    QueueStatusButton:SetParent(UIParent)
    QueueStatusButton:SetFrameLevel(1)
    QueueStatusButton:SetScale(0.8, 0.8)
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint(db.queueicon.point, UIParent, db.queueicon.point, db.queueicon.x, db.queueicon.y)
  end)
end)
