local isSpawning = false
local hasSpawned = false

local function spawnPlayer()
    if isSpawning then return end
    isSpawning = true

    local coords = Config.Spawn
    local model = GetHashKey('a_m_y_skater_01')

    -- Spawnmanager creates the first ped; moving PlayerPedId alone does not.
    exports.spawnmanager:spawnPlayer({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = coords.heading,
        model = model,
        skipFade = false
    }, function()
        local ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(ped, coords.heading)
        ClearPlayerWantedLevel(PlayerId())
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        FreezeEntityPosition(ped, false)
        hasSpawned = true
        isSpawning = false
        DoScreenFadeIn(600)
        print('^2[YAKUZA - GG]^7 Player spawned at Legion Square.')
    end)

    -- Recovery if another script has left the screen faded out.
    SetTimeout(10000, function()
        if isSpawning then
            isSpawning = false
            print('^3[YAKUZA - GG]^7 Spawn timeout; try /spawn.')
        end
        if IsScreenFadedOut() or IsScreenFadingOut() then
            DoScreenFadeIn(600)
        end
    end)
end

RegisterCommand('spawn', function()
    spawnPlayer()
end, false)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
    Wait(1500)
    if not hasSpawned then spawnPlayer() end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
        Wait(1200)
        if not hasSpawned then spawnPlayer() end
    end)
end)

print('^1[YAKUZA - GG]^7 Spawn resource loaded. Use /spawn.')
