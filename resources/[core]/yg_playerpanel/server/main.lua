RegisterNetEvent('yg_playerpanel:server:requestData', function()
    local playerId = source
    local playerName = GetPlayerName(playerId) or 'Nieznany gracz'
    local playerCount = #GetPlayers()
    local maxPlayers = GetConvarInt('sv_maxclients', 48)
    local ping = GetPlayerPing(playerId)

    TriggerClientEvent('yg_playerpanel:client:updateData', playerId, {
        name = playerName,
        id = playerId,
        ping = ping,
        online = playerCount,
        maxPlayers = maxPlayers,
        serverName = GetConvar('sv_hostname', 'YAKUZA - GG')
    })
end)
