--[[
	spot.lua
		Scripts for Bagnon_Spot, which provides filtering functionality for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.2+, UnitXP SP3, DXVK
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

--[[ Search Functions ]]--

function BagnonSpot_Search(text)
	if text and text ~= "" then
		nameFilter = string.lower(text)
	else
		nameFilter = nil
	end

	if Bagnon and Bagnon:IsShown() then
		BagnonFrame_Generate(Bagnon)
	end
	if Banknon and Banknon:IsShown() then
		BagnonFrame_Generate(Banknon)
	end
end

function BagnonSpot_ClearSearch()
	nameFilter = nil
	table.wipe(lowerNameCache)
	if BagnonSpot and BagnonSpot.ClearHighlightText then
		BagnonSpot:ClearHighlightText()
	end

	if Bagnon and Bagnon:IsShown() then
		BagnonFrame_Generate(Bagnon)
	end
	if Banknon and Banknon:IsShown() then
		BagnonFrame_Generate(Banknon)
	end
end

--[[ Function Overrides ]]--

BagnonFrame_OnDoubleClick = function(frame)
	if arg1 == "LeftButton" then
		BagnonSpot:Hide()
		BagnonSpot.frame = frame

		BagnonSpot:ClearAllPoints()
		BagnonSpot:SetPoint("TOPLEFT", frame:GetName() .. "Title", "TOPLEFT", -2, 1)
		BagnonSpot:SetPoint("BOTTOMRIGHT", frame:GetName() .. "Title", "BOTTOMRIGHT", 4, -1)
		BagnonSpot:Show()
	end
end

local function ToItemID(hyperLink)
	if hyperLink then
		local _, _, w = string.find(hyperLink, "item:(%d+)")
		return w or hyperLink
	end
end

-- Darkens items we're not searching for
local oBagnonItem_Update = BagnonItem_Update
BagnonItem_Update = function(item)
	oBagnonItem_Update(item)

	if nameFilter then
		local link
		if item.isLink then
			if BagnonDB then
				link = BagnonDB.GetItemData(item:GetParent():GetParent().player, item:GetParent():GetID(), item:GetID())
			end
		else
			link = ToItemID(GetContainerItemLink(item:GetParent():GetID(), item:GetID()))
		end

		if link then
			local lowerName = GetLowerItemName(link)
			if lowerName and not string.find(lowerName, nameFilter, 1, true) then
				item:SetAlpha(item:GetParent():GetParent():GetAlpha() / 3)
			else
				item:SetAlpha(item:GetParent():GetParent():GetAlpha())
			end
		end
	else
		item:SetAlpha(item:GetParent():GetParent():GetAlpha())
	end
end

local oBagnonFrame_OnHide = BagnonFrame_OnHide
BagnonFrame_OnHide = function()
	oBagnonFrame_OnHide()

	if BagnonSpot:IsVisible() and BagnonSpot.frame == this then
		BagnonSpot:Hide()
	end
end

local oBagnonFrame_OnEnter = BagnonFrame_OnEnter
BagnonFrame_OnEnter = function()
	oBagnonFrame_OnEnter()

	if BagnonSets.showTooltips then
		GameTooltip:AddLine(BAGNON_SPOT_TOOLTIP)
		GameTooltip:Show()
	end
end