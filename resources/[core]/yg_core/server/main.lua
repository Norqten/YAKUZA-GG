local RESOURCE = GetCurrentResourceName()

print(('^1[YAKUZA - GG]^7 %s started.'):format(RESOURCE))

AddEventHandler('playerJoining', function()
    local playerId = source
    local playerName = GetPlayerName(playerId) or ('ID %s'):format(playerId)

    print(('^2[YAKUZA - GG]^7 %s (ID: %s) joined.'):format(playerName, playerId))
end)

RegisterNetEvent('yg_core:server:requestPlayerInfo', function()
    local playerId = source

    TriggerClientEvent('yg_core:client:playerInfo', playerId, {
        id = playerId,
        name = GetPlayerName(playerId) or 'Unknown'
    })
end)
