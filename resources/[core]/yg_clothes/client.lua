local components = { [1]='Maska', [3]='Ramiona', [4]='Spodnie', [5]='Torba', [6]='Buty', [7]='Akcesoria', [8]='Podkoszulek', [9]='Kamizelka', [10]='Naszywki', [11]='Bluza/kurtka' }
local props = { [0]='Czapka', [1]='Okulary', [2]='Uszy', [6]='Zegarek', [7]='Bransoletka' }
local function say(msg) TriggerEvent('chat:addMessage', {args={'YAKUZA - GG', msg}}) end
RegisterCommand('ciuchy', function()
    say('Garderoba: /ubranie [slot] [model] [tekstura], /dodatek [slot] [model] [tekstura], /zdejmij [slot]')
    say('Ubrania: 1 maska, 4 spodnie, 6 buty, 8 podkoszulek, 11 bluza/kurtka. Dodatki: 0 czapka, 1 okulary.')
    say('Sprawdź zakres: /ubranie [slot] lub /dodatek [slot]. Numery zależą od modelu postaci.')
end, false)
RegisterCommand('ubranie', function(_, args)
    local slot, drawable, texture = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]) or 0
    if not slot or not components[slot] then say('Nieprawidłowy slot. Wpisz /ciuchy.') return end
    local ped = PlayerPedId()
    local count = GetNumberOfPedDrawableVariations(ped, slot)
    if not drawable then say(components[slot]..': modele 0-'..math.max(0,count-1)) return end
    if drawable < 0 or drawable >= count then say('Nieprawidłowy model; dostępne 0-'..math.max(0,count-1)) return end
    local textures = GetNumberOfPedTextureVariations(ped, slot, drawable)
    if texture < 0 or texture >= textures then say('Tekstury: 0-'..math.max(0,textures-1)) return end
    SetPedComponentVariation(ped, slot, drawable, texture, 0)
    say('Zmieniono: '..components[slot]..' ('..drawable..', '..texture..')')
end, false)
RegisterCommand('dodatek', function(_, args)
    local slot, drawable, texture = tonumber(args[1]), tonumber(args[2]), tonumber(args[3]) or 0
    if not slot or not props[slot] then say('Nieprawidłowy slot. Wpisz /ciuchy.') return end
    local ped = PlayerPedId()
    local count = GetNumberOfPedPropDrawableVariations(ped, slot)
    if not drawable then say(props[slot]..': modele 0-'..math.max(0,count-1)..'; -1 usuwa dodatek') return end
    if drawable == -1 then ClearPedProp(ped, slot) return end
    if drawable < 0 or drawable >= count then say('Nieprawidłowy model.') return end
    local textures = GetNumberOfPedPropTextureVariations(ped, slot, drawable)
    if texture < 0 or texture >= textures then say('Nieprawidłowa tekstura.') return end
    SetPedPropIndex(ped, slot, drawable, texture, true)
    say('Zmieniono: '..props[slot])
end, false)
RegisterCommand('zdejmij', function(_, args)
    local slot = tonumber(args[1])
    if not slot or not props[slot] then say('Podaj slot dodatku, np. /zdejmij 0') return end
    ClearPedProp(PlayerPedId(), slot)
    say('Zdjęto: '..props[slot])
end, false)
