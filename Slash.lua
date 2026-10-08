--[[
	Slash.lua
		This is the slash command handler for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for ClassicAPI v1.15.15+
--]]

if not Bagnon_EngineReady then
	return
end

function BagnonSlash_DisplayHelp()
	BagnonMsg(BAGNON_HELP_TITLE);
	BagnonMsg(BAGNON_HELP_HELP);
	BagnonMsg(BAGNON_HELP_SHOWBAGS);
	BagnonMsg(BAGNON_HELP_SHOWBANK);
	BagnonMsg(BAGNON_HELP_SORT);
	BagnonMsg(BAGNON_HELP_FREESLOTS);
	BagnonMsg(BAGNON_HELP_ENCHANTS);

	if BagnonDB then
		BagnonMsg(BAGNON_FOREVER_HELP_DELETE_CHARACTER)
	end
end

local argsBuffer = {}

SlashCmdList["BagnonCOMMAND"] = function(msg)
	if(not msg or msg == "") then
		if BagnonOptions then
			BagnonOptions:Show()
		else
			BagnonSlash_DisplayHelp()
		end
	else
		table.wipe(argsBuffer)
		local word
		for word in string.gfind(msg, "[^%s]+") do
			table.insert(argsBuffer, word)
		end
		local cmd = string.lower(argsBuffer[1] or "")

		if(cmd == BAGNON_COMMAND_HELP) then
			BagnonSlash_DisplayHelp();
		elseif(cmd == BAGNON_COMMAND_SHOWBANK) then
			BagnonFrame_Toggle("Banknon");
		elseif(cmd == BAGNON_COMMAND_SHOWBAGS) then
			BagnonFrame_Toggle("Bagnon");
		elseif(cmd == BAGNON_COMMAND_SORT) then
			if Banknon and Banknon:IsShown() and not (Bagnon_IsCachedFrame and Bagnon_IsCachedFrame(Banknon)) and bgn_atBank then
				Bagnon_RequestSort(true)
			else
				if Bagnon and Bagnon_IsCachedFrame and Bagnon_IsCachedFrame(Bagnon) then
					BagnonMsg(BAGNON_CANNOT_SORT_OFFLINE)
				else
					Bagnon_RequestSort(false)
				end
			end
		elseif(cmd == BAGNON_COMMAND_FREESLOTS or cmd == "freeslots") then
			if not BagnonSets then BagnonSets = {} end
			if BagnonSets.showFreeSlots == 0 then
				BagnonSets.showFreeSlots = 1
				BagnonMsg(BAGNON_FREESLOTS_ENABLED)
			else
				BagnonSets.showFreeSlots = 0
				BagnonMsg(BAGNON_FREESLOTS_DISABLED)
			end
			if Bagnon and Bagnon:IsShown() then
				BagnonFrame_UpdateFreeSlots(Bagnon)
			end
			if Banknon and Banknon:IsShown() then
				BagnonFrame_UpdateFreeSlots(Banknon)
			end
		elseif(cmd == BAGNON_COMMAND_ENCHANTS) then
			if not BagnonSets then BagnonSets = {} end
			if BagnonSets.enchantBadges == 0 then
				BagnonSets.enchantBadges = 1
				BagnonMsg(BAGNON_ENCHANTS_ENABLED)
			else
				BagnonSets.enchantBadges = 0
				BagnonMsg(BAGNON_ENCHANTS_DISABLED)
			end
			if Bagnon and Bagnon:IsShown() then
				BagnonFrame_Update(Bagnon)
			end
		elseif(cmd == BAGNON_COMMAND_DEBUG_ON) then
			BagnonSets.noDebug = nil;
			BagnonMsg(BAGNON_DEBUG_ENABLED);
		elseif(cmd == BAGNON_COMMAND_DEBUG_OFF) then
			BagnonSets.noDebug = 1;
			BagnonMsg(BAGNON_DEBUG_DISABLED);
		elseif(cmd == BAGNON_FOREVER_COMMAND_DELETE_CHARACTER and BagnonDB) then
			if not argsBuffer[2] then
				BagnonMsg(BAGNON_FOREVER_HELP_DELETE_CHARACTER)
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
