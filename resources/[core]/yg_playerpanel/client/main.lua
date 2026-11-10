local panelOpen = false

local function setPanelVisible(state)
    panelOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = state and 'open' or 'close'
    })

    if state then
        TriggerServerEvent('yg_playerpanel:server:requestData')
    end
end

RegisterCommand('yg_playerpanel', function()
    setPanelVisible(not panelOpen)
end, false)

RegisterKeyMapping('yg_playerpanel', 'Otwórz panel gracza YAKUZA - GG', 'keyboard', 'F2')

RegisterNetEvent('yg_playerpanel:client:updateData', function(data)
    if not panelOpen or type(data) ~= 'table' then return end

    SendNUIMessage({
        action = 'update',
        data = data
    })
end)

RegisterNUICallback('close', function(_, cb)
    setPanelVisible(false)
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('yg_playerpanel:server:requestData')
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
