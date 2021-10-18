local carry = {
  carrying = false,
  serverId = -1,
  type = '',
}

local function GetClosestPlayer(radius)
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()

  for _, playerId in ipairs(GetActivePlayers()) do
    local playerPed = GetPlayerPed(playerId)
    if playerPed ~= ped and DoesEntityExist(playerPed) then
      local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(ped))
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

local function ensureAnimDict(anim)
  if not HasAnimDictLoaded(anim) then
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
      Wait(0)
    end
  end
  return anim
end

RegisterCommand('carry', function()
  if not carry.carrying then
    local closestPlayer = GetClosestPlayer(3)
    if closestPlayer then
      local serverId = GetPlayerServerId(closestPlayer)
      if serverId ~= -1 then
        carry.carrying = true
        carry.serverId = serverId
        TriggerServerEvent('CarryPeople:sync', serverId)
        ensureAnimDict('missfinale_c2mcs_1')
        carry.type = 'carrying'
      end
    end
  else
    carry.carrying = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
    TriggerServerEvent('CarryPeople:stop', carry.serverId)
    carry.serverId = 0
  end
end, false)

RegisterNetEvent('CarryPeople:syncTarget', function(targetSrc)
  local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
  carry.carrying = true
  ensureAnimDict('nm')
  AttachEntityToEntity(PlayerPedId(), targetPed, 0, .27, .15, .63, .5, .5, 180, false, false, false, false, 2, false)
  carry.type = 'beingcarried'
end)

RegisterNetEvent('CarryPeople:cl_stop', function()
  carry.carrying = false
  ClearPedSecondaryTask(PlayerPedId())
  DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
  while true do
    if carry.carrying then
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