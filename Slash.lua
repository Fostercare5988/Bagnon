--[[
	Slash.lua
		This is the slash command handler for Bagnon
		Author: Tuller, McPewPew, Fostercare5988
		Built for ClassicAPI v1.15.13+
--]]

function BagnonSlash_DisplayHelp()
	BagnonMsg(BAGNON_HELP_TITLE);
	BagnonMsg(BAGNON_HELP_HELP);
	BagnonMsg(BAGNON_HELP_SHOWBAGS);
	BagnonMsg(BAGNON_HELP_SHOWBANK);
	BagnonMsg(BAGNON_HELP_SORT);
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
				if C_Container and C_Container.SortBankBags then
					PlaySound("igMainMenuOption")
					C_Container.SortBankBags()
				end
			else
				if Bagnon and Bagnon_IsCachedFrame and Bagnon_IsCachedFrame(Bagnon) then
					BagnonMsg(BAGNON_CANNOT_SORT_OFFLINE)
				elseif C_Container and C_Container.SortBags then
					PlaySound("igMainMenuOption")
					C_Container.SortBags()
				end
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
			BagnonForever_RemovePlayer(argsBuffer[2], argsBuffer[3] or GetRealmName());
		end
	end
end

SLASH_BagnonCOMMAND1 = "/bagnon";
SLASH_BagnonCOMMAND2 = "/bgn";
SLASH_BagnonCOMMAND3 = "/bo";
