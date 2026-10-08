--[[
	Events.lua
		The main event handler for Bagnon and Banknon.
		Author: Tuller, McPewPew, Fostercare5988
		It controls when the frames update, and when and when they are not shown.

		The UI by default partially supports showing/hiding at the mailbox, and fully supports the inventory frame showing/hiding at a vendor.

		I've extended the behavior in the following ways:
			If a frame was previously shown by a user, it will not automatically close.
			The events of showing the bank, tradeskill, auction, and trading can also be set to open the inventory or bank windows.
--]]

if not Bagnon_EngineReady then
	return
end

bgn_atBank = nil --a flag for if the player is at the bank or not

--[[ Local Functions ]]--

local function ShouldUpdateBag(frame, bag)
	return (frame and frame:IsVisible() and Bagnon_FrameHasBag(frame:GetName(), bag))
end

local function IsVisibleCachedFrame(frame)
	return frame and frame:IsVisible() and Bagnon_IsCachedFrame(frame)
end

-- Native delayed bag updates collapse loot/sort bursts. Locks, cooldowns,
-- the keyring and main bank slots also use one next-tick refresh because those
-- paths are not all covered by BAG_UPDATE_DELAYED.
local pendingBags = {}
local pendingLocks, pendingCooldowns, pendingCachedMetadata, refreshTimer
local function FlushUpdates()
    if refreshTimer then refreshTimer:Cancel(); refreshTimer=nil end
    local bags, locks, cooldowns, cachedMetadata = pendingBags, pendingLocks, pendingCooldowns, pendingCachedMetadata
    pendingBags, pendingLocks, pendingCooldowns, pendingCachedMetadata = {}, nil, nil, nil
    local function RefreshFrame(frame)
        if not frame or not frame:IsVisible() then return end
        if Bagnon_IsCachedFrame(frame) then
            -- Item data can become resident after a cached view was built.
            -- Read its current owner now; never retain a queued player/frame.
            if cachedMetadata then BagnonFrame_Generate(frame) end
            return
        end
        local rebuilt = BagnonFrame_UpdateBags(frame,bags)
        if locks and not rebuilt then BagnonFrame_UpdateLock(frame,bags) end
        if cooldowns and not rebuilt then
            for slot=1,(frame.size or 0) do
                local item=(frame.items and frame.items[slot]) or getglobal(frame:GetName().."Item"..slot)
                if item and item:IsShown() and not bags[item:GetParent():GetID()] then
                    BagnonItem_UpdateCooldown(item:GetParent():GetID(),item)
                end
            end
        end
    end
    RefreshFrame(Bagnon)
    RefreshFrame(Banknon)
end

local function ScheduleRefresh()
    if not refreshTimer then
        local timer
        timer=C_Timer.NewTimer(0,function() if refreshTimer==timer then FlushUpdates() end end)
        refreshTimer=timer
    end
end

local function QueueBagUpdate(bag)
    if type(bag)~="number" then return end
    if ShouldUpdateBag(Bagnon,bag) or ShouldUpdateBag(Banknon,bag) then pendingBags[bag]=true end
    if bag==KEYRING_CONTAINER or bag==-1 then ScheduleRefresh() end
end

local function OpenIF(frameName, condition)
	if condition and getglobal(frameName) then
		BagnonFrame_Open(frameName, 1)
		return true
	end
end

local function CloseIF(frameName, condition)
	if condition then
		BagnonFrame_Close(frameName, 1)
		return true
	end
end

--[[
	Taken from Blizzard's code
	Shows the normal bank frame
--]]
local function ShowBlizBank()
	BankFrameTitleText:SetText(UnitName("npc"))
	SetPortraitTexture(BankPortraitTexture,"npc")
	ShowUIPanel(BankFrame)
	if not BankFrame:IsVisible() then
		CloseBankFrame()
	end
	UpdateBagSlotStatus()
end

--[[ Variable Loading ]]--

local function LoadVariables()
	local currentVersion = GetAddOnMetadata("Bagnon", "Version") or "1.0.0"
	if type(BagnonSets) ~= "table" then
		BagnonSets = {
			showBagsAtBank = 1,
			showBagsAtAH = 1,
			showBankAtBank = 1,
			showTooltips = 1,
			qualityBorders = 1,
			enchantBadges = 1,
			showFreeSlots = 1,
			showForeverTooltips = 1,
			version = currentVersion,
		}
		BagnonMsg(BAGNON_INITIALIZED)
	else
		if BagnonSets.enchantBadges == nil then
			BagnonSets.enchantBadges = 1
		end
		if BagnonSets.showFreeSlots == nil then
			BagnonSets.showFreeSlots = 1
		end
		if BagnonSets.version ~= currentVersion then
			BagnonSets.version = currentVersion
			BagnonMsg(format(BAGNON_UPDATED, currentVersion))
		end
	end
end

local function Load(eventFrame)
	BankFrame:UnregisterEvent("BANKFRAME_OPENED")

	LoadVariables()

	eventFrame:RegisterEvent("CVAR_UPDATE")
	eventFrame:RegisterEvent("BAG_UPDATE")
	eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
	eventFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
	eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
	eventFrame:RegisterEvent("BANKFRAME_OPENED")
	eventFrame:RegisterEvent("BANKFRAME_CLOSED")
	eventFrame:RegisterEvent("TRADE_SHOW")
	eventFrame:RegisterEvent("TRADE_CLOSED")
	eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
	eventFrame:RegisterEvent("TRADE_SKILL_CLOSE")
	eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
	eventFrame:RegisterEvent("MAIL_SHOW")
	eventFrame:RegisterEvent("MAIL_CLOSED")
	eventFrame:RegisterEvent("MERCHANT_SHOW")
	eventFrame:RegisterEvent("MERCHANT_CLOSED")
end

local function OnEvent(arg1_param, arg2_param, arg3_param, arg4_param)
	local f = (type(arg1_param) == "table" and arg1_param) or this or eventFrame
	local ev = (type(arg1_param) == "string" and arg1_param) or arg2_param or event
	local a1 = (type(arg1_param) == "string" and (arg2_param or arg1)) or arg3_param or arg1
	local a2
	if type(arg1_param) == "table" then a2 = arg4_param
	elseif type(arg1_param) == "string" then a2 = arg3_param
	else a2 = arg2 end

	--[[ Events For Updating Items ]]--
	if ev == "BAG_UPDATE_COOLDOWN" then
        pendingCooldowns=true; ScheduleRefresh()
    elseif ev == "GET_ITEM_INFO_RECEIVED" then
        -- ClassicAPI emits success as 1/nil; also preserve positional false.
        -- Hidden/live views need no metadata-only timer or item regeneration.
        if a2 and (IsVisibleCachedFrame(Bagnon) or IsVisibleCachedFrame(Banknon)) then
            pendingCachedMetadata=true; ScheduleRefresh()
        end
    elseif ev == "BAG_UPDATE" then
        QueueBagUpdate(a1)
    elseif ev == "BAG_UPDATE_DELAYED" then
        FlushUpdates()
    elseif ev == "PLAYERBANKSLOTS_CHANGED" then
        QueueBagUpdate(-1)
    elseif ev == "ITEM_LOCK_CHANGED" then
        pendingLocks=true; ScheduleRefresh()
	--the keyring's size changes based on the player's level
	elseif ev == "PLAYER_LEVEL_UP" then
		if ShouldUpdateBag(Bagnon, KEYRING_CONTAINER) then
			BagnonFrame_Generate(Bagnon)
		end
	elseif ev == "CVAR_UPDATE" then
		if Bagnon then
			BagnonFrame_Reposition(Bagnon)
		end
		if Banknon then
			BagnonFrame_Reposition(Banknon)
		end
	--[[ Events for Automatically Opening and Closing Frames ]]--
	elseif ev == "BANKFRAME_OPENED" then
		bgn_atBank = true
		if Banknon then
			Banknon.player = UnitName("player")
			Banknon.manOpened = nil
			local titleText = getglobal("BanknonTitle")
			if titleText then
				titleText:SetText(format(Banknon.title or BAGNON_BANK_TITLE, UnitName("player")))
			end
		end
		OpenIF("Bagnon", BagnonSets.showBagsAtBank)
		if not OpenIF("Banknon", BagnonSets.showBankAtBank) then
			-- An already visible cached bank becomes the live player's bank even
			-- when automatic bank-window opening is disabled.
			if Banknon and Banknon:IsShown() then BagnonFrame_Open("Banknon", 1) end
			ShowBlizBank()
		end
	elseif ev == "BANKFRAME_CLOSED" then
		bgn_atBank = nil
		if Banknon then
			Banknon.manOpened = nil
			BagnonFrame_Close("Banknon")
		end
		CloseIF("Bagnon", BagnonSets.showBagsAtBank)
	elseif ev == "TRADE_SHOW" then
		OpenIF("Bagnon", BagnonSets.showBagsAtTrade)
		OpenIF("Banknon", BagnonSets.showBankAtTrade)
	elseif ev == "TRADE_CLOSED" then
		CloseIF("Bagnon", BagnonSets.showBagsAtTrade)
		CloseIF("Banknon", BagnonSets.showBankAtTrade)
	elseif ev == "TRADE_SKILL_SHOW" then
		OpenIF("Bagnon", BagnonSets.showBagsAtCraft)
		OpenIF("Banknon", BagnonSets.showBankAtCraft)
	elseif ev == "TRADE_SKILL_CLOSE" then
		CloseIF("Bagnon", BagnonSets.showBagsAtCraft)
		CloseIF("Banknon", BagnonSets.showBankAtCraft)
	elseif ev == "AUCTION_HOUSE_SHOW" then
		OpenIF("Bagnon", BagnonSets.showBagsAtAH)
		OpenIF("Banknon", BagnonSets.showBankAtAH)
	elseif ev == "AUCTION_HOUSE_CLOSED" then
		CloseIF("Bagnon", BagnonSets.showBagsAtAH)
		CloseIF("Banknon", BagnonSets.showBankAtAH)
	elseif ev == "MAIL_SHOW" then
		OpenIF("Banknon", BagnonSets.showBankAtMail)
	elseif ev == "MAIL_CLOSED" then
		CloseIF("Bagnon", true)
		CloseIF("Banknon", BagnonSets.showBankAtMail)
	elseif ev == "MERCHANT_SHOW" then
		OpenIF("Banknon", BagnonSets.showBankAtVendor)
	elseif ev == "MERCHANT_CLOSED" then
		CloseIF("Banknon", BagnonSets.showBankAtVendor)
	--Loading event
	elseif ev == "ADDON_LOADED" and a1 == "Bagnon" then
		f:UnregisterEvent("ADDON_LOADED")
		Load(f)
	end
end

--create the event handler frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:Hide()
