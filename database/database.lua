--[[
	Database.lua
		BagnonForever's implementation of BagnonDB
		Author: Tuller, McPewPew, Fostercare5988
		Built for the Enhanced WoW 1.12.1 Client (ClassicAPI v1.15.8+)
--]]

--[[ 
	This check isn't absolutely necessary, but it'll warn users if they're using more than one database addon.
	Nothing under this block of code should be loaded if BagnonDB already exists.
--]]
if BagnonDB then
	error("Already using " .. (BagnonDB.addon or "another addon") .. " to view cached data.");
	return;
else
	BagnonDB = {addon = "Bagnon"};
end

--local globals
local currentPlayer = UnitName("player"); --the name of the current player that's logged on
local currentRealm = GetRealmName(); --what currentRealm we're on

if not BagnonForeverData then
	BagnonForeverData = {}
end

if currentRealm and currentRealm ~= "" and not BagnonForeverData[currentRealm] then
	BagnonForeverData[currentRealm] = {}
end

local function GetRealm()
	if not currentRealm or currentRealm == "" then
		currentRealm = GetRealmName()
	end
	if currentRealm and currentRealm ~= "" and not BagnonForeverData[currentRealm] then
		BagnonForeverData[currentRealm] = {}
	end
	return currentRealm
end

--[[ 
	Access  Functions 
--]]

--[[ 
	BagnonDB.GetPlayers()	
		returns:
			iterator of all players on this realm with data
		usage:  
			for playerName, data in BagnonDB.GetPlayers()
--]]

local sortedNamesBuffer = {}

function BagnonDB.GetPlayers(sort)
	local realm = GetRealm()
	if not realm or not BagnonForeverData[realm] then
		return function() end
	end

	if not sort then
		-- If sort is false, just return pairs
		return pairs(BagnonForeverData[realm])
	end

	-- If sort is true, create a sorted list of keys using zero-GC pre-allocated buffer
	table.wipe(sortedNamesBuffer)
	for name in pairs(BagnonForeverData[realm]) do
		table.insert(sortedNamesBuffer, name)
	end
	table.sort(sortedNamesBuffer)

	-- Return a custom iterator function
	local i = 0
	return function()
		i = i + 1
		local playerName = sortedNamesBuffer[i]
		if not playerName then return nil end
		return playerName, BagnonForeverData[realm][playerName]
	end
end

--[[ 
	BagnonDB.GetBags(player)	
		returns:
			iterator of all bagsIDs for the given player
		usage:  
			for bagID, data in BagnonDB.GetBags("playerName")
--]]

function BagnonDB.GetBags(player)
	local realm = GetRealm()
	if realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player] then
		return ipairs(BagnonForeverData[realm][player])
	end
end

--[[ 
	BagnonDB.GetItems(player, bagID)	
		returns:
			iterator of all itemSlots with stuff in the given bag
		usage:  
			for bagID, data in BagnonDB.GetBags("playerName", bagID)
--]]

function BagnonDB.GetItems(player, bagID)
	local realm = GetRealm()
	if realm and player and bagID and BagnonForeverData[realm] and BagnonForeverData[realm][player] and BagnonForeverData[realm][player][bagID] then
		return ipairs(BagnonForeverData[realm][player][bagID])
	end
end

--[[ 
	BagnonDB.GetMoney(player)
		args:
			player (string)
				the name of the player we're looking at.  This is specific to the current realm we're on
		
		returns:
			(number) How much money, in copper, the given player has
--]]
function BagnonDB.GetMoney(player)
	local realm = GetRealm()
	if realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player] then
		return BagnonForeverData[realm][player].g or 0;
	end
	return 0;
end

--[[
	BagnonDB.GetTotalMoney(realm)
		returns:
			(number) Total money across all characters on the specified (or current) realm
--]]
function BagnonDB.GetTotalMoney(realm)
	local targetRealm = realm or GetRealm()
	if not targetRealm or not BagnonForeverData[targetRealm] then
		return 0
	end
	local total = 0
	for _, data in pairs(BagnonForeverData[targetRealm]) do
		if type(data) == "table" and data.g then
			total = total + data.g
		end
	end
	return total
end

--[[ 
	BagnonDB.GetBagData(player, bagID)	
		args:
			player (string)
				the name of the player we're looking at.  This is specific to the current realm we're on
			bagID (number)
				the number of the bag we're looking at.
		
		returns:
			size (number)
				How many items the bag can hold (number)
			link (string)
				The itemlink of the bag, in the format item:w:x:y:z (string)
			count (number)
				How many items are in the bag.  This is used by ammo and soul shard bags
--]]
function BagnonDB.GetBagData(player, bagID)
	local realm = GetRealm()
	local playerData = realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player];
	if playerData then
		local bagData = playerData[bagID];	
		if bagData then
			local _, _, size, count, link = string.find(bagData.s, "([%w_:]+),([%w_:]+),([%w_:]*)");
			
			if(size ~= "") then
				if(link ~="") then
					if(tonumber(link)) then
						link = link .. ":0:0:0";
					end
					link = "item:" .. link;
				else
					link = nil;
				end

				return size, link, tonumber(count);
			end
		end
	end
end

--[[ 
	BagnonDB.GetItemData(player, bagID, itemSlot)
		args:
			player (string)
				the name of the player we're looking at.  This is specific to the current realm we're on
			bagID (number)
				the number of the bag we're looking at.
			itemSlot (number)
				the specific item slot we're looking at
				
		returns:
			itemLink (string)
				The itemlink of the item, in the format item:w:x:y:z
			count (number)
				How many of there are of the specific item
			texture (string)
				The filepath of the item's texture
--]]
function BagnonDB.GetItemData(player, bagID, itemSlot)
	local realm = GetRealm()
	local playerData = realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player];
	if playerData then
		local bagData = playerData[bagID];
		if bagData then
			local itemData = bagData[itemSlot];
			
			if itemData then
				local _, _, itemLink, count = string.find(itemData, "([%d:]+),*(%d*)");
				if tonumber(itemLink) then
					itemLink = itemLink .. ":0:0:0";
				end
				itemLink = "item:" .. itemLink;
				
				local _, _, quality, _, _, _, _, _, texture = GetItemInfo(itemLink);
				return itemLink, tonumber(count), texture, quality;
			end
		end
	end
end

--[[
	Returns how many of the specific item id the given player has in the given bag
--]]
function BagnonDB.GetItemTotal(id, player, bagID)
	local count = 0
	local targetID = tonumber(id)
	if not targetID then return 0 end

	local realm = GetRealm()
	local playerData = realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player]
	if playerData then
		local bagData = playerData[bagID]
		if bagData then
			for itemSlot, itemData in pairs(bagData) do
				if tonumber(itemSlot) and type(itemData) == "string" then
					local _, _, rawID, rawCount = string.find(itemData, "^(%d+)[^,]*,?(%d*)")
					if rawID and tonumber(rawID) == targetID then
						count = count + (tonumber(rawCount) or 1)
					end
				end
			end
		end
	end
	return count
end

local playerTotalsCache = {}

local function BuildPlayerItemIndex(realm, player)
	local playerData = realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player]
	if not playerData then return nil end

	local cache = {}
	for bagID, bagData in pairs(playerData) do
		if type(bagID) == "number" and type(bagData) == "table" then
			local isBank = (bagID == -1 or (bagID >= 5 and bagID <= 10))
			for itemSlot, itemData in pairs(bagData) do
				if tonumber(itemSlot) and type(itemData) == "string" then
					local _, _, rawID, rawCount = string.find(itemData, "^(%d+)[^,]*,?(%d*)")
					if rawID then
						local itemID = tonumber(rawID)
						if itemID then
							local qty = tonumber(rawCount) or 1
							local entry = cache[itemID]
							if not entry then
								entry = {0, 0}
								cache[itemID] = entry
							end
							if isBank then
								entry[2] = entry[2] + qty
							else
								entry[1] = entry[1] + qty
							end
						end
					end
				end
			end
		end
	end

	if not playerTotalsCache[realm] then
		playerTotalsCache[realm] = {}
	end
	playerTotalsCache[realm][player] = cache
	return cache
end

function BagnonDB.InvalidatePlayerCache(player, realm)
	local targetRealm = realm or GetRealm()
	if not targetRealm then
		table.wipe(playerTotalsCache)
		return
	end

	if player then
		if playerTotalsCache[targetRealm] then
			playerTotalsCache[targetRealm][player] = nil
		end
	else
		if playerTotalsCache[targetRealm] then
			table.wipe(playerTotalsCache[targetRealm])
		else
			table.wipe(playerTotalsCache)
		end
	end
end

--[[
	Returns (invCount, bankCount) of the specific item id across all bags of the given player.
	Backed by an on-demand indexed aggregation cache.
--]]
function BagnonDB.GetPlayerItemTotals(id, player)
	local targetID = tonumber(id)
	if not targetID then return 0, 0 end

	local realm = GetRealm()
	if not realm or not player then return 0, 0 end

	local realmCache = playerTotalsCache[realm]
	local playerCache = realmCache and realmCache[player]
	if not playerCache then
		playerCache = BuildPlayerItemIndex(realm, player)
	end

	if playerCache then
		local entry = playerCache[targetID]
		if entry then
			return entry[1], entry[2]
		end
	end

	return 0, 0
end

--[[ 
	BagnonDB.GetItemHyperlink(player, bagID, itemSlot)
		args:
			player (string)
				the name of the player we're looking at.  This is specific to the current realm we're on
			bagID (number)
				the number of the bag we're looking at.
			itemSlot (number)
				the specific item slot we're looking at
				
		returns:
			hyperLink (string)
				This is what's linked in chat, ex |Hitem:6948:0:0:0|H[Hearthstone]|H
--]]
function BagnonDB.GetItemHyperlink(player, bagID, itemSlot)
	local realm = GetRealm()
	local playerData = realm and player and BagnonForeverData[realm] and BagnonForeverData[realm][player];
	if playerData then
	
		local bagData = playerData[bagID];
		if bagData then
			local itemData = bagData[itemSlot];
			
			if itemData then
				local _, _, itemLink = string.find(itemData, "([%w_:]+)");
				if tonumber(itemLink) then
					itemLink = itemLink .. ":0:0:0";
				end
				itemLink = "item:" .. itemLink;
				if itemLink then
					local name, ilink, quality = GetItemInfo( itemLink );
					if name then
						local r,g,b,hex = GetItemQualityColor( quality or 1 );
						return (hex or "|cffffffff") .. "|H".. itemLink .. "|h[" .. name .. "]|h|r";
					else
						return "|cffffffff|H".. itemLink .. "|h[Item " .. itemLink .. "]|h|r";
					end
				end
			end
		end
	end
end