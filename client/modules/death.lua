local specmode = false
local oldcoords = nil

RegisterNetEvent("wld:delallveh")
AddEventHandler("wld:delallveh", function ()
    local totalvehc = 0
    local notdelvehc = 0

    for vehicle in EnumerateVehicles() do
        if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then SetVehicleHasBeenOwnedByPlayer(vehicle, false) SetEntityAsMissionEntity(vehicle, false, false) DeleteVehicle(vehicle)
            if (DoesEntityExist(vehicle)) then DeleteVehicle(vehicle) end
            if (DoesEntityExist(vehicle)) then notdelvehc = notdelvehc + 1 end
        end
        totalvehc = totalvehc + 1 
    end
    local vehfrac = totalvehc - notdelvehc .. " / " .. totalvehc
end)

RegisterNetEvent("erp-anticheat:teleporttoplayer")
AddEventHandler("erp-anticheat:teleporttoplayer", function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 1, 0, 0, 1)
end)

RegisterNetEvent("erp-anticheat:spectate")
AddEventHandler("erp-anticheat:spectate", function(targetPed, coords, id)
    oldcoords = GetEntityCoords(PlayerPedId())
    if not specmode then
        SetEntityVisible(PlayerPedId(), false, 0)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 1, 0, 0, 1)
        Wait(1000)
        --RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        NetworkSetInSpectatorMode(true, targetPed)
        --print(NetworkIsInSpectatorMode())
        specmode = true
    else
        SetEntityVisible(PlayerPedId(), true, 0)
        SetEntityCoords(PlayerPedId(), oldcoords.x, oldcoords.y, oldcoords.z, 1, 0, 0, 1)
        --RequestCollisionAtCoord(oldcoords.x, oldcoords.y, oldcoords.z)
        NetworkSetInSpectatorMode(false, targetPed)
        specmode = false
    end
end)

Round = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

local player = PlayerId()
local playerPed = PlayerPedId()

CreateThread(function()
	while true do
        Wait(0)
        if NetworkIsPlayerActive(player) then
            if IsEntityDead(playerPed) and not isDead then
                isDead = true
                local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
                local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
                if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
                    PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause, killerEntity)
                else
                    PlayerKilled(deathCause, killerEntity)
                end
            elseif not IsEntityDead(playerPed) then 
                isDead = false
            end
        else
            Wait(1000)
        end
	end
end)

CreateThread(function()
	while true do
		player = PlayerId()
		playerPed = PlayerPedId()
		Wait(1000)
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause, killerEntity)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {x = Round(victimCoords.x, 1), y = Round(victimCoords.y, 1), z = Round(victimCoords.z, 1)},
		killerCoords = {x = Round(killerCoords.x, 1), y = Round(killerCoords.y, 1), z = Round(killerCoords.z, 1)},

		killedByPlayer = true,
		deathCause = deathCause,
		distance = Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId,
		killerEntity = killerEntity
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

function PlayerKilled(deathCause, killerEntity)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = {x = Round(victimCoords.x, 1), y = Round(victimCoords.y, 1), z = Round(victimCoords.z, 1)},

		killedByPlayer = false,
		deathCause = deathCause,
		killerEntity = killerEntity
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end
