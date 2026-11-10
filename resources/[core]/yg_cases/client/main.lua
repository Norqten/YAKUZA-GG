local opened = false
local function toggle(state)
    opened = state
    SetNuiFocus(state, state)
    SendNUIMessage({action=state and 'open' or 'close'})
    if state then TriggerServerEvent('yg_cases:request') end
end

RegisterCommand('skrzynki', function() toggle(not opened) end, false)
RegisterNUICallback('close', function(_, cb) toggle(false) cb({ok=true}) end)
RegisterNUICallback('buy', function(data, cb)
    if type(data) == 'table' and type(data.case) == 'string' then
        TriggerServerEvent('yg_cases:buy', data.case)
    end
    cb({ok=true})
end)
RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('yg_cases:request')
    cb({ok=true})
end)
RegisterNetEvent('yg_cases:update', function(data)
    if opened then SendNUIMessage({action='update', data=data}) end
end)
RegisterNetEvent('yg_cases:result', function(data)
    if opened then SendNUIMessage({action='result', data=data}) end
end)
AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then SetNuiFocus(false,false) end
end)
