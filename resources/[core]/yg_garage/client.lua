local vehicles = {
    {label='Sultan RS', model='sultanrs'},
    {label='Elegy RH8', model='elegy2'},
    {label='Banshee 900R', model='banshee2'},
    {label='Kuruma', model='kuruma'},
    {label='Jester', model='jester'},
    {label='Zentorno', model='zentorno'},
    {label='T20', model='t20'},
    {label='Adder', model='adder'},
    {label='Bati 801', model='bati'}
}
local currentVehicle = nil
local function notify(msg)
    TriggerEvent('chat:addMessage', {args={'YAKUZA - GG', msg}})
end
RegisterCommand('auta', function()
    notify('Garaż: /auto 1-9 | /usunauto')
    for i, v in ipairs(vehicles) do notify(i .. '. ' .. v.label) end
end, false)
RegisterCommand('auto', function(_, args)
    local index = tonumber(args[1])
    local chosen = index and vehicles[index]
    if not chosen then notify('Wpisz /auta, aby zobaczyć listę aut.') return end
    local model = joaat(chosen.model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        notify('Model auta jest niedostępny.') return
    end
    RequestModel(model)
    local deadline = GetGameTimer() + 8000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(50) end
    if not HasModelLoaded(model) then notify('Nie udało się wczytać auta.') return end
    local ped = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 6.0, 0.0)
    local heading = GetEntityHeading(ped)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        SetEntityAsMissionEntity(currentVehicle, true, true)
        DeleteVehicle(currentVehicle)
    end
    local vehicle = CreateVehicle(model, pos.x, pos.y, pos.z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    if not DoesEntityExist(vehicle) then notify('Nie udało się stworzyć auta.') return end
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, 'YAKUZA')
    SetPedIntoVehicle(ped, vehicle, -1)
    currentVehicle = vehicle
    notify('Wyciągnięto: ' .. chosen.label)
end, false)
RegisterCommand('usunauto', function()
    if currentVehicle and DoesEntityExist(currentVehicle) then
        SetEntityAsMissionEntity(currentVehicle, true, true)
        DeleteVehicle(currentVehicle)
        currentVehicle = nil
        notify('Usunięto Twoje ostatnie auto.')
    else notify('Nie masz auta do usunięcia.') end
end, false)
