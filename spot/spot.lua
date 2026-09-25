--[[
	spot.lua
		Scripts for Bagnon_Spot, which provides filtering functionality for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for ClassicAPI v1.15.13+
--]]

local nameFilter
local lowerNameCache = {}

local function GetLowerItemName(link)
	if not link then return nil end
	local cached = lowerNameCache[link]
	if cached then return cached end

	local name = GetItemInfo(link)
	if name then
		local lower = string.lower(name)
		lowerNameCache[link] = lower
		return lower
	end
	return nil
end

local function ToItemID(hyperLink)
	if hyperLink then
		local _, _, w = string.find(hyperLink, "item:(%d+)")
		return w or hyperLink
	end
end

local function UpdateItemFilter(item)
	if not item then return end

	local parent = item:GetParent()
	local parentFrame = parent and parent:GetParent()
	local baseAlpha = (parentFrame and parentFrame:GetAlpha()) or 1

	if nameFilter then
		local link
		if item.isLink then
			if BagnonDB and parentFrame then
				link = BagnonDB.GetItemData(parentFrame.player, parent:GetID(), item:GetID())
			end
		else
			if C_Container and C_Container.GetContainerItemID then
				link = C_Container.GetContainerItemID(parent:GetID(), item:GetID())
			end
			if not link then
				link = ToItemID(GetContainerItemLink(parent:GetID(), item:GetID()))
			end
		end

		if link then
			local lowerName = GetLowerItemName(link)
			if lowerName and not string.find(lowerName, nameFilter, 1, true) then
				item:SetAlpha(baseAlpha / 3)
			else
				item:SetAlpha(baseAlpha)
			end
		else
			item:SetAlpha(baseAlpha)
		end
	else
		item:SetAlpha(baseAlpha)
	end
end

local function UpdateFrameSearch(frame)
	if not frame or not frame:IsShown() then return end
	local items = frame.items
	local size = frame.size or 0
	if items then
		for slot = 1, size do
			local item = items[slot]
			if item and item:IsShown() then
				UpdateItemFilter(item)
			end
		end
	else
		local frameName = frame:GetName()
		for slot = 1, size do
			local item = getglobal(frameName .. "Item" .. slot)
			if item and item:IsShown() then
				UpdateItemFilter(item)
			end
		end
	end
end

--[[ Search Functions ]]--

function BagnonSpot_Search(text)
	if text and text ~= "" then
		nameFilter = string.lower(text)
	else
		nameFilter = nil
	end

	UpdateFrameSearch(Bagnon)
	UpdateFrameSearch(Banknon)
end

function BagnonSpot_ClearSearch()
	nameFilter = nil
	table.wipe(lowerNameCache)
	if BagnonSpot and BagnonSpot.ClearHighlightText then
		BagnonSpot:ClearHighlightText()
	end

	UpdateFrameSearch(Bagnon)
	UpdateFrameSearch(Banknon)
end

--[[ Function Overrides ]]--

BagnonFrame_OnDoubleClick = function(frame, button)
	local btn = button or arg1
	if btn == "LeftButton" then
		BagnonSpot:Hide()
		BagnonSpot.frame = frame

		BagnonSpot:ClearAllPoints()
		BagnonSpot:SetPoint("TOPLEFT", frame:GetName() .. "Title", "TOPLEFT", -2, 1)
		BagnonSpot:SetPoint("BOTTOMRIGHT", frame:GetName() .. "Title", "BOTTOMRIGHT", 4, -1)
		BagnonSpot:Show()
	end
end

-- Darkens items we're not searching for
local oBagnonItem_Update = BagnonItem_Update
BagnonItem_Update = function(item)
	oBagnonItem_Update(item)
	UpdateItemFilter(item)
end

local oBagnonFrame_OnHide = BagnonFrame_OnHide
BagnonFrame_OnHide = function(self)
	oBagnonFrame_OnHide(self)

	local f = self or this
	if BagnonSpot:IsVisible() and BagnonSpot.frame == f then
		BagnonSpot:Hide()
	end
end

local oBagnonFrame_OnEnter = BagnonFrame_OnEnter
BagnonFrame_OnEnter = function(self)
	oBagnonFrame_OnEnter(self)

	if BagnonSets.showTooltips then
		GameTooltip:AddLine(BAGNON_SPOT_TOOLTIP)
		GameTooltip:Show()
	end
end
