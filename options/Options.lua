--[[
	Options.lua
		Main configuration dialog for Bagnon (/bgn)
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

function BagnonOptions_OnLoad()
	if not BagnonDB then
		local frameName = this:GetName()
		this:SetWidth(this:GetWidth() - 24)

		getglobal(frameName .. "ForeverTooltips"):Hide()
		getglobal(frameName .. "Quality"):ClearAllPoints()
		getglobal(frameName .. "Quality"):SetPoint("TOPLEFT", frameName .. "Tooltips", "BOTTOMLEFT")

		getglobal(frameName .. "ShowWhen"):ClearAllPoints()
		getglobal(frameName .. "ShowWhen"):SetPoint("TOPLEFT", this, "TOPLEFT", 16, 118)

		getglobal(frameName .. "ShowWhen"):ClearAllPoints()
		getglobal(frameName .. "BanknonDiv"):SetPoint("TOPLEFT", this, "TOPLEFT", 16, 118)
	end
end

function BagnonOptions_OnShow()
	local frameName = this:GetName()

	getglobal(frameName .. "Tooltips"):SetChecked(BagnonSets.showTooltips)
	getglobal(frameName .. "ForeverTooltips"):SetChecked(BagnonSets.showForeverTooltips)
	getglobal(frameName .. "Quality"):SetChecked(BagnonSets.qualityBorders)

	getglobal(frameName .. "ShowBagnon1"):SetChecked(BagnonSets.showBagsAtBank)
	--getglobal(frameName .. "ShowBagnon2"):SetChecked(BagnonSets.showBagsAtVendor)
	getglobal(frameName .. "ShowBagnon3"):SetChecked(BagnonSets.showBagsAtAH)
	--getglobal(frameName .. "ShowBagnon4"):SetChecked(BagnonSets.showBagsAtMail)
	getglobal(frameName .. "ShowBagnon5"):SetChecked(BagnonSets.showBagsAtTrade)
	getglobal(frameName .. "ShowBagnon6"):SetChecked(BagnonSets.showBagsAtCraft)

	getglobal(frameName .. "ShowBanknon1"):SetChecked(BagnonSets.showBankAtBank)
	getglobal(frameName .. "ShowBanknon2"):SetChecked(BagnonSets.showBankAtVendor)
	getglobal(frameName .. "ShowBanknon3"):SetChecked(BagnonSets.showBankAtAH)
	getglobal(frameName .. "ShowBanknon4"):SetChecked(BagnonSets.showBankAtMail)
	getglobal(frameName .. "ShowBanknon5"):SetChecked(BagnonSets.showBankAtTrade)
	getglobal(frameName .. "ShowBanknon6"):SetChecked(BagnonSets.showBankAtCraft)
end

local function SetFrameTrigger(bankKey, bagKey, enable, bank)
	local key = bank and bankKey or bagKey
	BagnonSets[key] = enable and 1 or nil
end

function BagnonOptions_ShowAtBank(enable, bank) SetFrameTrigger("showBankAtBank", "showBagsAtBank", enable, bank) end
function BagnonOptions_ShowAtVendor(enable, bank) SetFrameTrigger("showBankAtVendor", "showBagsAtVendor", enable, bank) end
function BagnonOptions_ShowAtAH(enable, bank) SetFrameTrigger("showBankAtAH", "showBagsAtAH", enable, bank) end
function BagnonOptions_ShowAtMail(enable, bank) SetFrameTrigger("showBankAtMail", "showBagsAtMail", enable, bank) end
function BagnonOptions_ShowAtTrade(enable, bank) SetFrameTrigger("showBankAtTrade", "showBagsAtTrade", enable, bank) end
function BagnonOptions_ShowAtCrafting(enable, bank) SetFrameTrigger("showBankAtCraft", "showBagsAtCraft", enable, bank) end

function BagnonOptions_ShowTooltips(enable)
	if enable then
		BagnonSets.showTooltips = 1
	else
		BagnonSets.showTooltips = nil
	end
end

function BagnonOptions_ShowForeverTooltips(enable)
	if enable then
		BagnonSets.showForeverTooltips = 1
	else
		BagnonSets.showForeverTooltips = nil
	end
end

function BagnonOptions_ShowQualityBorders(enable)
	if enable then
		BagnonSets.qualityBorders = 1
	else
		BagnonSets.qualityBorders = nil
	end

	if Bagnon and Bagnon:IsShown() then
		BagnonFrame_Generate(Bagnon)
	end

	if Banknon and Banknon:IsShown() then
		BagnonFrame_Generate(Banknon)
	end
end