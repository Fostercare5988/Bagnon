--[[
	Bagnon
		Displays the player's inventory in a single frame
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI v1.14.0+, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

-- Strict Engine Dependency Guard (Mandatory ClassicAPI v1.14.0+ & SuperWoW v2.2+)
local MIN_CLASSIC_API = 11400

if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) or 
   (type(CLASSIC_API_VERSION) == "number" and CLASSIC_API_VERSION < MIN_CLASSIC_API) then
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Bagnon Fatal Error]|r Bagnon requires ClassicAPI (v1.14.0+) & SuperWoW (v2.2+)! Please ensure both DLLs are loaded.", 1, 0.2, 0.2)
	end
	return
end

local bBagSlotButton_OnEnter, bMainBag_OnEnter, bKeyRingButton_OnEnter;
local bBagSlotButton_OnClick, bKeyRingButton_OnClick, bMainBag_OnClick;

--[[ Loading Functions ]]--

function Bagnon_OnLoad(self)
	local f = self or this
	if f then
		f:RegisterEvent("ADDON_LOADED")
	end
end

--[[ Event Handler ]]--

function Bagnon_OnEvent(arg1_param, arg2_param, arg3_param)
	local ev, a1
	if type(arg1_param) == "table" then
		ev = arg2_param or event
		a1 = arg3_param or arg1
	else
		ev = arg1_param or event
		a1 = arg2_param or arg1
	end

	if ( ev == "ADDON_LOADED" and a1 == "Bagnon" ) then
		Bagnon:UnregisterEvent("ADDON_LOADED");
		Bagnon_Load();
	end
end

function Bagnon_Load()
	local texPath = "Interface\\AddOns\\Bagnon\\assets\\bank.blp"
	local bankBtn = getglobal("BagnonOpenBank")
	if bankBtn then
		bankBtn:SetNormalTexture(texPath)
		bankBtn:SetPushedTexture(texPath)
	end

	BagnonFrame_Load(Bagnon, {-2, 0, 1, 2, 3, 4}, BAGNON_INVENTORY_TITLE);
	Bagnon_AddBagHooks();
end

--[[ UI Functions ]]--

--OnShow
function Bagnon_OnShow()
	MainMenuBarBackpackButton:SetChecked(1);
	PlaySound("igBackPackOpen");
end

--OnHide
function Bagnon_OnHide()
	MainMenuBarBackpackButton:SetChecked(0);
	PlaySound("igBackPackClose");
end

--Show Bags
function Bagnon_ToggleBags(self)
	local btn = self or this
	if( not BagnonBags:IsShown() ) then
		BagnonBags:Show();
		BagnonSets["Bagnon"].bagsShown = 1;
		if btn and btn.SetText then btn:SetText(BAGNON_HIDEBAGS); end
	else
		BagnonBags:Hide();
		BagnonSets["Bagnon"].bagsShown = nil;
		if btn and btn.SetText then btn:SetText(BAGNON_SHOWBAGS); end
	end
	
	BagnonFrame_TrimToSize(Bagnon);
end

function Bagnon_ViewBank()
	BagnonFrame_Toggle("Banknon")
end

--[[ Bag Overrides ]]--

function Bagnon_AddBagHooks()
	bMainBag_OnEnter = MainMenuBarBackpackButton:GetScript("OnEnter");
	bMainBag_OnClick = MainMenuBarBackpackButton:GetScript("OnClick");
	MainMenuBarBackpackButton:SetScript("OnEnter", BagnonBlizMainBag_OnEnter);
	MainMenuBarBackpackButton:SetScript("OnLeave", BagnonBlizBag_OnLeave);
	MainMenuBarBackpackButton:SetScript("OnClick", BagnonBlizMainBag_OnClick);
	
	bBagSlotButton_OnEnter = BagSlotButton_OnEnter;
	BagSlotButton_OnEnter = BagnonBlizBag_OnEnter;
	bBagSlotButton_OnClick = getglobal("CharacterBag0Slot"):GetScript("OnClick");
	for i = 0, 3 do
		getglobal("CharacterBag" .. i .. "Slot"):SetScript("OnLeave", BagnonBlizBag_OnLeave);
		getglobal("CharacterBag" .. i .. "Slot"):SetScript("OnClick", BagnonBlizBag_OnClick);
	end
	
	bKeyRingButton_OnEnter = KeyRingButton:GetScript("OnEnter");
	bKeyRingButton_OnClick = KeyRingButton:GetScript("OnClick");
	KeyRingButton:SetScript("OnEnter", BagnonBlizKeyRing_OnEnter);
	KeyRingButton:SetScript("OnLeave", BagnonBlizBag_OnLeave);
	KeyRingButton:SetScript("OnClick", BagnonBlizKeyRing_OnClick);
end

--Main Bag
function BagnonBlizMainBag_OnEnter()
	if( Bagnon:IsShown() ) then
		BagnonFrame_HighlightSlots(Bagnon, this:GetID());
	end
	bMainBag_OnEnter();
end

function BagnonBlizMainBag_OnClick()
	if( IsShiftKeyDown() ) then
		BagnonFrame_ToggleBag(Bagnon, this:GetID());
	else
		bMainBag_OnClick();
	end
end

--Normal Bags
function BagnonBlizBag_OnEnter()
	if(Bagnon:IsShown() ) then
		BagnonFrame_HighlightSlots(Bagnon, this:GetID() - 19);
	end
	
	bBagSlotButton_OnEnter();
end

function BagnonBlizBag_OnClick()
	if( IsShiftKeyDown() ) then
		BagnonFrame_ToggleBag(Bagnon, this:GetID() - 19);
	else
		bBagSlotButton_OnClick();
	end
end

function BagnonBlizBag_OnLeave()
	GameTooltip:Hide();
	BagnonFrame_UnhighlightAll(Bagnon);
end

--KeyRing
function BagnonBlizKeyRing_OnEnter()
	if(Bagnon:IsShown() ) then
		BagnonFrame_HighlightSlots(Bagnon, this:GetID());
	end
	bKeyRingButton_OnEnter();
end

function BagnonBlizKeyRing_OnClick()
	if( IsShiftKeyDown() ) then
		BagnonFrame_ToggleBag(Bagnon, this:GetID());
	else
		bKeyRingButton_OnClick();
	end
end