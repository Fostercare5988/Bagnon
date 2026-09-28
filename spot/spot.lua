--[[
	spot.lua
		Scripts for Bagnon_Spot, which provides filtering functionality for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for ClassicAPI v1.15.15+
--]]

local itemInfoCache = {}
local bindingCache = {}

local QUALITY_MAP = {
	["poor"] = 0, ["gray"] = 0, ["grey"] = 0, ["0"] = 0,
	["common"] = 1, ["white"] = 1, ["1"] = 1,
	["uncommon"] = 2, ["green"] = 2, ["2"] = 2,
	["rare"] = 3, ["blue"] = 3, ["3"] = 3,
	["epic"] = 4, ["purple"] = 4, ["4"] = 4,
	["legendary"] = 5, ["orange"] = 5, ["5"] = 5,
	["artifact"] = 6, ["6"] = 6,
}

local SLOT_ALIASES = {
	INVTYPE_HEAD = "head helm helmet",
	INVTYPE_NECK = "neck necklace amulet",
	INVTYPE_SHOULDER = "shoulder shoulders",
	INVTYPE_BODY = "shirt body",
	INVTYPE_CHEST = "chest robe vest tunic",
	INVTYPE_ROBE = "chest robe vest tunic",
	INVTYPE_WAIST = "waist belt",
	INVTYPE_LEGS = "legs pants leggings",
	INVTYPE_FEET = "feet boots shoes",
	INVTYPE_WRIST = "wrist bracer bracers",
	INVTYPE_HAND = "hand hands gloves gauntlets",
	INVTYPE_FINGER = "finger ring",
	INVTYPE_TRINKET = "trinket",
	INVTYPE_CLOAK = "cloak back cape",
	INVTYPE_WEAPON = "weapon one-hand main hand off hand",
	INVTYPE_SHIELD = "shield off hand",
	INVTYPE_2HWEAPON = "weapon two-hand 2h",
	INVTYPE_WEAPONMAINHAND = "weapon main hand mainhand",
	INVTYPE_WEAPONOFFHAND = "weapon off hand offhand",
	INVTYPE_HOLDABLE = "held off hand offhand",
	INVTYPE_RANGED = "ranged bow gun crossbow wand",
	INVTYPE_THROWN = "thrown ranged",
	INVTYPE_RANGEDRIGHT = "ranged wand",
	INVTYPE_RELIC = "relic idol totem libram",
	INVTYPE_BAG = "bag container",
	INVTYPE_TABARD = "tabard",
}

local parsedTokens = {}
local numTokens = 0

local function ParseQuery(text)
	numTokens = 0
	if not text or text == "" then
		return
	end

	local gfind = string.gfind or string.gmatch
	for word in gfind(text, "%S+") do
		local w = string.lower(word)
		local kind, val

		if w == "boe" or w == "bop" then
			kind = "bind"
			val = w
		elseif string.sub(w, 1, 1) == "#" then
			local qStr = string.sub(w, 2)
			local qVal = QUALITY_MAP[qStr]
			if qVal ~= nil then
				kind = "quality"
				val = qVal
			else
				kind = "name"
				val = w
			end
		elseif string.sub(w, 1, 2) == "q:" then
			local qStr = string.sub(w, 3)
			local qVal = QUALITY_MAP[qStr]
			if qVal ~= nil then
				kind = "quality"
				val = qVal
			else
				kind = "name"
				val = w
			end
		elseif string.sub(w, 1, 2) == "t:" or string.sub(w, 1, 5) == "type:" then
			val = (string.sub(w, 1, 2) == "t:") and string.sub(w, 3) or string.sub(w, 6)
			kind = "type"
		elseif string.sub(w, 1, 2) == "s:" or string.sub(w, 1, 5) == "slot:" then
			val = (string.sub(w, 1, 2) == "s:") and string.sub(w, 3) or string.sub(w, 6)
			kind = "slot"
		else
			kind = "name"
			val = w
		end

		if val and val ~= "" then
			numTokens = numTokens + 1
			local t = parsedTokens[numTokens]
			if not t then
				t = {}
				parsedTokens[numTokens] = t
			end
			t.kind = kind
			t.val = val
		end
	end
end

local function GetItemSearchData(link)
	if not link then return nil end
	local cached = itemInfoCache[link]
	if cached then return cached end

	local name, _, quality, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(link)
	if not name then return nil end

	local slotStr = ""
	if itemEquipLoc and itemEquipLoc ~= "" then
		local alias = SLOT_ALIASES[itemEquipLoc] or ""
		local localized = getglobal(itemEquipLoc) or ""
		slotStr = string.lower(itemEquipLoc .. " " .. alias .. " " .. localized)
	end

	local data = {
		name = string.lower(name),
		quality = quality or 0,
		itemType = string.lower(itemType or ""),
		itemSubType = string.lower(itemSubType or ""),
		slotStr = slotStr,
	}
	itemInfoCache[link] = data
	return data
end

local function GetItemBinding(item, link)
	if not link then return nil end
	local cached = bindingCache[link]
	if cached ~= nil then
		return cached
	end

	local scanner = BagnonEnchantTooltip or getglobal("BagnonEnchantTooltip")
	if not scanner then
		scanner = CreateFrame("GameTooltip", "BagnonScanTooltip", UIParent, "GameTooltipTemplate")
		scanner:SetOwner(UIParent, "ANCHOR_NONE")
	end

	scanner:ClearLines()
	if item and not item.isLink then
		local parent = item:GetParent()
		local bagID = parent and parent:GetID()
		local slotID = item:GetID()
		if bagID and slotID then
			if bagID == -1 then
				local invID = BankButtonIDToInvSlotID and BankButtonIDToInvSlotID(slotID)
				if invID then
					scanner:SetInventoryItem("player", invID)
				else
					scanner:SetHyperlink(link)
				end
			else
				scanner:SetBagItem(bagID, slotID)
			end
		else
			scanner:SetHyperlink(link)
		end
	else
		scanner:SetHyperlink(link)
	end

	local binding = false
	local numLines = scanner:NumLines()
	local maxLines = (numLines > 5) and 5 or numLines
	local bindOnEquip = ITEM_BIND_ON_EQUIP or "Binds when equipped"
	local bindOnPickup = ITEM_BIND_ON_PICKUP or "Binds when picked up"
	local soulbound = ITEM_SOULBOUND or "Soulbound"
	local bindOnUse = ITEM_BIND_ON_USE or "Binds when used"

	for i = 2, maxLines do
		local textWidget = getglobal(scanner:GetName() .. "TextLeft" .. i)
		if textWidget then
			local text = textWidget:GetText()
			if text then
				if text == bindOnEquip or text == bindOnUse then
					binding = "boe"
					break
				elseif text == bindOnPickup or text == soulbound then
					binding = "bop"
					break
				end
			end
		end
	end

	bindingCache[link] = binding
	return binding
end

local function MatchesFilter(item, link)
	if numTokens == 0 then return true end
	if not link then return false end

	local data = GetItemSearchData(link)
	if not data then return true end

	for i = 1, numTokens do
		local tok = parsedTokens[i]
		local kind = tok.kind
		local val = tok.val

		if kind == "quality" then
			if data.quality ~= val then
				return false
			end
		elseif kind == "type" then
			if not (string.find(data.itemType, val, 1, true) or string.find(data.subType, val, 1, true)) then
				return false
			end
		elseif kind == "slot" then
			if not string.find(data.slotStr, val, 1, true) then
				return false
			end
		elseif kind == "bind" then
			local bind = GetItemBinding(item, link)
			if bind ~= val then
				return false
			end
		elseif kind == "name" then
			if not string.find(data.name, val, 1, true) then
				return false
			end
		end
	end

	return true
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

	if numTokens > 0 then
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

		if link and MatchesFilter(item, link) then
			item:SetAlpha(baseAlpha)
		else
			item:SetAlpha(baseAlpha / 3)
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
	ParseQuery(text)
	UpdateFrameSearch(Bagnon)
	UpdateFrameSearch(Banknon)
end

function BagnonSpot_ClearSearch()
	numTokens = 0
	if BagnonSpot and BagnonSpot.ClearHighlightText then
		BagnonSpot:ClearHighlightText()
	end

	UpdateFrameSearch(Bagnon)
	UpdateFrameSearch(Banknon)
end

--[[ Function Overrides ]]--

function BagnonSpot_Toggle(frame)
	if not frame then return end
	if BagnonSpot:IsShown() and BagnonSpot.frame == frame then
		BagnonSpot:Hide()
	else
		BagnonSpot:Hide()
		BagnonSpot.frame = frame

		BagnonSpot:ClearAllPoints()
		local frameName = frame:GetName()
		local title = getglobal(frameName .. "Title")
		local searchBtn = getglobal(frameName .. "SearchButton")
		if title and searchBtn then
			BagnonSpot:SetPoint("TOPLEFT", title, "TOPLEFT", -2, 1)
			BagnonSpot:SetPoint("BOTTOMRIGHT", searchBtn, "BOTTOMLEFT", -6, 0)
		else
			BagnonSpot:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -4)
			BagnonSpot:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -40, -22)
		end
		BagnonSpot:Show()
	end
end

BagnonFrame_OnDoubleClick = function(frame, button)
	local btn = button or arg1
	if btn == "LeftButton" then
		BagnonSpot_Toggle(frame)
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
