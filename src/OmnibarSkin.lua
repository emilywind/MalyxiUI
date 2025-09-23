OnPlayerLogin(function()
  if not OmniBar_StartCooldown then return end

  hooksecurefunc('OmniBar_StartCooldown',
  ---@param icon Texture
  function(_, icon)
    ApplyEuiBackdrop(icon)
  end)
end)
