--[[
	TLib.lua
		Lua functions for table manipulation and utility
		Author: Tuller, McPewPew, Fostercare5988
		Built natively for ClassicAPI v1.13.4+, SuperWoW 2.2+, NamPower 4.6.3+, UnitXP SP3, DXVK
--]]

-- Strict Engine Dependency Guard (Mandatory ClassicAPI v1.13.4+ & SuperWoW v2.2+)
if not (CLASSIC_API_VERSION and SUPERWOW_VERSION) then
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Bagnon Fatal Error]|r Bagnon requires ClassicAPI.dll (v1.13.4+) & SuperWoW (v2.2+)! Please ensure both DLLs are loaded.", 1, 0.2, 0.2)
	end
	return
end

--local msg = function(message)  ChatFrame1:AddMessage('TLib: ' .. (message or 'nil')) end

--[[ Functions TLib needs to load ]]--

--converts a version string into a number.  Yes, I'm lazy
local function VToN(versionString)
	if tonumber(versionString) then
		return tonumber(versionString)
	end

	local _, _, major, minor, point = string.find(versionString, "(%d+)%.(%d+)%.(%d+)")
	major = tonumber(major); minor = tonumber(minor); point = tonumber(point)
	if major and minor and point then
--		msg(major * 10000 + minor * 100 + point)
		return major * 10000 + minor * 100 + point
	end
end
local OlderIsBetter = function(lib, version) return lib and lib.version and VToN(lib.version) >= VToN(version) end

local VERSION = "6.10.18"
if OlderIsBetter(TLib, VERSION) then return end
if not TLib then TLib = {} end

TLib.version = VERSION

--[[ Library Functions ]]--

TLib.VToN = VToN
TLib.OlderIsBetter = OlderIsBetter

--[[ Table Functions ]]--

--Adapted from http://www.lua.org/pil/14.1.html,
--sets a specific global variable string to the given value, with table.table.table access
function TLib.SetField(field, value)
	local var
	for i, rest in string.gfind(field, "([%w_]+)(%.?)") do
		if not var then
			if i == field then
				setglobal(i, value)
				return
			else
				i = tonumber(i) or i
				var = getglobal(i)
			end
		elseif rest and rest ~= "" then
			i = tonumber(i) or i
			if not var[i] then
				var[i] = {}
			end
			var = var[i]
		else
			i = tonumber(i) or i
			var[i] = value
		end
	end
end

--Adapted from http://www.lua.org/pil/14.1.html, gets a specific field of a global variable string
function TLib.GetField(field)
	local var
	for i in string.gfind(field, "([%w_]+)") do
		if not var then
			var = getglobal(i)
		else
			i = tonumber(i) or i
			var = var[i]
		end
	end
	return var
end

--taken from http://lua-users.org/wiki/PitLibTablestuff, performs a deep table copy
function TLib.TCopy(t, lookup_table)
	if t then
		local copy = {}
		for i, v in pairs(t) do
			if type(v) ~= "table" then
				copy[i] = v
			else
				lookup_table = lookup_table or {}
				lookup_table[t] = copy
				if lookup_table[v] then
					copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
				else
					copy[i] = TLib.TCopy(v, lookup_table) -- not yet copied. copy it.
				end
			end
		end
		return copy
	end
end