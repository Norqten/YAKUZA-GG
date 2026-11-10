local open=false
local slots={
 {id='hair',name='Fryzura',kind='component',slot=2},
 {id='haircolor',name='Kolor włosów',kind='haircolor'},
 {id='beard',name='Zarost',kind='overlay',slot=1},
 {id='eyebrows',name='Brwi',kind='overlay',slot=2},
 {id='makeup',name='Makijaż',kind='overlay',slot=4},
 {id='lipstick',name='Pomadka',kind='overlay',slot=8},
 {id='mask',name='Maska',kind='component',slot=1},
 {id='arms',name='Ramiona',kind='component',slot=3},
 {id='pants',name='Spodnie',kind='component',slot=4},
 {id='shoes',name='Buty',kind='component',slot=6},
 {id='undershirt',name='Podkoszulek',kind='component',slot=8},
 {id='vest',name='Kamizelka',kind='component',slot=9},
 {id='jacket',name='Bluza / kurtka',kind='component',slot=11},
 {id='hat',name='Czapka',kind='prop',slot=0},
 {id='glasses',name='Okulary',kind='prop',slot=1}
}
local function options()
 local ped=PlayerPedId()
 local out={}
 for _,s in ipairs(slots) do
  local max=0
  local value=0
  local tex=0
  if s.kind=='component' then
   max=GetNumberOfPedDrawableVariations(ped,s.slot)-1
   value=GetPedDrawableVariation(ped,s.slot)
   tex=GetPedTextureVariation(ped,s.slot)
  elseif s.kind=='prop' then
   max=GetNumberOfPedPropDrawableVariations(ped,s.slot)-1
   value=GetPedPropIndex(ped,s.slot)
   tex=value>=0 and GetPedPropTextureIndex(ped,s.slot) or 0
  elseif s.kind=='haircolor' then
   max=GetNumHairColors()-1
   value=GetPedHairColor(ped)
  else
   max=GetNumHeadOverlayValues(s.slot)-1
   value=GetPedHeadOverlayValue(ped,s.slot)
   if value==255 then value=-1 end
  end
  out[#out+1]={id=s.id,name=s.name,kind=s.kind,slot=s.slot,min=(s.kind=='prop' or s.kind=='overlay') and -1 or 0,max=math.max(0,max),value=value,texture=tex}
 end
 return out
end
local function apply(s,value,texture)
 local ped=PlayerPedId()
 value=math.floor(tonumber(value) or 0)
 texture=math.floor(tonumber(texture) or 0)
 if s.kind=='component' then
  local n=GetNumberOfPedDrawableVariations(ped,s.slot)
  if value<0 or value>=n then return end
  local t=GetNumberOfPedTextureVariations(ped,s.slot,value)
  SetPedComponentVariation(ped,s.slot,value,math.max(0,math.min(texture,t-1)),0)
 elseif s.kind=='prop' then
  if value==-1 then ClearPedProp(ped,s.slot) return end
  if value<0 or value>=GetNumberOfPedPropDrawableVariations(ped,s.slot) then return end
  local t=GetNumberOfPedPropTextureVariations(ped,s.slot,value)
  SetPedPropIndex(ped,s.slot,value,math.max(0,math.min(texture,t-1)),true)
 elseif s.kind=='haircolor' then
  SetPedHairColor(ped,math.max(0,math.min(value,GetNumHairColors()-1)),0)
 elseif s.kind=='overlay' then
  if value< -1 or value>=GetNumHeadOverlayValues(s.slot) then return end
  SetPedHeadOverlay(ped,s.slot,value==-1 and 255 or value,value==-1 and 0.0 or 1.0)
 end
end
local function save()
 local ped=PlayerPedId()
 local data={model=GetEntityModel(ped),values=options()}
 SetResourceKvp('skin_'..tostring(GetPlayerServerId(PlayerId())),json.encode(data))
end
local function load()
 local raw=GetResourceKvpString('skin_'..tostring(GetPlayerServerId(PlayerId())))
 if not raw then return end
 local ok,data=pcall(json.decode,raw)
 if not ok or type(data)~='table' or data.model~=GetEntityModel(PlayerPedId()) or type(data.values)~='table' then return end
 for _,v in ipairs(data.values) do
  for _,s in ipairs(slots) do if s.id==v.id then apply(s,v.value,v.texture) break end end
 end
end
RegisterCommand('skin',function()
 if open then return end
 if not DoesEntityExist(PlayerPedId()) then return end
 open=true
 SetNuiFocus(true,true)
 SendNUIMessage({action='open',items=options()})
end,false)
RegisterNUICallback('change',function(data,cb)
 for _,s in ipairs(slots) do if s.id==data.id then apply(s,data.value,data.texture) break end end
 cb({items=options()})
end)
RegisterNUICallback('save',function(_,cb)
 save()
 open=false
 SetNuiFocus(false,false)
 SendNUIMessage({action='close'})
 cb({ok=true})
end)
RegisterNUICallback('close',function(_,cb)
 open=false
 SetNuiFocus(false,false)
 SendNUIMessage({action='close'})
 cb({ok=true})
end)
AddEventHandler('playerSpawned',function()
 Wait(2000)
 load()
end)
CreateThread(function()
 while not NetworkIsPlayerActive(PlayerId()) do Wait(500) end
 Wait(3500)
 load()
end)
