--------------------------------------
-- Shows dampening display in arena --
--------------------------------------
local frame = CreateFrame("Frame", "Dampening_Display", UIParent, "UIWidgetTemplateIconAndText")
local dampeningtext = C_Spell.GetSpellInfo(110310).name
local widgetSetID = C_UIWidgetManager.GetTopCenterWidgetSetID()
local widgetSetInfo = C_UIWidgetManager.GetWidgetSetInfo(widgetSetID)
local C_Commentator_GetDampeningPercent = C_Commentator.GetDampeningPercent

frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetPoint(UIWidgetTopCenterContainerFrame.verticalAnchorPoint, UIWidgetTopCenterContainerFrame,
	UIWidgetTopCenterContainerFrame.verticalRelativePoint, 0, widgetSetInfo.verticalPadding)
frame.Text:SetParent(frame)
frame:SetWidth(200)
frame.Text:SetAllPoints()
frame.Text:SetJustifyH("CENTER")

function frame:UNIT_AURA()
	local percentage = C_Commentator_GetDampeningPercent()
	if percentage and percentage > 0 then
		if not self:IsShown() then
			self:Show()
		end
		if self.dampening ~= percentage then
			self.dampening = percentage
			self.Text:SetText(dampeningtext .. ": " .. percentage .. "%")
		end
	elseif self:IsShown() then
		self:Hide()
	end
end

function frame:PLAYER_ENTERING_WORLD()
	local instanceInfo = GetInstanceData()
	if instanceInfo.isInArena and EUIDB.dampeningDisplay then
		self:RegisterUnitEvent("UNIT_AURA", "player")
	else
		self:UnregisterEvent("UNIT_AURA")
		self:Hide()
	end
end
