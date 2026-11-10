local isSpawning = false

local function spawnPlayer()
    if isSpawning then return end
    isSpawning = true

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(50)
    end

    local ped = PlayerPedId()
    local coords = Config.Spawn

    if IsEntityDead(ped) then
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
        ped = PlayerPedId()
    end

    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, coords.heading)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 0)
    FreezeEntityPosition(ped, false)

    Wait(300)
    DoScreenFadeIn(700)
    isSpawning = false
end

RegisterCommand('spawn', function()
    spawnPlayer()
end, false)

AddEventHandler('playerSpawned', function()
    Wait(Config.RespawnDelay)
    if not IsEntityDead(PlayerPedId()) then
        isSpawning = false
    end
end)

CreateThread(function()
    Wait(1500)
    if not NetworkIsPlayerActive(PlayerId()) then return end
    if not IsEntityDead(PlayerPedId()) then
        local coords = GetEntityCoords(PlayerPedId())
        if coords.x == 0.0 and coords.y == 0.0 then
            spawnPlayer()
        end
    end
end)

print('^1[YAKUZA - GG]^7 Spawn resource loaded. Use /spawn.')
