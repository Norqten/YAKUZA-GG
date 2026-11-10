local active = false
local saved = nil
local spawn = vector4(195.17, -933.77, 30.69, 144.5)
local models = {male = 'mp_m_freemode_01', female = 'mp_f_freemode_01'}
local outfits = {
 male = {
  {top=15, torso=15, legs=21, shoes=34},
  {top=4, torso=11, legs=24, shoes=10},
  {top=1, torso=6, legs=5, shoes=6}
 },
 female = {
  {top=15, torso=15, legs=15, shoes=35},
  {top=4, torso=3, legs=16, shoes=6},
  {top=2, torso=8, legs=5, shoes=3}
 }
}
local function loadSaved()
 local raw = GetResourceKvpString('yg_character_data')
 if raw then
  local ok, data = pcall(json.decode, raw)
  if ok and type(data)=='table' and models[data.gender] then return data end
 end
 return nil
end
local function applyLook(data)
 local ped = PlayerPedId()
 SetPedDefaultComponentVariation(ped)
 local set = (outfits[data.gender] or outfits.male)[math.max(1,math.min(3,tonumber(data.outfit) or 1))]
 SetPedComponentVariation(ped, 3, set.torso, 0, 0)
 SetPedComponentVariation(ped, 4, set.legs, 0, 0)
 SetPedComponentVariation(ped, 6, set.shoes, 0, 0)
 SetPedComponentVariation(ped, 8, 15, 0, 0)
 SetPedComponentVariation(ped, 11, set.top, 0, 0)
 local bag = tonumber(data.bag) or 0
 if bag == 1 then
  SetPedComponentVariation(ped, 5, 40, 0, 0)
 elseif bag == 2 then
  SetPedComponentVariation(ped, 5, 41, 0, 0)
 else
  SetPedComponentVariation(ped, 5, 0, 0, 0)
 end
end
local function enter(data)
 if active then return end
 active = true
 SetNuiFocus(false,false)
 SendNUIMessage({action='close'})
 local model = joaat(models[data.gender])
 exports.spawnmanager:spawnPlayer({
  x=spawn.x,y=spawn.y,z=spawn.z,heading=spawn.w,model=model,skipFade=false
 },function()
  applyLook(data)
  FreezeEntityPosition(PlayerPedId(),false)
  DisplayRadar(true)
  DoScreenFadeIn(500)
  active=false
 end)
end
local function openMenu()
 if active then return end
 active=true
 DoScreenFadeIn(500)
 DisplayRadar(false)
 SetNuiFocus(true,true)
 SendNUIMessage({action='open', saved=saved})
end
RegisterNUICallback('select',function(data,cb)
 if type(data)~='table' or not models[data.gender] then cb({ok=false}) return end
 local look={gender=data.gender,outfit=math.max(1,math.min(3,tonumber(data.outfit) or 1)),bag=math.max(0,math.min(2,tonumber(data.bag) or 0))}
 saved=look
 SetResourceKvp('yg_character_data',json.encode(look))
 active=false
 enter(look)
 cb({ok=true})
end)
RegisterNUICallback('close',function(_,cb)
 if saved then
  active=false
  enter(saved)
 end
 cb({ok=true})
end)
RegisterCommand('postac',function()
 if not active then openMenu() end
end,false)
CreateThread(function()
 while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
 Wait(2300)
 saved=loadSaved()
 openMenu()
end)
AddEventHandler('onClientResourceStart',function(name)
 if name~=GetCurrentResourceName() then return end
 CreateThread(function()
  while not NetworkIsPlayerActive(PlayerId()) do Wait(250) end
  Wait(2300)
  saved=loadSaved()
  if not active then openMenu() end
 end)
end)
