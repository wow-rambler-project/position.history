-- WoW Rambler Project - Position History Addon
--
-- mailto: wow.rambler.project@gmail.com
--

local AddonName = ...

local mainFrame = CreateFrame("Frame", nil, UIParent)

local zeroVector = CreateVector2D(0, 0)
local unitVector = CreateVector2D(1, 1)
local playerPosition = CreateVector2D(0,0)

function MonitorPosition()
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if not uiMapID then
		return
	end

	local worldPosition = WoWRamblerProjectMapsCache[uiMapID]

	-- It's a new map, save its dimmensions.
	if not worldPosition then
		worldPosition = {}
		local _
		_, worldPosition[1] = C_Map.GetWorldPosFromMapPos(uiMapID, zeroVector)
		_, worldPosition[2] = C_Map.GetWorldPosFromMapPos(uiMapID, unitVector)

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

	playerPosition.x, playerPosition.y = UnitPosition('player')

	WoWRamblerProjectPositionHistory[GetServerTime()] = {
		["map"] = uiMapID,
		["x"] = playerPosition.x,
		["y"] = playerPosition.y,
		["combat"] = UnitAffectingCombat("player")
	}
end

function mainFrame:OnEvent(event, param)
	if event == "ADDON_LOADED" and param == AddonName then
		WoWRamblerProjectPositionHistory = WoWRamblerProjectPositionHistory or {}
		WoWRamblerProjectMapsCache = WoWRamblerProjectMapsCache or {}

		C_Timer.NewTicker(1, MonitorPosition)
	end
end

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:SetScript("OnEvent", mainFrame.OnEvent)
