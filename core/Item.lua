--[[
	Item.lua
		Functions used by the item slots in Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.2+, UnitXP SP3, DXVK
--]]

--[[ OnX Handlers ]]--

local function OnClick()
	BagnonItem_OnClick(arg1)
end

local function OnEnter()
	BagnonItem_OnEnter(this)
end

local function OnLeave()
	BagnonItem_OnLeave(this)
end

local function OnDragStart()
	BagnonItem_OnClick("LeftButton", 1)
end

local function OnReceiveDrag()
	BagnonItem_OnClick("LeftButton", 1)
end

local function OnHide()
	BagnonItem_OnHide(this)
end

function BagnonItem_Create(name, parent)
	--create the button
	local item = CreateFrame("Button", name, parent, "BagnonItemTemplate")
	item:SetAlpha(parent:GetParent():GetAlpha())

	-- Cache child widget references for O(1) access without string concatenation or getglobal lookups
	item.border = getglobal(name .. "Border")
	item.cooldown = getglobal(name .. "Cooldown")
	item.normalTexture = getglobal(name .. "NormalTexture")
	item.iconTexture = getglobal(name .. "IconTexture")
	item.countText = getglobal(name .. "Count")

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

function BagnonItem_OnClick(mouseButton, ignoreModifiers)
	if this.isLink then
		if this.hasItem then
			if mouseButton == "LeftButton" then
				if IsControlKeyDown() then
					local itemSlot = this:GetID()
					local bagID = this:GetParent():GetID()
					local player = this:GetParent():GetParent().player

					DressUpItemLink((BagnonDB.GetItemData(player, bagID, itemSlot)))
				elseif IsShiftKeyDown() then
					local itemSlot = this:GetID()
					local bagID = this:GetParent():GetID()
					local player = this:GetParent():GetParent().player

					ChatFrameEditBox:Insert(BagnonDB.GetItemHyperlink(player, bagID, itemSlot))
				end
			end
		end
	else
		ContainerFrameItemButton_OnClick(mouseButton, ignoreModifiers)
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
	else
		item.isLink = nil

		texture, itemCount, locked, _, readable = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		BagnonItem_UpdateBorder(item)

		if texture then
			BagnonItem_UpdateCooldown(item:GetParent():GetID(), item)
			item.hasItem = 1
		else
			local cd = item.cooldown or getglobal(item:GetName() .. "Cooldown")
			if cd then cd:Hide() end
			item.hasItem = nil
		end

		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
		item.readable = readable
	end

	--update texture and count
	SetItemButtonTexture(item, texture)
	SetItemButtonCount(item, itemCount)
end

function BagnonItem_UpdateBorder(button, quality, player)
	local bagID = button:GetParent():GetID()
	local border = button.border or getglobal(button:GetName() .. "Border")
	local normalTexture = button.normalTexture or getglobal(button:GetName() .. "NormalTexture")

	if BagnonSets.qualityBorders then
		if not quality then
			local link = player and BagnonDB and BagnonDB.GetItemData(player, bagID, button:GetID()) or GetContainerItemLink(bagID, button:GetID())
			if link then
				_, _, quality = GetItemInfo(link)
			end
		end

		if quality and quality > 1 then
			local red, green, blue = GetItemQualityColor(quality)
			if border then
				border:SetVertexColor(red, green, blue, 0.5)
				border:Show()
			end
		elseif border then
			border:Hide()
		end
	elseif border then
		border:Hide()
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