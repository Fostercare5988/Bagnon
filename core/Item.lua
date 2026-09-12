--[[
	Item.lua
		Functions used by the item slots in Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

--[[ OnX Handlers ]]--

local function OnClick(self, button)
	local b = button or arg1
	BagnonItem_OnClick(self or this, b)
end

local function OnEnter(self)
	BagnonItem_OnEnter(self or this)
end

local function OnLeave(self)
	BagnonItem_OnLeave(self or this)
end

local function OnDragStart(self)
	BagnonItem_OnClick(self or this, "LeftButton", 1)
end

local function OnReceiveDrag(self)
	BagnonItem_OnClick(self or this, "LeftButton", 1)
end

local function OnHide(self)
	BagnonItem_OnHide(self or this)
end

local QUALITY_BORDER_BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 8,
	edgeSize = 16,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- High-luminance, high-contrast palette for clear distinction (Green vs Blue vs Purple)
local ENHANCED_QUALITY_COLORS = {
	[2] = { r = 0.05, g = 1.00, b = 0.15 }, -- Vibrant Emerald Green
	[3] = { r = 0.00, g = 0.70, b = 1.00 }, -- Radiant Electric Sky Blue
	[4] = { r = 0.85, g = 0.20, b = 1.00 }, -- Vivid Neon Purple / Magenta
	[5] = { r = 1.00, g = 0.55, b = 0.00 }, -- Flaming Orange
	[6] = { r = 0.95, g = 0.85, b = 0.40 }, -- Radiant Gold
}

local function GetBorderQualityColor(quality)
	local color = ENHANCED_QUALITY_COLORS[quality]
	if color then
		return color.r, color.g, color.b
	end
	return GetItemQualityColor(quality)
end

function BagnonItem_Create(name, parent)
	--create the button
	local item = CreateFrame("Button", name, parent, "BagnonItemTemplate")
	item:SetAlpha(parent:GetParent():GetAlpha())

	-- Cache child widget references for O(1) access without string concatenation or getglobal lookups
	item.border = getglobal(name .. "Border")
	item.cooldown = getglobal(name .. "Cooldown")
	if item.cooldown and item.cooldown.EnableMouse then
		item.cooldown:EnableMouse(false)
	end
	item.normalTexture = getglobal(name .. "NormalTexture")
	item.iconTexture = getglobal(name .. "IconTexture")
	item.countText = getglobal(name .. "Count")

	-- Native modern rarity border frame
	local qBorder = CreateFrame("Frame", name .. "QualityBorder", item)
	qBorder:SetPoint("TOPLEFT", item, "TOPLEFT", -2, 2)
	qBorder:SetPoint("BOTTOMRIGHT", item, "BOTTOMRIGHT", 2, -2)
	qBorder:SetBackdrop(QUALITY_BORDER_BACKDROP)
	qBorder:EnableMouse(false)
	qBorder:Hide()
	item.qualityBorder = qBorder

	-- Native modern weapon enchant overlay frame
	local overlay = CreateFrame("Frame", name .. "EnchantOverlay", item)
	overlay:SetAllPoints(item)
	overlay:EnableMouse(false)
	if item.GetFrameLevel then
		overlay:SetFrameLevel(item:GetFrameLevel() + 3)
	end

	local iconFrame = CreateFrame("Frame", nil, overlay)
	iconFrame:SetWidth(14)
	iconFrame:SetHeight(14)
	iconFrame:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", -1, -1)

	local iconBg = iconFrame:CreateTexture(nil, "BACKGROUND")
	iconBg:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 0, 0)
	iconBg:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 0, 0)
	iconBg:SetTexture(0, 0, 0, 0.85)

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	overlay.icon = icon
	overlay.iconFrame = iconFrame

	local duration = overlay:CreateFontString(nil, "OVERLAY")
	duration:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
	duration:SetPoint("TOPRIGHT", iconFrame, "BOTTOMRIGHT", 0, -1)
	duration:SetShadowOffset(1, -1)
	duration:SetShadowColor(0, 0, 0, 1)
	duration:SetTextColor(1.0, 1.0, 1.0)
	overlay.duration = duration

	overlay:Hide()
	item.enchantOverlay = overlay

	item:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	item:RegisterForDrag("LeftButton")

	item:SetScript("OnClick", OnClick)
	item:SetScript("OnEnter", OnEnter)
	item:SetScript("OnLeave", OnLeave)
	item:SetScript("OnDragStart", OnDragStart)
	item:SetScript("OnReceiveDrag", OnReceiveDrag)
	item:SetScript("OnHide", OnHide)

	--Fix for AxuItemMenus
	if AxuItemMenus_DropDown then
		item.SplitStack = function(item, split)
			SplitContainerItem(item:GetParent():GetID(), item:GetID(), split)
		end
	end

	return item
end

function BagnonItem_OnClick(item, mouseButton, ignoreModifiers)
	local btn, mb, ign
	if type(item) == "string" or not item then
		btn = this
		mb = item or arg1
		ign = mouseButton
	else
		btn = item or this
		mb = mouseButton or arg1
		ign = ignoreModifiers
	end
	if not btn then return end

	if btn.isLink then
		if btn.hasItem then
			if mb == "LeftButton" then
				if IsControlKeyDown() then
					local itemSlot = btn:GetID()
					local bagID = btn:GetParent():GetID()
					local player = btn:GetParent():GetParent().player

					DressUpItemLink((BagnonDB.GetItemData(player, bagID, itemSlot)))
				elseif IsShiftKeyDown() then
					local itemSlot = btn:GetID()
					local bagID = btn:GetParent():GetID()
					local player = btn:GetParent():GetParent().player

					ChatFrameEditBox:Insert(BagnonDB.GetItemHyperlink(player, bagID, itemSlot))
				end
			end
		end
	else
		ContainerFrameItemButton_OnClick(mb, ign)
	end
end

--[[
	Show tooltip on hover
--]]

function BagnonItem_OnEnter(item)
	--link case
	if item.isLink then
		if item.hasItem then
			GameTooltip:SetOwner(item)

			local itemSlot = item:GetID()
			local bagID = item:GetParent():GetID()
			local player = item:GetParent():GetParent().player

			local link, count = BagnonDB.GetItemData(player, bagID, itemSlot)
			GameTooltip:SetHyperlink(link, count)

			Bagnon_AnchorTooltip(item)
		end
	--normal bag case
	else
		if item:GetParent():GetID() == -1 then
			GameTooltip:SetOwner(item)
			GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(item:GetID()))
		else
			ContainerFrameItemButton_OnEnter(item)
		end

		if not EnhTooltip then
			Bagnon_AnchorTooltip(item)
		end
	end
end

function BagnonItem_OnLeave(item)
	item.updateTooltip = nil
	GameTooltip:Hide()
	ResetCursor()
end

function BagnonItem_OnUpdate(item)
	if GameTooltip:IsOwned(item) then
		BagnonItem_OnEnter(item)
	end
end

function BagnonItem_OnHide(item)
	if item.hasStackSplit and item.hasStackSplit == 1 then
		StackSplitFrame:Hide()
	end
end

--[[
	Update Functions
--]]

-- Update the texture, lock status, and other information about an item
function BagnonItem_Update(item)
	local texture, itemCount, locked, readable, quality

	if Bagnon_IsCachedItem(item) then
		item.isLink = 1

		local itemSlot = item:GetID()
		local bagID = item:GetParent():GetID()
		local player = item:GetParent():GetParent().player

		_, itemCount, texture, quality = BagnonDB.GetItemData(player, bagID, itemSlot)
		BagnonItem_UpdateBorder(item, quality, player)

		item.hasItem = texture and 1 or nil

		--hide cooldown since there isn't one for linked items
		BagnonItem_UpdateCooldown(bagID, item)
		if item.enchantOverlay then
			item.enchantOverlay:Hide()
		end
	else
		item.isLink = nil

		texture, itemCount, locked, _, readable = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		BagnonItem_UpdateBorder(item)

		if texture then
			BagnonItem_UpdateCooldown(item:GetParent():GetID(), item)
			item.hasItem = 1
			BagnonItem_UpdateEnchant(item)
		else
			local cd = item.cooldown or getglobal(item:GetName() .. "Cooldown")
			if cd then cd:Hide() end
			item.hasItem = nil
			if item.enchantOverlay then
				item.enchantOverlay:Hide()
			end
		end

		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
		item.readable = readable
	end

	--update texture and count
	SetItemButtonTexture(item, texture)
	SetItemButtonCount(item, itemCount)
end

local function get_temp_enchant_texture(enchantID, itemName)
	if enchantID and type(C_Item) == "table" and type(C_Item.GetEnchantInfo) == "function" then
		local ok, info = pcall(C_Item.GetEnchantInfo, enchantID)
		if ok and type(info) == "table" and info.spellID and type(C_Spell) == "table" and type(C_Spell.GetSpellTexture) == "function" then
			local tex = C_Spell.GetSpellTexture(info.spellID)
			if tex then return tex end
		end
	end
	local lower = itemName and string.lower(itemName) or ""
	if string.find(lower, "oil") then
		return "Interface\\Icons\\INV_Potion_19"
	elseif string.find(lower, "stone") or string.find(lower, "weight") then
		return "Interface\\Icons\\INV_Stone_SharpeningStone_04"
	end
	return "Interface\\Icons\\Ability_Poisons"
end

local function format_enchant_duration(expirationMs, charges)
	local s = (expirationMs and expirationMs > 0) and math.floor(expirationMs / 1000) or 0
	local timeStr = ""
	if s >= 3600 then
		timeStr = string.format("%dh", math.floor(s / 3600))
	elseif s >= 60 then
		timeStr = string.format("%dm", math.floor(s / 60))
	elseif s > 0 then
		timeStr = string.format("%ds", s)
	end

	local text = timeStr
	local r, g, b = 1.0, 1.0, 1.0
	if charges and charges > 0 and charges <= 5 then
		text = charges .. "c"
		r, g, b = 1.0, 0.4, 0.1
	elseif charges and charges > 0 and charges <= 10 then
		text = (timeStr ~= "") and (timeStr .. "·" .. charges) or (charges .. "c")
		r, g, b = 1.0, 0.7, 0.2
	elseif s > 0 and s < 120 then
		r, g, b = 1.0, 0.2, 0.2
	end

	return text, r, g, b
end

function BagnonItem_UpdateEnchant(item)
	local overlay = item.enchantOverlay
	if not overlay then return end

	local enabled = not BagnonSets or BagnonSets.enchantBadges ~= 0
	if not enabled then
		overlay:Hide()
		return
	end

	local bagID = item:GetParent():GetID()
	local slotID = item:GetID()

	-- Only inspect real player bag slots (0..4), not bank slots (-1, 5..10)
	if not bagID or bagID < 0 or bagID > 4 or not slotID then
		overlay:Hide()
		return
	end

	if not item.hasItem then
		overlay:Hide()
		return
	end

	local itemLink = GetContainerItemLink(bagID, slotID)
	if not itemLink then
		overlay:Hide()
		return
	end

	local itemName, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
	local isWeapon = (itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_2HWEAPON" or
		itemEquipLoc == "INVTYPE_WEAPONMAINHAND" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND")

	if not isWeapon then
		overlay:Hide()
		return
	end

	if type(C_Item) == "table" and type(C_Item.GetItemTempEnchantInfo) == "function" then
		local ok, hasEnchant, expirationMs, charges, enchantID = pcall(C_Item.GetItemTempEnchantInfo, { bagID = bagID, slotIndex = slotID })
		if ok and hasEnchant then
			local tex = get_temp_enchant_texture(enchantID, itemName)
			overlay.icon:SetTexture(tex)
			overlay.iconFrame:Show()

			local text, r, g, b = format_enchant_duration(expirationMs, charges)
			overlay.duration:SetText(text)
			overlay.duration:SetTextColor(r, g, b)
			overlay.duration:Show()
			overlay:Show()
			return
		end
	end

	overlay:Hide()
end

function BagnonItem_UpdateBorder(button, quality, player)
	local bagID = button:GetParent():GetID()
	local slotID = button:GetID()
	local border = button.border or getglobal(button:GetName() .. "Border")
	local qBorder = button.qualityBorder or getglobal(button:GetName() .. "QualityBorder")
	local normalTexture = button.normalTexture or getglobal(button:GetName() .. "NormalTexture")

	-- Legacy blurry circular ActionButton border is retired in favor of native qualityBorder
	if border then
		border:Hide()
	end

	local enabled = BagnonSets and BagnonSets.qualityBorders and BagnonSets.qualityBorders ~= 0

	if enabled then
		if not quality then
			-- Tier 0: ClassicAPI direct CGItem resolution (zero string allocations, 0 GC churn)
			local itemID
			if C_Container and C_Container.GetContainerItemID then
				itemID = C_Container.GetContainerItemID(bagID, slotID)
			end

			if itemID then
				local _, _, q = GetItemInfo(itemID)
				quality = q
			else
				-- Tier 1 fallback: Link extraction / BagnonDB cached data
				local link = player and BagnonDB and BagnonDB.GetItemData(player, bagID, slotID) or GetContainerItemLink(bagID, slotID)
				if link then
					local _, _, rawID = string.find(link, "item:(%d+)")
					if rawID then
						local _, _, q = GetItemInfo(tonumber(rawID))
						quality = q
					else
						local _, _, q = GetItemInfo(link)
						quality = q
					end
				end
			end
		end

		if quality and quality > 1 then
			local red, green, blue = GetBorderQualityColor(quality)
			if qBorder then
				qBorder:SetBackdropBorderColor(red, green, blue, 1.0)
				qBorder:Show()
			end
		elseif qBorder then
			qBorder:Hide()
		end
	elseif qBorder then
		qBorder:Hide()
	end

	--ammo and special bag slot coloring
	if normalTexture then
		if bagID == KEYRING_CONTAINER then
			normalTexture:SetVertexColor(1, 0.7, 0)
		elseif Bagnon_IsAmmoBag(bagID, player) then
			normalTexture:SetVertexColor(1, 1, 0)
		elseif Bagnon_IsProfessionBag(bagID, player) then
			normalTexture:SetVertexColor(0, 1, 0)
		else
			normalTexture:SetVertexColor(1, 1, 1)
		end
	end
end

-- Backward compatibility alias
BagnonItem_UpdateLinkBorder = BagnonItem_UpdateBorder

--Update cooldown
function BagnonItem_UpdateCooldown(container, button)
	local cooldown = button.cooldown or getglobal(button:GetName() .. "Cooldown")
	if not cooldown then return end

	if button.isLink then
		CooldownFrame_SetTimer(cooldown, 0, 0, 0)
	else
		local start, duration, enable = GetContainerItemCooldown(container, button:GetID())
		CooldownFrame_SetTimer(cooldown, start, duration, enable)

		if duration > 0 and enable == 0 then
			SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4)
		end
	end
end