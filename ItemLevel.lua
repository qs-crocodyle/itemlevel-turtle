--Modified from S_ItemTip, a Chinese addon, 20250502

local EquipSoltList = {
	INVTYPE_2HWEAPON,
	-- INVTYPE_BODY,
	INVTYPE_CHEST,
	INVTYPE_CLOAK,
	INVTYPE_FEET,
	INVTYPE_FINGER,
	INVTYPE_HAND,
	INVTYPE_HEAD,
	INVTYPE_HOLDABLE,
	INVTYPE_LEGS,
	INVTYPE_NECK,
	INVTYPE_RANGED,
	INVTYPE_RELIC,
	INVTYPE_ROBE,
	INVTYPE_SHIELD,
	INVTYPE_SHOULDER,
	-- INVTYPE_TABARD,
	INVTYPE_TRINKET,
	INVTYPE_WAIST,
	INVTYPE_WEAPON,
	INVTYPE_WEAPONMAINHAND,
	INVTYPE_WEAPONOFFHAND,
	INVTYPE_WRIST,
	"Gun",
	"Crossbow",
	"Wand",
	"Thrown",
}

local function IsEquip()
	if ItemRefTooltip:IsVisible() then
		for i = 2,5 do
			local EquipText = getglobal("ItemRefTooltipTextLeft"..i):GetText()
			for _, equip in pairs(EquipSoltList) do
				if EquipText == equip then
					return true
				end
			end
		end
	else
		for i = 2,5 do
			local EquipText = getglobal("GameTooltipTextLeft"..i):GetText()
			for _, equip in pairs(EquipSoltList) do
				if EquipText == equip then
					return true
				end
			end
		end	
	end
	
	return false
end

local function Add_ItemLevelLine(itemLevel)
	if itemLevel > 0 then
		if ItemRefTooltip:IsVisible() then
			-- ItemRefTooltip:AddLine("ItemLevel: " .. itemLevel, 1, 1, 0)
			ItemRefTooltip:Show()
		else
			GameTooltip:AddLine("ItemLevel: " .. itemLevel, 1, 1, 0)
			GameTooltip:Show()
		end
	end
end

ItemLevel = CreateFrame("Frame" , "ItemLevelTooltip", GameTooltip)
ItemLevel:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ItemLevel:SetScript("OnEvent", function()
	local ilvl = this:ScanUnit("mouseover")
	if ilvl and ilvl > 0 then
		GameTooltip:AddLine("ItemLevel: " .. ilvl, 1, 1, 0)
		GameTooltip:Show()
	end
end)

ItemLevel:SetScript("OnShow", function()
	if GameTooltip.itemLink then
		local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+)")
		local itemLevel = ItemLevel.ilvl_database[tonumber(itemID)] or 0
		if IsEquip() and itemID then
			if itemLevel == 0 then -- search by name and get new item level
				local itemName, _, _ = GetItemInfo(itemID)
				for realID, engName in pairs(ItemLevel.item_database) do
					if engName == itemName then
						local newItemLevel = ItemLevel.ilvl_database[realID] or 0
						itemLevel = newItemLevel
						break
					end
				end
			end 
			Add_ItemLevelLine(itemLevel)
		end
	end
end)

ItemLevel:SetScript("OnHide", function()
	GameTooltip.itemLink = nil
end)

hooksecurefunc("SetItemRef", function(link, button)
	if ItemRefTooltip:IsVisible() then
		local _, _, itemID = string.find(link, "item:(%d+)")
		local itemLevel = ItemLevel.ilvl_database[tonumber(itemID)] or 0
		Add_ItemLevelLine(itemLevel)
	end
end)

if IsAddOnLoaded("StatCompare") then
	StatCompareSelfFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	StatCompareSelfFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	StatCompareSelfFrame:RegisterEvent("BAG_UPDATE")
	StatCompareSelfFrame:SetScript("OnEvent", function()
		local ilvl = ItemLevel:ScanUnit("player")
		if ilvl and ilvl > 0 then
			PlayerItemGS:SetText("ItemLevel: " .. ilvl)
			PlayerItemGS:SetTextColor(1, 1, 0)
		else
			PlayerItemGS:SetText()
		end
	end)
end

-- target inspect frame
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

    local ilvl = ItemLevel:ScanUnit("target")
    if ilvl and ilvl > 0 then
        ItemLevel.Inspect.text:SetText("ItemLevel: " .. ilvl)
        ItemLevel.Inspect.text:SetTextColor(1, 1, 0)
    end
	if IsAddOnLoaded("StatCompare") then
		if ilvl and ilvl > 0 then
			TargetItemGS:SetText("ItemLevel: " .. ilvl)
			TargetItemGS:SetTextColor(1, 1, 0)
		else
			TargetItemGS:SetText()
		end
	end
end

-- -- player inspect frame
ItemLevel.CharacterFrame = CreateFrame("Frame", nil, CharacterModelFrame)
ItemLevel.CharacterFrame:SetFrameStrata("HIGH")
ItemLevel.CharacterFrame:SetWidth(200)
ItemLevel.CharacterFrame:SetHeight(50)
ItemLevel.CharacterFrame:SetPoint("BOTTOM", 0, 0)
ItemLevel.CharacterFrame.text = ItemLevel.CharacterFrame:CreateFontString("Status", "LOW", "GameFontNormal")
ItemLevel.CharacterFrame.text:SetPoint("CENTER", 0, 0)

ItemLevel.CharacterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ItemLevel.CharacterFrame:RegisterEvent("UNIT_NAME_UPDATE")
ItemLevel.CharacterFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
ItemLevel.CharacterFrame:RegisterEvent("BAG_UPDATE")
ItemLevel.CharacterFrame:SetScript("OnEvent", function()
    ilvl = ItemLevel:ScanUnit("player")
    if ilvl and ilvl > 0 then
        ItemLevel.CharacterFrame.text:SetText("ItemLevel: " .. ilvl)
        ItemLevel.CharacterFrame.text:SetTextColor(1, 1, 0)
    end
end)

function ItemLevel:Calculate(rarity, ilvl)
	if not rarity then rarity = 0 end
	
	local qualityScale = 1
	if rarity == 5 then
		qualityScale = 1.3
	elseif rarity == 4 then
		qualityScale = 1.0
	elseif rarity == 3 then
		qualityScale = 0.85
	elseif rarity == 2 then
		qualityScale = 0.6
	elseif rarity == 1 then
		qualityScale = 0.25
	end
	
	return ilvl * qualityScale
end

function ItemLevel:ScanUnit(unit)
    if not UnitIsPlayer(unit) then return nil end

    local ilvl = 0
    local _, class = UnitClass(unit)
    local isHunter = (class == "HUNTER")
    local hasMainHand = (GetInventoryItemLink(unit, 16) ~= nil)
    local hasOffhand = (GetInventoryItemLink(unit, 17) ~= nil)

    local slotCoefficients = {
        [1] = 1,
        [2] = 0.5625,
        [3] = 0.75,
        [5] = 1,
        [6] = 0.5625,
        [7] = 0.75,
        [8] = 0.75,
        [9] = 0.75,
        [10] = 0.75,
        [11] = 0.5625,
        [12] = 0.5625,
        [13] = 0.5625,
        [14] = 0.5625,
        [15] = 0.5625,
        [16] = 1,
        [17] = 1,
        [18] = 0.3164,
    }
	-- 0 = ammo
	-- 1 = head
	-- 2 = neck
	-- 3 = shoulder
	-- 4 = shirt
	-- 5 = chest
	-- 6 = waist
	-- 7 = legs
	-- 8 = feet
	-- 9 = wrist
	-- 10 = hands
	-- 11 = finger 1
	-- 12 = finger 2
	-- 13 = trinket 1
	-- 14 = trinket 2
	-- 15 = back
	-- 16 = main hand
	-- 17 = off hand
	-- 18 = ranged
	-- 19 = tabard
    for i = 1, 19 do
        if i ~= 4 and i ~= 19 then
            local itemLink = GetInventoryItemLink(unit, i)
            if itemLink then
                local _, _, itemID = string.find(itemLink, "item:(%d+)")
                local itemLevel = ItemLevel.ilvl_database[tonumber(itemID)] or 0
                local itemName, _, itemRarity = GetItemInfo(itemID)

                if itemLevel == 0 then              
                    for realID, engName in pairs(ItemLevel.item_database) do
                        if engName == itemName then
                            local newItemLevel = ItemLevel.ilvl_database[realID] or 0
                            itemLevel = newItemLevel
                            break
                        end
                    end
                end

                local coef = slotCoefficients[i] or 1

                if i == 16 then
					local _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemID)
					local itemName = GetItemInfo(itemID)
					if equipSlot == "INVTYPE_2HWEAPON" then
                        coef = isHunter and 1 or 2.6836
                    else
                        coef = isHunter and 0.5 or 1.6836
                    end
                elseif i == 17 then
                    coef = isHunter and 0.5 or 1
                elseif i == 18 then
                    coef = isHunter and 2 or 0.3164
                end

                local itemScore = ItemLevel:Calculate(itemRarity, itemLevel)
                if itemScore then
                    ilvl = ilvl + (itemScore * coef)
                end
            end
        end
    end

    local divisor = 17
    ilvl = tonumber(string.format("%0.1f", (ilvl / divisor) * 1.355))
  
    if ilvl ~= 0 then return ilvl else return nil end
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

local HookSetBagItem = GameTooltip.SetBagItem
function GameTooltip.SetBagItem(self, container, slot)
	GameTooltip.itemLink = GetContainerItemLink(container, slot)
	_, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
	return HookSetBagItem(self, container, slot)
end

local HookSetQuestLogItem = GameTooltip.SetQuestLogItem
function GameTooltip.SetQuestLogItem(self, itemType, index)
	GameTooltip.itemLink = GetQuestLogItemLink(itemType, index)
	if not GameTooltip.itemLink then return end
	return HookSetQuestLogItem(self, itemType, index)
end

local HookSetQuestItem = GameTooltip.SetQuestItem
function GameTooltip.SetQuestItem(self, itemType, index)
	GameTooltip.itemLink = GetQuestItemLink(itemType, index)
	return HookSetQuestItem(self, itemType, index)
end

local HookSetLootItem = GameTooltip.SetLootItem
function GameTooltip.SetLootItem(self, slot)
	GameTooltip.itemLink = GetLootSlotLink(slot)
	HookSetLootItem(self, slot)
end

local HookSetInboxItem = GameTooltip.SetInboxItem
function GameTooltip.SetInboxItem(self, mailID, attachmentIndex)
	local itemName, itemTexture, inboxItemCount, inboxItemQuality = GetInboxItem(mailID)
	GameTooltip.itemLink = ItemLevel:GetItemLinkByName(itemName)
	return HookSetInboxItem(self, mailID, attachmentIndex)
end

local HookSetInventoryItem = GameTooltip.SetInventoryItem
function GameTooltip.SetInventoryItem(self, unit, slot)
	GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
	return HookSetInventoryItem(self, unit, slot)
end

local HookSetLootRollItem = GameTooltip.SetLootRollItem
function GameTooltip.SetLootRollItem(self, id)
	GameTooltip.itemLink = GetLootRollItemLink(id)
	return HookSetLootRollItem(self, id)
end

local HookSetMerchantItem = GameTooltip.SetMerchantItem
function GameTooltip.SetMerchantItem(self, merchantIndex)
	GameTooltip.itemLink = GetMerchantItemLink(merchantIndex)
	return HookSetMerchantItem(self, merchantIndex)
end

local HookSetCraftItem = GameTooltip.SetCraftItem
function GameTooltip.SetCraftItem(self, skill, slot)
	GameTooltip.itemLink = GetCraftReagentItemLink(skill, slot)
	return HookSetCraftItem(self, skill, slot)
end

local HookSetCraftSpell = GameTooltip.SetCraftSpell
function GameTooltip.SetCraftSpell(self, slot)
	GameTooltip.itemLink = GetCraftItemLink(slot)
	return HookSetCraftSpell(self, slot)
end

local HookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
	if reagentIndex then
		GameTooltip.itemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
	else
		GameTooltip.itemLink = GetTradeSkillItemLink(skillIndex)
	end
	return HookSetTradeSkillItem(self, skillIndex, reagentIndex)
end

local HookSetAuctionItem = GameTooltip.SetAuctionItem
function GameTooltip.SetAuctionItem(self, atype, index)
  local itemName, _, itemCount = GetAuctionItemInfo(atype, index)
  GameTooltip.itemCount = itemCount
  GameTooltip.itemLink = ItemLevel:GetItemLinkByName(itemName)
  return HookSetAuctionItem(self, atype, index)
end

local HookSetAuctionSellItem = GameTooltip.SetAuctionSellItem
function GameTooltip.SetAuctionSellItem(self)
	local itemName, _, itemCount = GetAuctionSellItemInfo()
	GameTooltip.itemCount = itemCount
	GameTooltip.itemLink = ItemLevel:GetItemLinkByName(itemName)
	return HookSetAuctionSellItem(self)
end

local HookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
function GameTooltip.SetTradePlayerItem(self, index)
	GameTooltip.itemLink = GetTradePlayerItemLink(index)
	return HookSetTradePlayerItem(self, index)
end

local HookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
function GameTooltip.SetTradeTargetItem(self, index)
	GameTooltip.itemLink = GetTradeTargetItemLink(index)
	return HookSetTradeTargetItem(self, index)
end