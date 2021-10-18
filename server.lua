local carrying = {}
local carried = {}

RegisterServerEvent('CarryPeople:sync')
AddEventHandler('CarryPeople:sync', function(serverId)
  if #(
    GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(serverId))
  ) <= 3.0 then
    TriggerClientEvent('CarryPeople:syncTarget', serverId, source)
    carrying[source] = serverId
    carried[serverId] = source
  end
end)

RegisterServerEvent('CarryPeople:stop', function(serverId)
  if carrying[source] then
    TriggerClientEvent('CarryPeople:cl_stop', serverId)
    carrying[source] = nil
    carried[serverId] = nil
  elseif carried[source] then
    TriggerClientEvent('CarryPeople:cl_stop', carried[source])
    carrying[carried[source]] = nil
    carried[source] = nil
  end
end)

AddEventHandler('playerDropped', function()
  if carrying[source] then
    TriggerClientEvent('CarryPeople:cl_stop', carrying[source])
    carried[carrying[source]] = nil
    carrying[source] = nil
  end

  if carried[source] then
    TriggerClientEvent('CarryPeople:cl_stop', carried[source])
    carrying[carried[source]] = nil
    carried[source] = nil
  end
end)
