--[[
	tooltips.lua
		Tooltip integration for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for the Enhanced WoW 1.12.1 Client (ClassicAPI v1.15.8+)
--]]

local currentPlayer = UnitName("player")
local function GetCurrentPlayer()
	if not currentPlayer or currentPlayer == "" then
		currentPlayer = UnitName("player")
	end
	return currentPlayer
end

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
	if frame.bagnonOwnersID == id then return end

	local me = GetCurrentPlayer()
	local added = false
	for player in BagnonDB.GetPlayers() do
		if not me or player ~= me then
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
				added = true
			end
		end
	end
	if added then
		frame.bagnonOwnersID = id
		frame:Show()
	end
end

-- Cross-Addon Suite Synergy: ItemRack Set Integration
local function AddItemRackSets(frame, link)
	if not (frame and link and Rack and Rack.GetSetsWithItem) then return end
	if frame.bagnonItemRackLink == link then return end
	local sets = Rack.GetSetsWithItem(link)
	if sets then
		frame.bagnonItemRackLink = link
		frame:AddLine("ItemRack: " .. sets, 0.2, 0.8, 1.0)
		frame:Show()
	end
end

-- Cross-Addon Suite Synergy: TrinketMenu Queue Integration
local function AddTrinketMenuQueue(frame, link)
	if not (frame and link and TrinketMenu and TrinketMenu.GetQueuedSlotForItem) then return end
	if frame.bagnonTrinketLink == link then return end
	local slot = TrinketMenu.GetQueuedSlotForItem(link)
	if slot == 13 then
		frame.bagnonTrinketLink = link
		frame:AddLine("TrinketMenu: Queued (Top Slot)", 1.0, 0.82, 0.0)
		frame:Show()
	elseif slot == 14 then
		frame.bagnonTrinketLink = link
		frame:AddLine("TrinketMenu: Queued (Bottom Slot)", 1.0, 0.82, 0.0)
		frame:Show()
	end
end

--[[ Function Hooks ]]--

local function SafeHookTooltip(tbl, method, hookFunc)
	if not (tbl and tbl[method]) then return end
	hooksecurefunc(tbl, method, hookFunc)
end

local function ResetDecorations(frame)
	frame = frame or this
	frame.bagnonOwnersID = nil
	frame.bagnonItemRackLink = nil
	frame.bagnonTrinketLink = nil
end
local function HookReset(frame, script)
	if frame.HookScript then
		frame:HookScript(script, function() ResetDecorations(frame) end)
	else
		local previous = frame:GetScript(script)
		frame:SetScript(script, function(...)
			if previous then previous(...) end
			ResetDecorations(frame)
		end)
	end
end
HookReset(GameTooltip, "OnTooltipCleared")
HookReset(GameTooltip, "OnHide")
HookReset(ItemRefTooltip, "OnTooltipCleared")
HookReset(ItemRefTooltip, "OnHide")

SafeHookTooltip(GameTooltip, "SetBagItem", function(self, bag, slot)
	local link = GetContainerItemLink(bag, slot)
	if link then
		AddOwners(self, LinkToID(link))
		AddItemRackSets(self, link)
		AddTrinketMenuQueue(self, link)
	end
end)

SafeHookTooltip(GameTooltip, "SetInventoryItem", function(self, unit, slot)
	local link = GetInventoryItemLink(unit, slot)
	if link then
		AddOwners(self, LinkToID(link))
		AddItemRackSets(self, link)
		AddTrinketMenuQueue(self, link)
	end
end)

SafeHookTooltip(GameTooltip, "SetLootItem", function(self, slot)
	local link = GetLootSlotLink(slot)
	if link then
		AddOwners(self, LinkToID(link))
	end
end)

SafeHookTooltip(GameTooltip, "SetHyperlink", function(self, link, count)
	if link then
		AddOwners(self, LinkToID(link))
		AddItemRackSets(self, link)
		AddTrinketMenuQueue(self, link)
	end
end)

SafeHookTooltip(ItemRefTooltip, "SetHyperlink", function(self, link, count)
	if link then
		AddOwners(self, LinkToID(link))
		AddItemRackSets(self, link)
	end
end)

SafeHookTooltip(GameTooltip, "SetLootRollItem", function(self, rollID)
	local link = GetLootRollItemLink(rollID)
	if link then
		AddOwners(self, LinkToID(link))
	end
end)

SafeHookTooltip(GameTooltip, "SetAuctionItem", function(self, type, index)
	local link = GetAuctionItemLink(type, index)
	if link then
		AddOwners(self, LinkToID(link))
	end
end)

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
	if BagnonDB and BagnonDB.GetTotalMoney then
		money = BagnonDB.GetTotalMoney()
	elseif BagnonDB and BagnonDB.GetPlayers then
		for player in BagnonDB.GetPlayers() do
			money = money + BagnonDB.GetMoney(player)
		end
	end

	SetTooltipMoney(GameTooltip, money)
	GameTooltip:Show()
end
