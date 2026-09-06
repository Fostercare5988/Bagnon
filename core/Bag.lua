--[[
	Bag.lua
		Functions used by Bagnon Bags
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

--[[ Bag Frame Functions ]]--

local function ForAllBagSlots(bagFrame, action, arg1)
	local frameName = bagFrame:GetName()
	for i = 1, 10 do
		local bag = getglobal(frameName .. i)
		if bag then
			action(bag, arg1)
		end
	end
end

--this function is used when updating the frame's size based on a bag being replaced/removed/added, so we don't care about the keyring
local function UpdateFrameSize(bagFrame)
	local size = 0
	for i = 1, 10 do
		local bag = getglobal(bagFrame:GetName() .. i)
		if bag and GetInventoryItemTexture("player", ContainerIDToInventoryID(bag:GetID())) then
			size = size + GetContainerNumSlots(bag:GetID())
		end
	end
	local change = (size or 0) - (bagFrame.size or 0)

	--only generate the frame again if the size of the frame changed
	if change ~= 0 then
		bagFrame.size = size
		BagnonFrame_Generate(bagFrame:GetParent())
	end
end

function BagnonBagFrame_OnEvent(self, event, arg1, ...)
	local f = self or this
	if not f or not f:IsVisible() or Bagnon_IsCachedFrame(f:GetParent()) then return end
	local ev = event or event
	local a1 = arg1 or arg1

	if ev == "BAG_UPDATE" or ev == "PLAYERBANKSLOTS_CHANGED" or ev == "PLAYERBANKBAGSLOTS_CHANGED" then
		--hack, the bank frame needs to always update due to unreliable events
		if not a1 or f:GetParent() == Banknon then
			ForAllBagSlots(f, BagnonBag_Update)
		elseif tonumber(a1) and a1 > 0 then
			local bag = getglobal(f:GetName() .. a1)
			if bag then
				BagnonBag_Update(bag)
			end
		end
		UpdateFrameSize(f)
	elseif ev == "ITEM_LOCK_CHANGED" then
		ForAllBagSlots(f, BagnonBag_UpdateLock)
	elseif ev == "CURSOR_UPDATE" then
		ForAllBagSlots(f, BagnonBag_UpdateCursor)
	end
end

function BagnonBagFrame_OnLoad(self)
	local f = self or this
	if not f then return end
	f:RegisterEvent("BAG_UPDATE")
	f:RegisterEvent("ITEM_LOCK_CHANGED")
	f:RegisterEvent("CURSOR_UPDATE")

	f:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	f:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
end

--[[ Individual Bag Slot Code ]]--

--[[ Update Functions ]]--

function BagnonBag_Update(bag)
	if not bag then return end

	local invID = ContainerIDToInventoryID(bag:GetID())

	local textureName = GetInventoryItemTexture("player", invID)
	if textureName then
		SetItemButtonTexture(bag, textureName)
		BagnonBag_SetCount(bag, GetInventoryItemCount("player", invID))

		if not IsInventoryItemLocked(invID) then
			SetItemButtonTextureVertexColor(bag, 1.0, 1.0, 1.0)
			SetItemButtonNormalTextureVertexColor(bag, 1.0, 1.0, 1.0)
		end
		bag.hasItem = 1
	else
		SetItemButtonTexture(bag, nil)
		BagnonBag_SetCount(bag, 0)
		SetItemButtonTextureVertexColor(bag, 1, 1, 1)
		SetItemButtonNormalTextureVertexColor(bag, 1, 1, 1)
		bag.hasItem = nil
	end
	if GameTooltip:IsOwned(bag) then
		if textureName then
			BagnonBag_OnEnter(bag)
		else
			GameTooltip:Hide()
			ResetCursor()
		end
	end
	BagnonBag_UpdateLock(bag)

	-- Update repair all button status
	if MerchantRepairAllIcon then
		local repairAllCost, canRepair = GetRepairAllCost()
		if canRepair then
			SetDesaturation(MerchantRepairAllIcon, nil)
			MerchantRepairAllButton:Enable()
		else
			SetDesaturation(MerchantRepairAllIcon, 1)
			MerchantRepairAllButton:Disable()
		end
	end
end

function BagnonBag_UpdateLock(bag)
	if IsInventoryItemLocked(ContainerIDToInventoryID(bag:GetID())) then
		SetItemButtonDesaturated(bag, 1, 0.5, 0.5, 0.5)
	else
		SetItemButtonDesaturated(bag, nil)
	end
end

function BagnonBag_UpdateCursor(bag)
	if CursorCanGoInSlot(ContainerIDToInventoryID(bag:GetID())) then
		bag:LockHighlight()
	else
		bag:UnlockHighlight()
	end
end


--[[
	Update the texture and count of the bag
		Used mainly for cached bags
--]]
function BagnonBag_UpdateTexture(frame, bagID)
	local bag = getglobal(frame:GetName() .. "Bags" .. bagID)
	if not bag or bag:GetID() <= 0 then return end

	if Bagnon_IsCachedBag(frame.player, bagID) then
		local _, link, count = BagnonDB.GetBagData(frame.player, bagID)
		if link then
			local _, _, _, _, _, _, _, _, texture = GetItemInfo(link)
			SetItemButtonTexture(bag, texture)
		else
			SetItemButtonTexture(bag, nil)
		end
		if count then
			BagnonBag_SetCount(bag, count)
		end
	else
		local texture = GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID))
		if texture then
			SetItemButtonTexture(bag, texture)
		else
			SetItemButtonTexture(bag, nil)
		end
		BagnonBag_SetCount(bag, GetInventoryItemCount("player", ContainerIDToInventoryID(bagID)))
	end
end

function BagnonBag_SetCount(button, count)
	if not button then return end
	if not count then count = 0 end

	button.count = count
	if count > 1 or (button.isBag and count > 0) then
		local countText = getglobal(button:GetName().."Count")
		if count > 9999 then
			countText:SetFont(NumberFontNormal:GetFont(), 10, "OUTLINE")
		elseif count > 999 then
			countText:SetFont(NumberFontNormal:GetFont(), 11, "OUTLINE")
		else
			countText:SetFont(NumberFontNormal:GetFont(), 12, "OUTLINE")
		end
		countText:SetText(count)
		countText:Show()
	else
		getglobal(button:GetName().."Count"):Hide()
	end
end

--[[ OnX Functions ]]--

function BagnonBag_OnLoad(self)
	local b = self or this
	if not b then return end
	b:RegisterForDrag("LeftButton")
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
end

function BagnonBag_OnShow(self)
	local b = self or this
	if not b then return end
	BagnonBag_UpdateTexture(b:GetParent():GetParent(), b:GetID())
end

function BagnonBag_OnClick(self, mouseButton)
	local b = self or this
	if not b then return end
	if Bagnon_IsCachedBag(b:GetParent():GetParent().player, b:GetID()) then return end

	if not IsShiftKeyDown() then
		--damn you blizzard for making the keyring specific code!
		if b:GetID() == KEYRING_CONTAINER then
			PutKeyInKeyRing()
		elseif b:GetID() == 0 then
			PutItemInBackpack()
		else
			PutItemInBag(ContainerIDToInventoryID(b:GetID()))
		end
	else
		BagnonFrame_ToggleBag(b:GetParent():GetParent(), b:GetID())
	end
end

function BagnonBag_OnDrag(self)
	local b = self or this
	if not b then return end
	if Bagnon_IsCachedBag(b:GetParent():GetParent().player, b:GetID()) then return end

	PickupBagFromSlot(ContainerIDToInventoryID(b:GetID()))
	PlaySound("BAGMENUBUTTONPRESS")
end

--tooltip functions
function BagnonBag_OnEnter(self)
	local b = self or this
	if not b then return end
	local frame = b:GetParent():GetParent()

	BagnonFrame_HighlightSlots(frame, b:GetID())

	if b:GetLeft() and (b:GetLeft() < (UIParent:GetRight() / 2)) then
		GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
	else
		GameTooltip:SetOwner(b, "ANCHOR_LEFT")
	end

	--mainmenubag specific code
	if b:GetID() == 0 then
		GameTooltip:SetText(TEXT(BACKPACK_TOOLTIP), 1, 1, 1)
	--keyring specific code...again
	elseif b:GetID() == KEYRING_CONTAINER then
		GameTooltip:SetText(KEYRING, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	--cached bags
	elseif Bagnon_IsCachedBag(frame.player, b:GetID()) then
		local _, link = BagnonDB.GetBagData(frame.player, b:GetID())

		if link then
			GameTooltip:SetHyperlink(link)
			GameTooltip:Show()
		else
			GameTooltip:SetText(TEXT(EQUIP_CONTAINER), 1, 1, 1)
		end
	elseif not GameTooltip:SetInventoryItem("player", ContainerIDToInventoryID(b:GetID())) then
		GameTooltip:SetText(TEXT(EQUIP_CONTAINER), 1, 1, 1)
	end

	if not Bagnon_IsCachedBag(frame.player, b:GetID()) then
		--add the shift click to hide/show tooltip
		if BagnonSets.showTooltips then
			if Bagnon_FrameHasBag(frame:GetName(), b:GetID()) then
				GameTooltip:AddLine(BAGNON_BAGS_HIDE)
			else
				GameTooltip:AddLine(BAGNON_BAGS_SHOW)
			end
		end
	end
	GameTooltip:Show()
end

function BagnonBag_OnLeave(self)
	local b = self or this
	if b and b:GetParent() and b:GetParent():GetParent() then
		BagnonFrame_UnhighlightAll(b:GetParent():GetParent())
	end
	GameTooltip:Hide()
end