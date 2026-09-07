--[[
	tooltips.lua
		Tooltip integration for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

local currentPlayer = UnitName("player")

--[[ Local Functions ]]--

local function LinkToID(link)
	if not link then return nil end
	if tonumber(link) then
		return tonumber(link)
	end
	local _, _, id = string.find(link, "item:(%d+)")
	if id then
		return tonumber(id)
	end
	return nil
end

local function AddOwners(frame, id)
	if not (frame and id and BagnonSets and BagnonSets.showForeverTooltips) then return end
	if not (BagnonDB and BagnonDB.GetPlayers) then return end

	for player in BagnonDB.GetPlayers() do
		if player ~= currentPlayer then
			local invCount, bankCount
			if BagnonDB.GetPlayerItemTotals then
				invCount, bankCount = BagnonDB.GetPlayerItemTotals(id, player)
			else
				invCount = BagnonDB.GetItemTotal(id, player, -2)
				for bagID = 0, 4 do
					invCount = invCount + BagnonDB.GetItemTotal(id, player, bagID)
				end

				bankCount = BagnonDB.GetItemTotal(id, player, -1)
				for bagID = 5, 10 do
					bankCount = bankCount + BagnonDB.GetItemTotal(id, player, bagID)
				end
			end

			if (invCount + bankCount) > 0 then
				local tooltipString = player .. " " .. BAGNON_FOREVER_HAS
				if invCount > 0 then
					tooltipString = tooltipString .. " " .. invCount .. " " .. BAGNON_FOREVER_BAGS
				end
				if bankCount > 0 then
					tooltipString = tooltipString .. " " .. bankCount .. " " .. BAGNON_FOREVER_BANK
				end
				frame:AddLine(tooltipString, 1, 1, 0)
			end
		end
	end
	frame:Show()
end

-- Cross-Addon Suite Synergy: ItemRack Set Integration
local function AddItemRackSets(frame, link)
	if not (frame and link and Rack and Rack.GetSetsWithItem) then return end
	local sets = Rack.GetSetsWithItem(link)
	if sets then
		frame:AddLine("ItemRack: " .. sets, 0.2, 0.8, 1.0)
		frame:Show()
	end
end

-- Cross-Addon Suite Synergy: TrinketMenu Queue Integration
local function AddTrinketMenuQueue(frame, link)
	if not (frame and link and TrinketMenu and TrinketMenu.CombatQueue) then return end
	local _, _, itemName = string.find(link, "%[(.+)%]")
	if not itemName then return end
	if TrinketMenu.CombatQueue[0] == itemName then
		frame:AddLine("TrinketMenu: Queued (Top Slot)", 1.0, 0.82, 0.0)
		frame:Show()
	elseif TrinketMenu.CombatQueue[1] == itemName then
		frame:AddLine("TrinketMenu: Queued (Bottom Slot)", 1.0, 0.82, 0.0)
		frame:Show()
	end
end

--[[ Function Hooks ]]--

local Blizz_GameTooltip_SetBagItem = GameTooltip.SetBagItem
GameTooltip.SetBagItem = function(self, bag, slot)
	Blizz_GameTooltip_SetBagItem(self, bag, slot)
	local link = GetContainerItemLink(bag, slot)
	AddOwners(self, LinkToID(link))
	AddItemRackSets(self, link)
	AddTrinketMenuQueue(self, link)
end

local Blizz_GameTooltip_SetInventoryItem = GameTooltip.SetInventoryItem
GameTooltip.SetInventoryItem = function(self, unit, slot)
	Blizz_GameTooltip_SetInventoryItem(self, unit, slot)
	local link = GetInventoryItemLink(unit, slot)
	AddOwners(self, LinkToID(link))
	AddItemRackSets(self, link)
	AddTrinketMenuQueue(self, link)
end

local Bliz_GameTooltip_SetLootItem = GameTooltip.SetLootItem
GameTooltip.SetLootItem = function(self, slot)
	Bliz_GameTooltip_SetLootItem(self, slot)
	AddOwners(self, LinkToID(GetLootSlotLink(slot)))
end

local Bliz_SetHyperlink = GameTooltip.SetHyperlink
GameTooltip.SetHyperlink = function(self, link, count)
	Bliz_SetHyperlink(self, link, count)
	AddOwners(self, LinkToID(link))
	AddItemRackSets(self, link)
	AddTrinketMenuQueue(self, link)
end

local Bliz_ItemRefTooltip_SetHyperlink = ItemRefTooltip.SetHyperlink
ItemRefTooltip.SetHyperlink = function(self, link, count)
	Bliz_ItemRefTooltip_SetHyperlink(self, link, count)
	AddOwners(self, LinkToID(link))
	AddItemRackSets(self, link)
end

local Bliz_GameTooltip_SetLootRollItem = GameTooltip.SetLootRollItem
GameTooltip.SetLootRollItem = function(self, rollID)
	Bliz_GameTooltip_SetLootRollItem(self, rollID)
	AddOwners(self, LinkToID(GetLootRollItemLink(rollID)))
end

local Bliz_GameTooltip_SetAuctionItem = GameTooltip.SetAuctionItem
GameTooltip.SetAuctionItem = function(self, type, index)
	Bliz_GameTooltip_SetAuctionItem(self, type, index)
	AddOwners(self, LinkToID(GetAuctionItemLink(type, index)))
end

--[[ Money Frame Tooltip ]]--

-- Alters the tooltip of bagnon moneyframes to show total gold across all characters on the current realm
function BagnonFrameMoney_OnEnter(self)
	local f = self or this
	if not f then return end

	if f:GetLeft() and f:GetLeft() > (UIParent:GetRight() / 2) then
		GameTooltip:SetOwner(f, "ANCHOR_LEFT")
	else
		GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
	end
	GameTooltip:SetText(string.format(BAGNON_FOREVER_MONEY_ON_REALM, GetRealmName()))

	local money = 0
	if BagnonDB and BagnonDB.GetPlayers then
		for player in BagnonDB.GetPlayers() do
			money = money + BagnonDB.GetMoney(player)
		end
	end

	SetTooltipMoney(GameTooltip, money)
	GameTooltip:Show()
end