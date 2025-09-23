local function autoRepair()
  local cost, canRepair = GetRepairAllCost()
  if not canRepair then return end

  if cost > 0 then
    local costText = C_CurrencyInfo.GetCoinText(cost)
    local money = GetMoney()
    if EUIDB.autoRepair == 'Guild' and CanGuildBankRepair() then
      local guildMoney = GetGuildBankWithdrawMoney()
      local totalGuildMoney = GetGuildBankMoney()
      if guildMoney > totalGuildMoney then
        guildMoney = totalGuildMoney
      end

      if guildMoney > cost then
        RepairAllItems(1)
        print(format("|cfff07100Repair cost covered by G-Bank: %s|r", costText))
        return
      end
    end

    if money > cost then
      RepairAllItems()
      print(format("|cffead000Repair cost: %s|r", costText))
    else
      print("Not enough gold to cover the repair cost.")
    end
  end
end

local function autoSellGreyItems()
  for bag = 0, 4 do
    for slot = 0, C_Container.GetContainerNumSlots(bag) do
      local link = C_Container.GetContainerItemLink(bag, slot)
      if link then
        local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
        local quality = C_Item.GetItemQuality(itemLocation)
        if quality == Enum.ItemQuality.Poor then
          C_Container.UseContainerItem(bag, slot)
        end
      end
    end
  end
end

OnEvent("MERCHANT_SHOW", function()
  if EUIDB.autoRepair ~= 'Off' and CanMerchantRepair() then
    autoRepair()
  end

  if EUIDB.autoSellGrey then
    autoSellGreyItems()
  end
end)
