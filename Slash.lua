--[[
	Slash.lua
		This is the slash command handler for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for ClassicAPI
--]]

if not Bagnon_EngineReady then
	return
end

function BagnonSlash_DisplayHelp()
	BagnonMsg("Bagnon commands:");
	BagnonMsg("/bgn help - Display slash commands.");
	BagnonMsg("/bgn bags - Show/Hide Bagnon.");
	BagnonMsg("/bgn bank - Show/Hide Banknon.");
	BagnonMsg("/bgn sort - Clean up and sort bags.");
	BagnonMsg("/bgn freespace - Toggle free bag space display.");
	BagnonMsg("/bgn enchants - Toggle weapon enchant badges.");

	BagnonMsg("/bgn delete <character> <realm> - Removes the given character's inventory and bank data.")
end

local argsBuffer = {}

SlashCmdList["BagnonCOMMAND"] = function(msg)
	if(not msg or msg == "") then
		BagnonOptions_Toggle()
	else
		table.wipe(argsBuffer)
		for word in string.gmatch(msg, "[^%s]+") do
			table.insert(argsBuffer, word)
		end
		local cmd = string.lower(argsBuffer[1] or "")

		if(cmd == "help") then
			BagnonSlash_DisplayHelp();
		elseif(cmd == "bank") then
			BagnonFrame_Toggle("Banknon");
		elseif(cmd == "bags") then
			BagnonFrame_Toggle("Bagnon");
		elseif(cmd == "sort") then
			if Banknon:IsShown() and not Bagnon_IsCachedFrame(Banknon) and Bagnon_AtBank() then
				Bagnon_RequestSort(true)
			else
				if Bagnon_IsCachedFrame(Bagnon) then
					BagnonMsg("Cannot sort bags of an offline character.")
				else
					Bagnon_RequestSort(false)
				end
			end
		elseif(cmd == "freespace") then
			if BagnonSets.showFreeSlots == 0 then
				BagnonSets.showFreeSlots = 1
				BagnonMsg("Free bag space display enabled.")
			else
				BagnonSets.showFreeSlots = 0
				BagnonMsg("Free bag space display disabled.")
			end
			BagnonOptions_RefreshHeader()
		elseif(cmd == "enchants") then
			if BagnonSets.enchantBadges == 0 then
				BagnonSets.enchantBadges = 1
				BagnonMsg("Weapon enchant badges enabled.")
			else
				BagnonSets.enchantBadges = 0
				BagnonMsg("Weapon enchant badges disabled.")
			end
			BagnonOptions_RefreshItems()
		elseif(cmd == "delete") then
			if not argsBuffer[2] then
				BagnonMsg("/bgn delete <character> <realm> - Removes the given character's inventory and bank data.")
			else
				local realm = argsBuffer[3] and table.concat(argsBuffer, " ", 3) or GetRealmName()
				BagnonForever_RemovePlayer(argsBuffer[2], realm)
			end
		end
	end
end

SLASH_BagnonCOMMAND1 = "/bagnon";
SLASH_BagnonCOMMAND2 = "/bgn";
SLASH_BagnonCOMMAND3 = "/bo";
