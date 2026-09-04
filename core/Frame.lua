--[[
	Frame.lua
		Functionality for Bagnon Inventory/Bank frames
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK

	BagSlots:
		-2: Key (1.11)
		-1: Bank (24 slots)
		0:  Main Inventory (16 slots)
		1, 2, 3, 4: Inventory Bags (16 - 32?)
		5, 6, 7, 8, 9, 10:  Bank Bags (16 - 32?)

	TODO:
		Potentially, I can make the frame completely dynamically generated and merge Bagnon, Bagnon_Core, and Banknon
--]]

--Local constants
local FRAMESTRATA = {"LOW", "MEDIUM", "HIGH"}
local DEFAULT_COLS = 10
local DEFAULT_SPACING = 2
local DEFAULT_ALPHA = 0.85
local DEFAULT_BG = {r = 0, g = 0, b = 0, a = 1}

--[[
	Load settings for the frame
--]]

function BagnonFrame_Load(frame, bags, title)
	local frameName = frame:GetName()

	--make frame close on escape
	tinsert(UISpecialFrames, frameName)

	--initialize variables for the frame if there are none
	if not BagnonSets[frameName] then
		BagnonSets[frameName] = {
			stayOnScreen = 1,
			cols = DEFAULT_COLS,
			space = DEFAULT_SPACING,
			alpha = DEFAULT_ALPHA,
			bg = {r = 0, g = 0, b = 0, a = 1},
			strata = 3,
			bagsShown = 1,
		}
	else
		if BagnonSets[frameName].cols == nil then
			BagnonSets[frameName].cols = DEFAULT_COLS
		end
		if BagnonSets[frameName].space == nil then
			BagnonSets[frameName].space = DEFAULT_SPACING
		end
		if BagnonSets[frameName].alpha == nil then
			BagnonSets[frameName].alpha = DEFAULT_ALPHA
		end
		if not BagnonSets[frameName].bg or tonumber(BagnonSets[frameName].bg) then
			BagnonSets[frameName].bg = {r = 0, g = 0, b = 0, a = 1}
		end
		if BagnonSets[frameName].stayOnScreen == nil then
			BagnonSets[frameName].stayOnScreen = 1
		end
		if BagnonSets[frameName].strata == nil then
			BagnonSets[frameName].strata = 3
		end
		if BagnonSets[frameName].bagsShown == nil then
			BagnonSets[frameName].bagsShown = 1
		end
	end

	--add what bags are controlled by the frame
	if not BagnonSets[frameName].bags then
		BagnonSets[frameName].bags = bags
	end

	--set the frame's transparency
	frame:SetAlpha(BagnonSets[frameName].alpha or DEFAULT_ALPHA)

	--set the frame's background
	local bgSets = BagnonSets[frameName].bg or DEFAULT_BG
	frame:SetBackdropColor(bgSets.r, bgSets.g, bgSets.b, bgSets.a)
	frame:SetBackdropBorderColor(1, 1, 1, bgSets.a)

	--set the frame's layer (low, medium, or high)
	BagnonFrame_SetStrata(frame, BagnonSets[frameName].strata or 3)

	local bagFrame = getglobal(frameName .. "Bags")
	if bagFrame and (BagnonSets[frameName].bagsShown or BagnonSets[frameName].bagsShown == nil) then
		bagFrame:Show()
		local showBagsBtn = getglobal(frameName .. "ShowBags")
		if showBagsBtn then
			showBagsBtn:SetText(BAGNON_HIDEBAGS)
		end
	end

	frame:SetClampedToScreen(BagnonSets[frameName].stayOnScreen)

	frame.defaultBags = bags

	--load any settings needed if we have cached data
	if BagnonDB then
		frame.player = UnitName("player")

		local dropdownButton = CreateFrame("Button", frameName .. "DropDown", frame, "BagnonDBUIDropDownButton")
		dropdownButton:SetAlpha(frame:GetAlpha())
		getglobal(frameName .. "Title"):SetPoint("TOPLEFT", dropdownButton, "TOPRIGHT", 2, 2)
	end

	BagnonFrame_OrderBags(frame, BagnonSets[frameName].reverse)

	--set the frame's title
	frame.title = title
	getglobal(frameName .. "Title"):SetText(format(frame.title, UnitName("player")))
	frame:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp")

	--create the frame
	--reposition actually handles rescaling
	BagnonFrame_Reposition(frame)
	BagnonFrame_Generate(frame)
end

--[[
	Generate the frame (add all items, resize)
--]]

function BagnonFrame_Generate(frame)
	frame.size = 0
	local frameName = frame:GetName()
	local frameSets = BagnonSets[frameName]
	local bags

	if not frameSets then
		return
	end

	-- cached frames use their default bag list
	if Bagnon_IsCachedFrame(frame) then
		bags = frame.defaultBags or frameSets.bags
		MoneyFrame_Update(frameName .. "MoneyFrame", BagnonDB.GetMoney(frame.player))
	-- normal frames use the current saved bag list
	else
		bags = frameSets.bags
		MoneyFrame_Update(frameName .. "MoneyFrame", GetMoney())
	end

	if not bags then
		return
	end

	for _, bagID in pairs(bags) do
		BagnonFrame_AddBag(frame, bagID)
	end

	BagnonFrame_Layout(frame, frameSets.cols, frameSets.space)
	--frame:Show()
end

--[[
	Add all the slots of the given bag to the given frame.
	Increase the total size of frame to include the size of the bag
--]]

local function CreateDummyBag(parent, bagID)
	local dummyBag = CreateFrame("Frame", parent:GetName() .. "DummyBag" .. bagID, parent)
	dummyBag:SetID(bagID)

	return dummyBag
end

function BagnonFrame_AddBag(frame, bagID)
	local frameName = frame:GetName()
	local slot = frame.size

	local bagSize
	if Bagnon_IsCachedBag(frame.player, bagID) then
		bagSize = (BagnonDB.GetBagData(frame.player, bagID)) or 0
	else
		if bagID == KEYRING_CONTAINER then
			bagSize = GetKeyRingSize()
		--HACK, GetContainerNumSlots does not return proper amounts for empty bank slots if you happen to move a bank bag to your bank slots
		elseif bagID <= 0 or GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID)) then
			bagSize = GetContainerNumSlots(bagID)
		else
			bagSize = 0
		end
	end

	--update used slots
	local dummyBag = getglobal(frameName .. "DummyBag" .. bagID) or CreateDummyBag(frame, bagID)
	for index = 1, bagSize, 1 do
		slot = slot + 1
		local item = getglobal(frameName .. "Item".. slot) or BagnonItem_Create(frameName .. "Item".. slot, dummyBag)
		item:SetID(index)
		item:SetParent(dummyBag)
		item:Show()

		BagnonItem_Update(item)
	end

	frame.size = frame.size + bagSize
end

--[[
	Resize and hide any unusable bag slots in the frame.
		This function needs to know about the layout of the frame
--]]

function BagnonFrame_TrimToSize(frame)
	if not frame.space then return end

	local frameName = frame:GetName()
	local height

	--hide unused slots
	if frame.size then
		local slot = frame.size + 1
		local button = getglobal(frameName .. "Item".. slot)

		while button do
			button:Hide()
			slot = slot + 1
			button = getglobal(frameName .. "Item".. slot)
		end
	end

	--set the frame's width
	--correction for any frame that's completely empty
	if not frame.size or frame.size == 0 then
		height = 64
		frame:SetWidth(256)
	else
		--15 is the estimated border width of the frame, 37 is the width of an item button
		if frame.size < frame.cols then
			frame:SetWidth((37 + frame.space) * frame.size + 16 - frame.space)
		else
			frame:SetWidth((37 + frame.space) * frame.cols + 16 - frame.space)
		end

		--set the frame's height, adjusted to fit a bag frame if its shown/there is one
		height = (37 + frame.space) * math.ceil(frame.size / frame.cols)  + 64 - frame.space
	end

	--adjust for the bag frame, if present
	local bagFrame = getglobal(frame:GetName() .. "Bags")

	if bagFrame and bagFrame:IsShown() then
		frame:SetHeight(height + bagFrame:GetHeight())

		if frame:GetWidth() < bagFrame:GetWidth() then
			--the +8 is for correcting for the border width of the frame
			frame:SetWidth(bagFrame:GetWidth() + 8)
		end
	else
		frame:SetHeight(height)
	end
end


-- Update all item information for usable slots
function BagnonFrame_Update(frame, bagID)
	if not frame.size or Bagnon_IsCachedFrame(frame) then return end

	local frameName = frame:GetName()
	local startSlot = 1
	local endSlot

	--if we don't know the ID of the bag that updated, then update all slots, else only update the necessary slots.
	if not bagID then
		endSlot = frame.size
	else
		for _, bag in pairs(BagnonSets[frameName].bags) do
			if bag == bagID then
				if bag == KEYRING_CONTAINER then
					endSlot = startSlot + GetKeyRingSize() - 1
				elseif bag == -1 then
					endSlot = startSlot + 23
				else
					endSlot = startSlot + GetContainerNumSlots(bag) - 1
				end
				break
			else
				if bag == KEYRING_CONTAINER then
					startSlot = startSlot + GetKeyRingSize()
				elseif bag == -1 then
					startSlot = startSlot + 24
				else
					startSlot = startSlot + GetContainerNumSlots(bag)
				end
			end
		end
	end

	--update the necessary slots
	for slot = startSlot, endSlot do
		local item = getglobal(frameName .. "Item" .. slot)
		if item then
			BagnonItem_Update(item)
		end
	end
end

function BagnonFrame_UpdateLock(frame)
	if not frame.size or Bagnon_IsCachedFrame(frame) then return end

	local frameName = frame:GetName()

	for slot = 1, frame.size do
		local item = getglobal(frameName .. "Item" .. slot)
		local _, _, locked = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	end
end

-- Layout the frame with given number of columns and button spacing
function BagnonFrame_Layout(frame, cols, space)
	if not frame.size or frame.size == 0 then return end

	local frameName = frame:GetName()

	if not cols then
		cols = (BagnonSets[frameName] and BagnonSets[frameName].cols) or DEFAULT_COLS
	end
	BagnonSets[frameName].cols = cols

	if not space then
		space = (BagnonSets[frameName] and BagnonSets[frameName].space) or DEFAULT_SPACING
	end
	BagnonSets[frameName].space = space

	frame.cols = cols
	frame.space = space

	for slot = 1, frame.size do
		local button = getglobal(frameName .. "Item" .. slot)
		if button then
			button:ClearAllPoints()
			local col = (slot - 1) % cols
			if slot == 1 then
				button:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -31)
			elseif col == 0 then
				button:SetPoint("TOP", getglobal(frameName .. "Item" .. (slot - cols)), "BOTTOM", 0, -space)
			else
				button:SetPoint("LEFT", getglobal(frameName .. "Item" .. (slot - 1)), "RIGHT", space, 0)
			end
		end
	end

	BagnonFrame_TrimToSize(frame)
end

--[[
	Safe Open/Close/Toggle <frame>
--]]

function BagnonFrame_Open(frameName, automatic)
	local frame = getglobal(frameName)
	if not frame then
		return
	end

	BagnonFrame_Generate(frame)
	frame:Show()
	
	if not automatic then
		frame.manOpened = 1
	end
end

function BagnonFrame_Close(frameName, automatic)
	local frame = getglobal(frameName)
	if frame then
		if not(automatic and frame.manOpened) then
			frame:Hide()
			frame.manOpened = nil
		end
	end
end

function BagnonFrame_Toggle(frameName)
	local frame = getglobal(frameName)
	if not frame then
		return
	end

	if frame:IsVisible() then
		BagnonFrame_Close(frameName)
	else
		BagnonFrame_Open(frameName)
	end
end

--[[
	Highlight all the slots of <bag>
--]]

function BagnonFrame_HighlightSlots(frame, bagID)
	if not frame.size then return end

	local frameName = frame:GetName()
	local slot

	--update only the slots the player can use
	for slot = 1, frame.size, 1 do
		local item = getglobal(frameName .. "Item" .. slot)

		if item:GetParent():GetID() == bagID then
			item:LockHighlight()
		end
	end
end

function BagnonFrame_UnhighlightAll(frame)
	if not frame.size then return end

	local frameName = frame:GetName()
	local slot

	--update only the slots the player can use
	for slot = 1, frame.size, 1 do
		getglobal(frameName .. "Item" .. slot):UnlockHighlight()
	end
end

--[[
	Add/Remove <Bag> from the frame
--]]

function BagnonFrame_ToggleBag(frame, bagID)
	if not frame then return end

	local frameName = frame:GetName()

	-- add bag
	if not Bagnon_FrameHasBag(frameName, bagID) then
		table.insert(BagnonSets[frameName].bags, bagID)
	-- remove bag
	else
		for index, id in ipairs(BagnonSets[frameName].bags) do
			if id == bagID then
				table.remove(BagnonSets[frameName].bags, index)
				break
			end
		end
	end

	BagnonFrame_OrderBags(frame, BagnonSets[frameName].reverse)

	if frame:IsShown() then
		BagnonFrame_Generate(frame)
	end
end

--[[
	Frame Positioning Functions
--]]

function BagnonFrame_StartMoving(frame)
	if not BagnonSets[frame:GetName()].locked then
		frame.isMoving = 1
		frame:StartMoving()
	end
end

function BagnonFrame_StopMoving(frame)
	frame.isMoving = nil
	frame:StopMovingOrSizing()
	BagnonFrame_SavePosition(frame)
end

--Place the frame at the last place it was at.
--This is used when the frame first loads because the game currently does not remember the last position of a frame that's dynamically loaded
function BagnonFrame_Reposition(frame)
	local frameName = frame:GetName()
	if not (BagnonSets and BagnonSets[frameName]) then return end

	local top = BagnonSets[frameName].top
	local left = BagnonSets[frameName].left
	if not (top and left) then return end

	local scale = BagnonSets[frameName].scale or 1
	local parent = frame:GetParent() or UIParent
	local parentScale = parent:GetScale() or 1

	local ratio = 1
	if BagnonSets[frameName].parentScale and parentScale > 0 then
		ratio = BagnonSets[frameName].parentScale / parentScale
	end

	frame:ClearAllPoints()
	frame:SetScale(scale)
	frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", left * ratio, top * ratio)
end

--Save the frame's current position.  Needed because frames don't remember their positions if dynamically loaded.
function BagnonFrame_SavePosition(frame)
	local frameName = frame:GetName()
	if not (BagnonSets and BagnonSets[frameName]) then return end

	local top = frame:GetTop()
	local left = frame:GetLeft()
	if top and left and top > 0 and left > 0 then
		BagnonSets[frameName].top = top
		BagnonSets[frameName].left = left
		BagnonSets[frameName].scale = frame:GetScale()
		if frame:GetParent() then
			BagnonSets[frameName].parentScale = frame:GetParent():GetScale()
		end
	end
end

--set the layer of the frame
function BagnonFrame_SetStrata(frame, strata)
	BagnonSets[frame:GetName()].strata = strata
	frame:SetFrameStrata(FRAMESTRATA[strata])
end

--[[
	Tooltip Functions
--]]

--tooltips for the title
function BagnonFrame_OnEnter()
	if BagnonSets.showTooltips then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", this, "BOTTOMLEFT", -2, 0)
		GameTooltip:SetOwner(this, "ANCHOR_PRESERVE")
		GameTooltip:SetText(this:GetText(), 1, 1, 1)
		GameTooltip:AddLine(BAGNON_TITLE_TOOLTIP)
		GameTooltip:Show()
	end
end

function BagnonFrame_OnLeave()
	GameTooltip:Hide()
end

--[[
	Money Frame
--]]

--for money frame tooltips, ment to be overriden by forever/kc
function BagnonFrameMoney_OnEnter()
	return
end

function BagnonFrameMoney_OnLeave()
	GameTooltip:Hide()
end

-- This is a hack that enables tooltips but still allows clicking on the money frame
function BagnonFrameMoney_OnClick()
	local parentName = this:GetParent():GetName()
	local parent = this:GetParent()

	if MouseIsOver(getglobal(parentName .. "GoldButton")) then
		OpenCoinPickupFrame(COPPER_PER_GOLD, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(parentName .. "SilverButton")) then
		OpenCoinPickupFrame(COPPER_PER_SILVER, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(parentName .. "CopperButton")) then
		OpenCoinPickupFrame(1, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	end
end

--[[
	Rightclick Menu Stuff
--]]

--hide any menus attached to the frame, if they're visible and we're hiding the frame
function BagnonFrame_OnHide()
	if BagnonMenu:IsVisible() and BagnonMenu.frame == this then
		BagnonMenu:Hide()
	end
end

--this function is here so that it can be overriden
function BagnonFrame_OnDoubleClick(frame)
	return
end

function BagnonFrame_OnClick(frame, mouseButton)
	if mouseButton == "RightButton" then
		BagnonMenu_Show(frame)
	end
end

--[[
	Bag Sorting
--]]

--when sorting in reverse, the keyring is always at the top of the frame
local function ReverseSort(a, b)
	if a == KEYRING_CONTAINER then
		return true
	elseif b == KEYRING_CONTAINER then
		return false
	elseif a and b then
		return a > b
	end
end

--when sorting in normal order, the keyring is always at the bottom of the frame
local function NormalSort(a, b)
	if a == KEYRING_CONTAINER then
		return false
	elseif b == KEYRING_CONTAINER then
		return true
	elseif a and b then
		return a < b
	end
end

function BagnonFrame_OrderBags(frame, reverse)
	if reverse then
		if frame then
			table.sort(BagnonSets[frame:GetName()].bags, ReverseSort)
			if frame.defaultBags then
				table.sort(frame.defaultBags, ReverseSort)
			end
		end
	else
		if frame then
			table.sort(BagnonSets[frame:GetName()].bags, NormalSort)
			if frame.defaultBags then
				table.sort(frame.defaultBags, NormalSort)
			end
		end
	end
end