local carry = {
	InProgress = false,
	targetSrc = -1,
	type = '',
}

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
	if closestDistance ~= -1 and closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

RegisterCommand('carry',function(source, args)
	if not carry.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent('CarryPeople:sync',targetSrc)
				ensureAnimDict('missfinale_c2mcs_1')
				carry.type = 'carrying'
			end
		end
	else
		carry.InProgress = false
		ClearPedSecondaryTask(PlayerPedId())
		DetachEntity(PlayerPedId(), true, false)
		TriggerServerEvent('CarryPeople:stop',carry.targetSrc)
		carry.targetSrc = 0
	end
end,false)

RegisterNetEvent('CarryPeople:syncTarget', function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	carry.InProgress = true
	ensureAnimDict('nm')
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, .27, .15, .63, 0.5, 0.5, 180, false, false, false, false, 2, false)
	carry.type = 'beingcarried'
end)

RegisterNetEvent('CarryPeople:cl_stop', function()
	carry.InProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if carry.InProgress then
			if carry.type == 'beingcarried' then
				if not IsEntityPlayingAnim(PlayerPedId(), 'nm', 'firemans_carry', 3) then
					TaskPlayAnim(PlayerPedId(), 'nm', 'firemans_carry', 8.0, -8.0, 100000, 33, 0, false, false, false)
				end
			elseif carry.type == 'carrying' then
				if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 3) then
					TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, 100000, 49, 0, false, false, false)
				end
			end
		end
		Wait(0)
	end
end)