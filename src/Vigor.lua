local function skinVigorBar(frame, desaturate, hook)
  if frame then
    if desaturate ~= nil and frame.SetDesaturated then
      frame:SetDesaturated(desaturate)
    end

    if frame.SetVertexColor then
      frame:SetVertexColor(GetFrameColour())
      if hook then
        if not frame.bbfHooked then
          frame.bbfHooked = true

          hooksecurefunc(frame, "SetVertexColor", function(self)
            if self.changing or self:IsProtected() then return end
            self.changing = true
            self:SetDesaturated(desaturate)
            self:SetVertexColor(GetFrameColour())
            self.changing = false
          end)
        end
      end
    end
  end
end

OnPlayerLogin(function()
  if not EUIDB.darkenUi then return end

  for _, child in ipairs({ UIWidgetPowerBarContainerFrame:GetChildren() }) do
    if child.DecorLeft and child.DecorLeft.GetAtlas then
      local atlasName = child.DecorLeft:GetAtlas()
      if atlasName == "dragonriding_vigor_decor" then
        skinVigorBar(child.DecorLeft, 1, true)
        skinVigorBar(child.DecorRight, 1, true)
      end
    end
    for _, grandchild in ipairs({ child:GetChildren() }) do
      -- Check for textures with specific atlas names
      if grandchild.Frame and grandchild.Frame.GetAtlas then
        local atlasName = grandchild.Frame:GetAtlas()
        if atlasName == "dragonriding_vigor_frame" then
          skinVigorBar(grandchild.Frame, 1, true)
        end
      end
    end
  end
end)
