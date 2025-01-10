ItemLevel = CreateFrame( "Frame" , "ItemLevelTooltip", GameTooltip )
ItemLevel:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ItemLevel:SetScript("OnEvent", function()
  ilvl, r, g, b = ItemLevel:ScanUnit("mouseover")
  if ilvl and r and g and b then
    GameTooltip:AddLine("ItemLevel: " .. ilvl, r,g,b)
    GameTooltip:Show()
  end
end)

ItemLevel:SetScript("OnShow", function()
  if GameTooltip.itemLink then
    local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+):%d+:%d+:%d+")
    local _, _, itemLink = string.find(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)");

    if not itemLink then return end

    local ilvl = ItemLevel.Database[tonumber(itemID)] or 0
    local _, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(itemLink)
    local r,g,b = GetItemQualityColor(itemRarity)

    if ilvl and ilvl > 0 then
      GameTooltip:AddLine("ItemLevel: " .. ilvl, r, g, b)
      GameTooltip:Show()
    end
  end
end)

ItemLevel:SetScript("OnHide", function()
  GameTooltip.itemLink = nil
end)

local function GetItemLinkByName(name)
  for itemID = 1, 65536 do
    local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
    if (itemName and itemName == name) then
      local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
      return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
    end
  end
end

-- target inspect
ItemLevelHookInspectUnit = InspectUnit
function InspectUnit(unit)
  ItemLevelHookInspectUnit(unit)
  ItemLevel.Inspect = ItemLevel.Inspect or CreateFrame("Frame", nil, InspectModelFrame)
  ItemLevel.Inspect:SetFrameStrata("HIGH")
  ItemLevel.Inspect:SetWidth(200)
  ItemLevel.Inspect:SetHeight(25)
  ItemLevel.Inspect:SetPoint("BOTTOM", 0, 0)
  ItemLevel.Inspect.text = ItemLevel.Inspect.text or ItemLevel.Inspect:CreateFontString("Status", "TOOLTIP", "GameFontNormal")
  ItemLevel.Inspect.text:SetPoint("CENTER", 0, 0)

  local ilvl, r, g, b = ItemLevel:ScanUnit("target")
  if ilvl and r and g and b then
    ItemLevel.Inspect.text:SetText("ItemLevel: " .. ilvl)
    ItemLevel.Inspect.text:SetTextColor(r, g, b)
  end
end

-- player inspect
ItemLevel.CharacterFrame = CreateFrame("Frame", nil, CharacterModelFrame)
ItemLevel.CharacterFrame:SetFrameStrata("HIGH")
ItemLevel.CharacterFrame:SetWidth(200)
ItemLevel.CharacterFrame:SetHeight(50)
ItemLevel.CharacterFrame:SetPoint("BOTTOM", 0, 0)
ItemLevel.CharacterFrame.text = ItemLevel.CharacterFrame:CreateFontString("Status", "LOW", "GameFontNormal")

ItemLevel.CharacterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ItemLevel.CharacterFrame:RegisterEvent("UNIT_NAME_UPDATE")
ItemLevel.CharacterFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
ItemLevel.CharacterFrame:RegisterEvent("BAG_UPDATE")
ItemLevel.CharacterFrame:SetScript("OnEvent", function()
  ilvl, r, g, b = ItemLevel:ScanUnit("player")
  if ilvl and r and g and b then
    ItemLevel.CharacterFrame.text:SetText("ItemLevel: " .. ilvl)
    ItemLevel.CharacterFrame.text:SetTextColor(r, g, b)
  end
end)

--- BetterCharacterStats compatibility check
if BCSFrame then
  ItemLevel.CharacterFrame.text:SetPoint("CENTER", 0, 20)
else
  ItemLevel.CharacterFrame.text:SetPoint("CENTER", 0, 0)
end

-- functions
function ItemLevel:round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

function ItemLevel:ScanUnit(target)
  if not UnitIsPlayer(target) then return nil end

  local count, ar, ag, ab, ilvl, icount = 0, 0, 0, 0, 0, 0

  for i=1,19 do
    if GetInventoryItemLink(target, i) then
      local _, _, itemID = string.find(GetInventoryItemLink(target, i), "item:(%d+):%d+:%d+:%d+")
      local _, _, itemLink = string.find(GetInventoryItemLink(target, i), "(item:%d+:%d+:%d+:%d+)");

      local cilvl = ItemLevel.Database[tonumber(itemID)] or 0
      local _, _, itemRarity, _, _, _, _, itemSlot, _ = GetItemInfo(itemLink)
      local r, g, b = .2, .2, .2

      if itemRarity and itemSlot then
        r,g,b, _ = GetItemQualityColor(itemRarity)
        ar = ar + r ; ag = ag + g ; ab = ab + b
      end

      count = count + 1
      if cilvl and cilvl > 0 then
        ilvl = ilvl + cilvl
        icount = icount + 1
      end
    end
  end

  local ar = ItemLevel:round(ar / count, 2);
  local ag = ItemLevel:round(ag / count, 2);
  local ab = ItemLevel:round(ab / count, 2);
  local ilvl = ItemLevel:round(ilvl / icount, 1)

  if ilvl ~= 0 then return ilvl, ar, ag, ab else return nil end
end

function ItemLevel:GetItemLinkByName(name)
  for itemID = 1, 25818 do
    local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
    if (itemName and itemName == name) then
      local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
      return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
    end
  end
end

-- hooks
local ItemLevelHookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
  GameTooltip.itemLink = GetContainerItemLink(container, slot)
  _, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
  return ItemLevelHookSetBagItem(self, container, slot)
end

local ItemLevelHookSetQuestLogItem = GameTooltip.SetQuestLogItem
function GameTooltip.SetQuestLogItem(self, itemType, index)
  GameTooltip.itemLink = GetQuestLogItemLink(itemType, index)
  if not GameTooltip.itemLink then return end
  return ItemLevelHookSetQuestLogItem(self, itemType, index)
end

local ItemLevelHookSetQuestItem = GameTooltip.SetQuestItem
function GameTooltip.SetQuestItem(self, itemType, index)
  GameTooltip.itemLink = GetQuestItemLink(itemType, index)
  return ItemLevelHookSetQuestItem(self, itemType, index)
end

local ItemLevelHookSetLootItem = GameTooltip.SetLootItem
function GameTooltip.SetLootItem(self, slot)
  GameTooltip.itemLink = GetLootSlotLink(slot)
  ItemLevelHookSetLootItem(self, slot)
end

local ItemLevelHookSetInboxItem = GameTooltip.SetInboxItem
function GameTooltip.SetInboxItem(self, mailID, attachmentIndex)
  local itemName, itemTexture, inboxItemCount, inboxItemQuality = GetInboxItem(mailID)
  GameTooltip.itemLink = ItemLevel:GetItemLinkByName(itemName)
  return ItemLevelHookSetInboxItem(self, mailID, attachmentIndex)
end

local ItemLevelHookSetInventoryItem = GameTooltip.SetInventoryItem
function GameTooltip.SetInventoryItem(self, unit, slot)
  GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
  return ItemLevelHookSetInventoryItem(self, unit, slot)
end

local ItemLevelHookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
  GameTooltip.itemLink = GetLootRollItemLink(id)
  return ItemLevelHookSetLootRollItem(self, id)
end

local ItemLevelHookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
  GameTooltip.itemLink = GetLootRollItemLink(id)
  return ItemLevelHookSetLootRollItem(self, id)
end

local ItemLevelHookSetMerchantItem = GameTooltip.SetMerchantItem
function GameTooltip.SetMerchantItem(self, merchantIndex)
  GameTooltip.itemLink = GetMerchantItemLink(merchantIndex)
  return ItemLevelHookSetMerchantItem(self, merchantIndex)
end

local ItemLevelHookSetCraftItem = GameTooltip.SetCraftItem
function GameTooltip.SetCraftItem(self, skill, slot)
  GameTooltip.itemLink = GetCraftReagentItemLink(skill, slot)
  return ItemLevelHookSetCraftItem(self, skill, slot)
end

local ItemLevelHookSetCraftSpell = GameTooltip.SetCraftSpell
function GameTooltip.SetCraftSpell(self, slot)
  GameTooltip.itemLink = GetCraftItemLink(slot)
  return ItemLevelHookSetCraftSpell(self, slot)
end

local ItemLevelHookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
  if reagentIndex then
    GameTooltip.itemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
  else
    GameTooltip.itemLink = GetTradeSkillItemLink(skillIndex)
  end
  return ItemLevelHookSetTradeSkillItem(self, skillIndex, reagentIndex)
end

local HookSetAuctionItem = GameTooltip.SetAuctionItem
function GameTooltip.SetAuctionItem(self, atype, index)
  local itemName, _, itemCount = GetAuctionItemInfo(atype, index)
  GameTooltip.itemCount = itemCount
  GameTooltip.itemLink = GetItemLinkByName(itemName)
  return HookSetAuctionItem(self, atype, index)
end

local ItemLevelHookSetAuctionSellItem = GameTooltip.SetAuctionSellItem
function GameTooltip.SetAuctionSellItem(self)
  local itemName, _, itemCount = GetAuctionSellItemInfo()
  GameTooltip.itemCount = itemCount
  GameTooltip.itemLink = ItemLevel:GetItemLinkByName(itemName)
  return ItemLevelHookSetAuctionSellItem(self)
end

local ItemLevelHookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
function GameTooltip.SetTradePlayerItem(self, index)
  GameTooltip.itemLink = GetTradePlayerItemLink(index)
  return ItemLevelHookSetTradePlayerItem(self, index)
end

local ItemLevelHookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
function GameTooltip.SetTradeTargetItem(self, index)
  GameTooltip.itemLink = GetTradeTargetItemLink(index)
  return ItemLevelHookSetTradeTargetItem(self, index)
end

-- database
ItemLevel.Database = {}
