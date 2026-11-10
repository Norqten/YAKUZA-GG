RegisterNetEvent('yg_core:client:playerInfo', function(info)
    if type(info) ~= 'table' then return end

    print(('[YAKUZA - GG] Connected as %s (ID: %s)'):format(
        tostring(info.name or 'Unknown'),
        tostring(info.id or '?')
    ))
end)

CreateThread(function()
    Wait(1500)
    TriggerServerEvent('yg_core:server:requestPlayerInfo')
end)
