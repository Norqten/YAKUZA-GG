local RESOURCE = GetCurrentResourceName()
local DATA_FILE = 'players.json'
local database = {}
local busy = {}

local cases = {
    basic = {label='Basic Case', price=100, rewards={
        {item='yakuza_energy', label='Yakuza Energy', count=3, weight=60},
        {item='ammo', label='Amunicja', count=50, weight=40}}},
    street = {label='Street Case', price=250, rewards={
        {item='armor', label='Kamizelka kuloodporna', count=1, weight=60},
        {item='vintage_pistol', label='Vintage Pistol', count=1, weight=40}}},
    yakuza = {label='Yakuza Case', price=500, rewards={
        {item='ammo', label='Amunicja', count=200, weight=55},
        {item='sns_pistol_mk2', label='SNS Pistol Mk II', count=1, weight=45}}},
    samurai = {label='Samurai Case', price=1000, rewards={
        {item='samurai_token', label='Żeton Samurai', count=1, weight=75},
        {item='samurai_skin', label='Skin Samurai', count=1, weight=25}}},
    legendary = {label='Legendary Case', price=2000, rewards={
        {item='legendary_token', label='Żeton Legendarny', count=1, weight=80},
        {item='legendary_skin', label='Skin Legendarny', count=1, weight=20}}}
}

local function save()
    SaveResourceFile(RESOURCE, DATA_FILE, json.encode(database), -1)
end

local function keyFor(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, 8) == 'license:' then return identifier end
    end
    return nil
end

local function playerData(src)
    local key = keyFor(src)
    if not key then return nil end
    if not database[key] then
        database[key] = {coins=0, items={}, history={}}
    end
    local data = database[key]
    data.coins = math.max(0, math.floor(tonumber(data.coins) or 0))
    data.items = type(data.items)=='table' and data.items or {}
    data.history = type(data.history)=='table' and data.history or {}
    return data
end

local function publicCases()
    local list = {}
    for id, entry in pairs(cases) do
        local rewards = {}
        for _, reward in ipairs(entry.rewards) do
            rewards[#rewards+1] = {label=reward.label, count=reward.count, chance=reward.weight}
        end
        list[#list+1] = {id=id, label=entry.label, price=entry.price, rewards=rewards}
    end
    table.sort(list, function(a,b) return a.price < b.price end)
    return list
end

local function update(src)
    local data = playerData(src)
    if not data then return end
    TriggerClientEvent('yg_cases:update', src, {
        coins=data.coins, cases=publicCases(), history=data.history
    })
end

local function drawReward(rewards)
    local total = 0
    for _, reward in ipairs(rewards) do total = total + reward.weight end
    local roll = math.random(total)
    for _, reward in ipairs(rewards) do
        roll = roll - reward.weight
        if roll <= 0 then return reward end
    end
    return rewards[#rewards]
end

CreateThread(function()
    local raw = LoadResourceFile(RESOURCE, DATA_FILE)
    if raw and raw ~= '' then
        local ok, parsed = pcall(json.decode, raw)
        if ok and type(parsed)=='table' then database=parsed end
    end
    math.randomseed(os.time())
end)

RegisterNetEvent('yg_cases:request', function() update(source) end)

RegisterNetEvent('yg_cases:buy', function(caseId)
    local src = source
    if busy[src] then return end
    if type(caseId) ~= 'string' or not cases[caseId] then return end
    busy[src] = true
    local data = playerData(src)
    local selected = cases[caseId]
    if not data then
        TriggerClientEvent('yg_cases:result', src, {ok=false, message='Brak identyfikatora FiveM.'})
    elseif data.coins < selected.price then
        TriggerClientEvent('yg_cases:result', src, {ok=false, message='Za mało Yakuza Coins.'})
    else
        local reward = drawReward(selected.rewards)
        data.coins = data.coins - selected.price
        data.items[reward.item] = (tonumber(data.items[reward.item]) or 0) + reward.count
        table.insert(data.history, 1, {
            case=selected.label, reward=reward.label, count=reward.count,
            date=os.date('!%Y-%m-%d %H:%M UTC')
        })
        while #data.history > 20 do table.remove(data.history) end
        save()
        TriggerClientEvent('yg_cases:result', src, {
            ok=true, message=('Zdobyto: %s x%d'):format(reward.label,reward.count),
            rewardLabel=reward.label, rewardCount=reward.count, caseId=caseId
        })
        print(('[YAKUZA CASES] %s opened %s -> %s x%d'):format(
            GetPlayerName(src) or src,caseId,reward.item,reward.count))
        update(src)
    end
    busy[src] = nil
end)

-- Only admins with ACE permission yg.cases.grant can issue coins.
RegisterCommand('giveyc', function(src, args)
    if src ~= 0 and not IsPlayerAceAllowed(src, 'yg.cases.grant') then
        TriggerClientEvent('chat:addMessage', src, {args={'YAKUZA','Brak uprawnień.'}})
        return
    end
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    if not target or not GetPlayerName(target) or not amount or amount ~= math.floor(amount)
        or amount < 1 or amount > 100000 then
        print('Użycie: giveyc [ID gracza] [1-100000]')
        return
    end
    local data = playerData(target)
    if not data then return end
    data.coins = data.coins + amount
    save()
    update(target)
    print(('[YAKUZA CASES] %s granted %d YC to %s'):format(src,amount,target))
end, false)

AddEventHandler('playerDropped', function() busy[source] = nil end)
