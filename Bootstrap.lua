-- Enhanced Client startup contract for Bagnon.
local MIN_CLASSIC_API = 11515

Bagnon_EngineReady = CLASSIC_API_VERSION
	and type(CLASSIC_API_VERSION) == "number"
	and CLASSIC_API_VERSION >= MIN_CLASSIC_API
	and C_Timer
	and C_Timer.NewTicker
	and C_Container
	and C_Container.GetContainerItemID
	and C_Container.SortBags
	and C_Item and C_Item.GetItemTempEnchantInfo and C_Item.GetEnchantInfo
	and C_Spell and C_Spell.GetSpellTexture
	and table.wipe

if not Bagnon_EngineReady then
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Bagnon Fatal Error]|r Bagnon requires the Enhanced 1.12.1 engine (ClassicAPI v1.15.15+ with container sorting and item enchant metadata).", 1, 0.2, 0.2)
	end
	return
end
