-- Enhanced Client startup contract for Bagnon.
local MIN_CLASSIC_API = 11500

Bagnon_EngineReady = CLASSIC_API_VERSION
	and SUPERWOW_VERSION
	and type(CLASSIC_API_VERSION) == "number"
	and CLASSIC_API_VERSION >= MIN_CLASSIC_API
	and C_Timer
	and C_Timer.NewTicker
	and C_Container
	and C_Container.GetContainerItemID
	and C_Container.SortBags
	and table.wipe

if not Bagnon_EngineReady then
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Bagnon Fatal Error]|r Bagnon requires the Enhanced 1.12.1 engine (ClassicAPI v1.15.0+ with modern container sorting and SuperWoW v2.2+).", 1, 0.2, 0.2)
	end
	return
end
