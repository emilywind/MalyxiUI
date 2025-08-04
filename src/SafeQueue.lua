-- Enhanced version of SafeQueue by Jordon

local SafeQueue = CreateFrame("Frame")
local queueTime = {}
local queue = 0
local justPopped = true

PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.leaveButton.Show = function() end -- Prevent other mods from showing the button
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Em's UI|r: " .. msg)
end

local function PrintTime()
	print(queueTime[queue])
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

	Print(str)
end

SafeQueue:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
SafeQueue:SetScript("OnEvent", function()
	if not EUIDB.safeQueue then return end

	local queued = false
	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "queued" then
			queued = true
			if not queueTime[i] then
				justPopped = true
				queueTime[i] = GetTime()
			end
		elseif status == "confirm" then
			if queueTime[i] then
				queue = i
				PrintTime()
				queueTime[i] = nil
			end
		end
	end

	if not queued and queueTime[1] then queueTime = {} end
end)

SafeQueue:SetScript("OnUpdate", function()
	if not EUIDB.safeQueue then return end

	local timerBar = PVPReadyDialog.timerBar

	if not PVPReadyDialog_Showing(queue) then return end

	if not timerBar then
		timerBar = CreateFrame("StatusBar", nil, PVPReadyDialog)
		timerBar:SetPoint("TOP", PVPReadyDialog, "BOTTOM", 0, -5)
		timerBar:SetSize(194, 14)

		SkinProgressBar(timerBar)

		timerBar.Text = timerBar:CreateFontString(nil, "OVERLAY")
		timerBar.Text:SetFontObject(GameFontHighlight)
		timerBar.Text:SetPoint("CENTER", timerBar, "CENTER")
	end

	local function barUpdate(self)
		local timeLeft = GetBattlefieldPortExpiration(queue)

		if justPopped then
			justPopped = false
			timerBar:SetMinMaxValues(0, timeLeft)
			print(timeLeft)
			timerBar:Show()
		end

		if (timeLeft <= 0) then
			justPopped = true
			self:Hide()
		end

		self:SetValue(timeLeft)
		self.Text:SetFormattedText("%.1f", timeLeft)
	end
	timerBar:SetScript("OnUpdate", barUpdate)

	PVPReadyDialog.timerBar = timerBar
end)
