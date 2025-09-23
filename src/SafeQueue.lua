--------------------------------
--- Em's UI SafeQueue Module ---
--------------------------------
local queueTime = {} -- Use an array so we can store the time for each queue
local queue = 0 -- Current queue index of popped queue
local justPopped = true -- Flag to indicate if the queue just popped

PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.leaveButton.Show = function() end -- Prevent other mods from showing the button
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

local function printTime()
	local secs, str = floor(GetTime() - queueTime[queue]), "Queue popped "
	local mins = floor(secs/60)
	if secs < 1 then
		str = str .. "instantly!"
	else
		str = str .. "after "
		if secs >= 60 then
			str = str .. mins .. "m "
			secs = secs%60
		end
		if secs%60 ~= 0 then
			str = str .. secs .. "s"
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Em's UI|r: " .. str)
end

SafeQueue = OnEvent("UPDATE_BATTLEFIELD_STATUS", function()
	local queued = false
	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "queued" then
			queued = true
			if not queueTime[i] then
				justPopped = true -- Queue just started, so reset this
				queueTime[i] = GetTime()
			end
		elseif status == "confirm" then
			if queueTime[i] then
				queue = i
				printTime()
				queueTime[i] = nil
			end
		end
	end

	if not queued and queueTime[1] then queueTime = {} end
end)

SafeQueue:SetScript("OnUpdate", function()
	if not PVPReadyDialog_Showing(queue) then return end

	local timerBar = PVPReadyDialog.timerBar
	if not timerBar then
		timerBar = CreateTimerBar("EmsUISafeQueueStatusBar", PVPReadyDialog, function(self)
			local timeLeft = GetBattlefieldPortExpiration(queue)

			if justPopped then
				justPopped = false
				self:SetMinMaxValues(0, timeLeft)
			end

			if timeLeft <= 0 then
				justPopped = true
			end

			self:SetValue(timeLeft)
			self.Text:SetFormattedText("%.1f", timeLeft)
		end)

		PVPReadyDialog.timerBar = timerBar
	end
end)
