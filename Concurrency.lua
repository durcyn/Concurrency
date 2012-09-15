local _G = getfenv(0)
local CreateFrame = _G.CreateFrame
local GetCurrencyInfo = _G.GetCurrencyInfo
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local pairs = _G.pairs
local select = _G.select
local format = _G.string.format
local wipe = _G.wipe
local sort = _G.table.sort

local f = CreateFrame("Frame")
ConcurrencyDB = ConcurrencyDB or {}

local raw = {241, 390, 61, 515, 398, 384, 697, 81, 615, 393, 392, 361, 402, 395, 416, 677, 614, 400, 394, 397, 676, 391, 401, 385, 396, 399, 698, }
local currencies = {}

local init, name, class, realm
local colors = {}

local function initialize()
	name = UnitName("player")
	class = select(2, UnitClass("player"))

	for k, v in pairs(RAID_CLASS_COLORS) do
	        colors[k] = "|cff" .. format("%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
	end

	local found = false
	for k,v in pairs(ConcurrencyDB) do
		if v.name == name and v.realm == realm then
			found = true
			break
		end
	end

	if not found then
		table.insert(ConcurrencyDB, {name = name, realm = realm, class = class, data = {}})
	end
	init = true
end

f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
f:SetScript("OnEvent", function(frame, event, ...)
	if not init then initialize() end
	wipe(currencies)
	for _, i in pairs(raw) do
		local currency, amount, texture, week, max, cap, known  = GetCurrencyInfo(i)
		if known then 
			currencies[currency] = i
			for k,v in pairs(ConcurrencyDB) do
				if v.name == name then
					v.data[i] = amount
				end
			end
		end
	end
end)

local added = false
local function OnShow(tooltip, ...)
	if not added then
		local title = GameTooltip:GetRegions():GetText()
		if currencies[title] then
			sort(ConcurrencyDB, function(a,b) return a.name < b.name end)
			for k,v in pairs(ConcurrencyDB) do
				if v.name ~= name and v.realm == realm and v.data[currencies[title]] then
					local fancy = v.class and colors[v.class] and colors[v.class]..v.name.."|r" or v.name
					if v.realm ~= v.realm then fancy = fancy.." - "..v.realm end
					tooltip:AddLine(format("%s:  %d", fancy, v.data[currencies[title]]))
					tooltip:SetHeight(tooltip:GetHeight()+14)
				end
			end
		end
		added = true
	end
end
		   
local function OnTooltipCleared(tooltip, ...)
	added = false
end
		       
GameTooltip:HookScript("OnShow", OnShow)
GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
