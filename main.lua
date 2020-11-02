-- WoW Rambler Project - Position History Addon
--
-- mailto: wow.rambler.project@gmail.com
--

local AddonName = ...

local mainFrame = CreateFrame("Frame", nil, UIParent)
mainFrame.events = {}

local ZeroVector = CreateVector2D(0, 0)
local UnitVector = CreateVector2D(1, 1)

local function MonitorPosition()
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if not uiMapID then
		return
	end

	local worldPosition = WoWRamblerProjectMapsCache[uiMapID]

	-- It's a new map, save its dimmensions.
	if not worldPosition then
		worldPosition = {}
		local _
		_, worldPosition[1] = C_Map.GetWorldPosFromMapPos(uiMapID, ZeroVector)
		_, worldPosition[2] = C_Map.GetWorldPosFromMapPos(uiMapID, UnitVector)

		-- Exile's Reach - North Sea: returns nil.
		if not worldPosition[1] or not worldPosition[2] then
			return
		end

		WoWRamblerProjectMapsCache[uiMapID] = {
			["x1"] = worldPosition[1].x,
			["y1"] = worldPosition[1].y,
			["x2"] = worldPosition[2].x,
			["y2"] = worldPosition[2].y
		}
	end

	local y, x, _, instanceID = UnitPosition('player')

	WoWRamblerProjectPositionHistory[GetServerTime()] = {
		["map id"] = uiMapID,
		["instance id"] = instanceID or "nil",
		["instance x"] = x or "nil",
		["instance y"] = y or "nil",
		["combat"] = UnitAffectingCombat("player"),
		["target GUID"] = UnitGUID("target") or "nil"
	}
end

function mainFrame:SetupEvents()
	self:SetScript("OnEvent", function(self, event, ...)
		self.events[event](self, ...)
	end)

	for k, v in pairs(self.events) do
		self:RegisterEvent(k)
	end
end

function mainFrame.events:ADDON_LOADED(addonName)
	if addonName == AddonName then
		WoWRamblerProjectPositionHistory = WoWRamblerProjectPositionHistory or {}
		WoWRamblerProjectMapsCache = WoWRamblerProjectMapsCache or {}

		C_Timer.NewTicker(1, MonitorPosition)
	end
end

mainFrame:SetupEvents()
