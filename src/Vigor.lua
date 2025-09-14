local function skinVigorBar(frame)
  if frame then
    frame:SetDesaturated(true)

    if frame.SetVertexColor then
      ApplyUIMode(frame)
      if not frame.euiHooked then
        hooksecurefunc(frame, "SetVertexColor", function(self)
          if self.changing or self:IsProtected() then return end
          self.changing = true
          ApplyUIMode(self)
          self.changing = false
        end)

        frame.euiHooked = true
      end
    end
  end
end

OnEvents({
  "PLAYER_MOUNT_DISPLAY_CHANGED",
  "PLAYER_ENTERING_WORLD"
}, function()
  C_Timer.After(0.1, function() -- Delay to ensure UIWidgetPowerBarContainerFrame is fully loaded
    for _, child in ipairs({ UIWidgetPowerBarContainerFrame:GetChildren() }) do
      if child.DecorLeft and child.DecorLeft.GetAtlas then
        local atlasName = child.DecorLeft:GetAtlas()
        if atlasName == "dragonriding_vigor_decor" then
          skinVigorBar(child.DecorLeft)
          skinVigorBar(child.DecorRight)
        end
      end
      for _, grandchild in ipairs({ child:GetChildren() }) do
        if grandchild.Frame and grandchild.Frame.GetAtlas then
          local atlasName = grandchild.Frame:GetAtlas()
          if atlasName == "dragonriding_vigor_frame" then
            skinVigorBar(grandchild.Frame)
          end
        end
      end
    end
  end)
end)
