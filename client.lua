local ESX = nil
local PlayerData = {}
local Items = {}
local Armes = {}
local ArgentSale = {}
local societyGangsmoney = nil
local societyblackmoney = nil
local IsHandcuffed, DragStatus = false, {}
DragStatus.IsDragged = false


Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	while ESX == nil do Citizen.Wait(100) end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)
    

local GangsInServer = {
    Garage = {},
    Coffre = {},
    Boss = {}
};


--- MenuGangs


local function MarquerJoueur()
        local ped = GetPlayerPed(ESX.Game.GetClosestPlayer())
        local pos = GetEntityCoords(ped)
        local target, distance = ESX.Game.GetClosestPlayer()
end

local function getPlayerInvGang(player)
    Items = {}
    Armes = {}
    ArgentSale = {}
    
    ESX.TriggerServerCallback('rGangBuilder:getOtherPlayerData', function(data)
        for i=1, #data.accounts, 1 do
            if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
                table.insert(ArgentSale, {
                    label    = ESX.Math.Round(data.accounts[i].money),
                    value    = 'black_money',
                    itemType = 'item_account',
                    amount   = data.accounts[i].money
                })
    
                break
            end
        end

        for i=1, #data.weapons, 1 do
            table.insert(Armes, {
                label    = ESX.GetWeaponLabel(data.weapons[i].name),
                value    = data.weapons[i].name,
                right    = data.weapons[i].ammo,
                itemType = 'item_weapon',
                amount   = data.weapons[i].ammo
            })
        end
    
        for i=1, #data.inventory, 1 do
            if data.inventory[i].count > 0 then
                table.insert(Items, {
                    label    = data.inventory[i].label,
                    right    = data.inventory[i].count,
                    value    = data.inventory[i].name,
                    itemType = 'item_standard',
                    amount   = data.inventory[i].count
                })
            end
        end
    end, GetPlayerServerId(player))
end

local function MenuGangs(gang)
    local MenuGang = RageUI.CreateMenu("Menu "..gang.Label, "Interactions")
    local MenuGangSub = RageUI.CreateSubMenu(MenuGang, "Menu "..gang.Label, "Interactions")
        RageUI.Visible(MenuGang, not RageUI.Visible(MenuGang))
            while MenuGang do
                Citizen.Wait(0)
                    RageUI.IsVisible(MenuGang, true, true, true, function()

            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            local target, distance = ESX.Game.GetClosestPlayer()
            playerheading = GetEntityHeading(GetPlayerPed(-1))
            playerlocation = GetEntityForwardVector(PlayerPedId())
            playerCoords = GetEntityCoords(GetPlayerPed(-1))
            local target_id = GetPlayerServerId(target)
            RageUI.ButtonWithStyle('Fouiller', nil, {RightLabel = "→"}, closestPlayer ~= -1 and closestDistance <= 3.0, function(_, a, s)
                if a then
                    MarquerJoueur()
                    if s then
                    getPlayerInvGang(closestPlayer)
                end
            end
            end, MenuGangSub)
            
        RageUI.ButtonWithStyle("Carte d'identité", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local target, distance = ESX.Game.GetClosestPlayer()
                    playerheading = GetEntityHeading(GetPlayerPed(-1))
                    playerlocation = GetEntityForwardVector(PlayerPedId())
                    playerCoords = GetEntityCoords(GetPlayerPed(-1))
                    local target_id = GetPlayerServerId(target)
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then  
                    ESX.ShowNotification("Recherche en cours...")
                    Citizen.Wait(2000)
                    carteidentite(closestPlayer)
            else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
            end
        end)
            
        RageUI.ButtonWithStyle("Menotter/démenotter", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if (Selected) then
                local target, distance = ESX.Game.GetClosestPlayer()
                playerheading = GetEntityHeading(GetPlayerPed(-1))
                playerlocation = GetEntityForwardVector(PlayerPedId())
                playerCoords = GetEntityCoords(GetPlayerPed(-1))
                local target_id = GetPlayerServerId(target)
                if closestPlayer ~= -1 and closestDistance <= 3.0 then   
                TriggerServerEvent('rGangBuilder:handcuff', GetPlayerServerId(closestPlayer))
            else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
            end
        end)
            
            RageUI.ButtonWithStyle("Escorter", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local target, distance = ESX.Game.GetClosestPlayer()
                    playerheading = GetEntityHeading(GetPlayerPed(-1))
                    playerlocation = GetEntityForwardVector(PlayerPedId())
                    playerCoords = GetEntityCoords(GetPlayerPed(-1))
                    local target_id = GetPlayerServerId(target)
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then  
                TriggerServerEvent('rGangBuilder:drag', GetPlayerServerId(closestPlayer))
            else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
            end
        end)
            
            RageUI.ButtonWithStyle("Mettre dans un véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local target, distance = ESX.Game.GetClosestPlayer()
                    playerheading = GetEntityHeading(GetPlayerPed(-1))
                    playerlocation = GetEntityForwardVector(PlayerPedId())
                    playerCoords = GetEntityCoords(GetPlayerPed(-1))
                    local target_id = GetPlayerServerId(target)
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then  
                TriggerServerEvent('rGangBuilder:putInVehicle', GetPlayerServerId(closestPlayer))
            else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
                end
            end)
            
            RageUI.ButtonWithStyle("Sortir du véhicule", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local target, distance = ESX.Game.GetClosestPlayer()
                    playerheading = GetEntityHeading(GetPlayerPed(-1))
                    playerlocation = GetEntityForwardVector(PlayerPedId())
                    playerCoords = GetEntityCoords(GetPlayerPed(-1))
                    local target_id = GetPlayerServerId(target)
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then  
                TriggerServerEvent('rGangBuilder:OutVehicle', GetPlayerServerId(closestPlayer))
            else
                ESX.ShowNotification('Aucun joueurs à proximité')
            end
            end
        end)
        

        end, function()
        end)

        RageUI.IsVisible(MenuGangSub, true, true, true, function()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
            RageUI.Separator("Vous Fouiller : " ..GetPlayerName(closestPlayer))

            RageUI.Separator("↓ ~r~Argent non déclaré ~s~↓")
            for k,v  in pairs(ArgentSale) do
                RageUI.ButtonWithStyle("Argent non déclaré :", nil, {RightLabel = "~g~"..v.label.."$"}, true, function(_, _, s)
                    if s then
                        local combien = rGangBuilderKeyboardInput("Combien ?", '' , '', 8)
                        if tonumber(combien) > v.amount then
                            RageUI.Popup({message = "~r~Quantité invalide"})
                        else
                            TriggerServerEvent('rGangBuilder:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
                        end
                        RageUI.GoBack()
                    end
                end)
            end
    
            RageUI.Separator("↓ ~g~Objets ~s~↓")

            for k,v  in pairs(Items) do
                RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "~g~x"..v.right}, true, function(_, _, s)
                    if s then
                        local combien = rGangBuilderKeyboardInput("Combien ?", '' , '', 8)
                        if tonumber(combien) > v.amount then
                            RageUI.Popup({message = "~r~Quantité invalide"})
                        else
                            TriggerServerEvent('rGangBuilder:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
                        end
                        RageUI.GoBack()
                    end
                end)
            end

            RageUI.Separator("↓ ~g~Armes ~s~↓")

			for k,v  in pairs(Armes) do
				RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "avec ~g~"..v.right.. " ~s~balle(s)"}, true, function(_, _, s)
					if s then
						local combien = rGangBuilderKeyboardInput("Combien ?", '' , '', 8)
						if tonumber(combien) > v.amount then
							RageUI.Popup({message = "~r~Quantité invalide"})
						else
							TriggerServerEvent('rGangBuilder:confiscatePlayerItem', GetPlayerServerId(closestPlayer), v.itemType, v.value, tonumber(combien))
						end
						RageUI.GoBack()
					end
				end)
			end
    
            end, function() 
            end)

            if not RageUI.Visible(MenuGang) and not RageUI.Visible(MenuGangSub) then
                MenuGang = RMenu:DeleteType("Menu Fouille", true)
        end
    end
end


function carteidentite(player)
    local StockFouille = RageUI.CreateMenu("Carte d'identité", "Informations")
    ESX.TriggerServerCallback('rGangBuilder:getOtherPlayerDataa', function(data)
    RageUI.Visible(StockFouille, not RageUI.Visible(StockFouille))
        while StockFouille do
            Citizen.Wait(0)
                RageUI.IsVisible(StockFouille, true, true, true, function()
                            RageUI.ButtonWithStyle("Prenom & Nom : ", nil, {RightLabel = data.name}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.ButtonWithStyle("Sexe : ", nil, {RightLabel = data.sex}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.ButtonWithStyle("Taille : ", nil, {RightLabel = data.height}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.ButtonWithStyle("Né le : ", nil, {RightLabel = data.dob}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.ButtonWithStyle("Metier : ", nil, {RightLabel = data.job.." - "..data.grade}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.ButtonWithStyle("Orga : ", nil, {RightLabel = data.job2.." - "..data.grade2}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                            RageUI.Separator("↓ Permis ↓")
                            for i=1, #data.licenses, 1 do
                            RageUI.ButtonWithStyle(data.licenses[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                                if Selected then
                                end
                            end)
                        end
                end, function()
                end)
            if not RageUI.Visible(StockFouille) then
            StockFouille = RMenu:DeleteType("Carte d'identite", true)
        end
    end
end, GetPlayerServerId(player))
end

-------------------------- Intéraction 

RegisterNetEvent('rGangBuilder:handcuff')
AddEventHandler('rGangBuilder:handcuff', function()

  IsHandcuffed    = not IsHandcuffed;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()

    if IsHandcuffed then

        RequestAnimDict('mp_arresting')
        while not HasAnimDictLoaded('mp_arresting') do
            Citizen.Wait(100)
        end

      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
      DisableControlAction(2, 37, true)
      SetEnableHandcuffs(playerPed, true)
      SetPedCanPlayGestureAnims(playerPed, false)
      FreezeEntityPosition(playerPed,  true)
      DisableControlAction(0, 24, true) -- Attack
      DisableControlAction(0, 257, true) -- Attack 2
      DisableControlAction(0, 25, true) -- Aim
      DisableControlAction(0, 263, true) -- Melee Attack 1
      DisableControlAction(0, 37, true) -- Select Weapon
      DisableControlAction(0, 47, true)  -- Disable weapon
      

    else

      ClearPedSecondaryTask(playerPed)
      SetEnableHandcuffs(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)

    end

  end)
end)

RegisterNetEvent('rGangBuilder:drag')
AddEventHandler('rGangBuilder:drag', function(cop)
  TriggerServerEvent('esx:clientLog', 'starting dragging')
  IsDragged = not IsDragged
  CopPed = tonumber(cop)
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('rGangBuilder:putInVehicle')
AddEventHandler('rGangBuilder:putInVehicle', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)

RegisterNetEvent('rGangBuilder:OutVehicle')
AddEventHandler('rGangBuilder:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

-- Handcuff

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)



Keys.Register('F7', 'rGangBuilder', 'Ouvrir le menu du gang', function()
    ESX.TriggerServerCallback('rGangBuilder:getAllGang', function(result)
        for k,v in pairs(result) do
            if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == v.Name then
            MenuGangs(v)
            end
        end
    end)
end)



----- Garage

function GarageMenuGangs()
    local MenuG = RageUI.CreateMenu("Garage", GangsInServer.Garage.Label)
      RageUI.Visible(MenuG, not RageUI.Visible(MenuG))
          while MenuG do
              Citizen.Wait(0)
                  RageUI.IsVisible(MenuG, true, true, true, function()
                      RageUI.ButtonWithStyle("Ranger la voiture", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then   
                          local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                          if dist4 < 4 then
                              DeleteEntity(veh)
                              end 
                          end
                      end)

                      RageUI.Separator("~y~↓ Véhicule disponible ↓")
  
                      for k,v in pairs(Config.VoitureGangs) do
                      RageUI.ButtonWithStyle(v.nom, nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
                          if (Selected) then
                              SpawnCarForGangs(v.modele, GangsInServer.Garage.Name)
                              RageUI.CloseAll()
                              end
                          end)
                      end
                  end, function()
                  end)
              if not RageUI.Visible(MenuG) then
                MenuG = RMenu:DeleteType("MenuG", true)
          end
      end
end

function SpawnCarForGangs(car, name)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local PosSpawn = vector3(json.decode(GangsInServer.Garage.PosVehSpawn).x, json.decode(GangsInServer.Garage.PosVehSpawn).y, json.decode(GangsInServer.Garage.PosVehSpawn).z)
    local vehicle = CreateVehicle(car, PosSpawn, GetEntityHeading(PlayerPedId()), true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    local plaque = name..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(GetPlayerPed(-1),vehicle,-1)
    SetVehicleCustomPrimaryColour(vehicle, Config.colorForCar[name].r, Config.colorForCar[name].g, Config.colorForCar[name].b)
    SetVehicleCustomSecondaryColour(vehicle, Config.colorForCar[name].r, Config.colorForCar[name].g, Config.colorForCar[name].b)
end

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rGangBuilder:getAllGang', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == v.Name then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Garage = vector3(json.decode(v.PosGarage).x, json.decode(v.PosGarage).y, json.decode(v.PosGarage).z)
            local dist = #(plyPos-Garage)
            if dist <= 10.0 then
                Timer = 0
                DrawMarker(22, Garage, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ouvrir le garage", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    GangsInServer.Garage = v
                    GarageMenuGangs()
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)

--- Coffre

function MenuCoffreGangs(Label)
    local MenuCoffre = RageUI.CreateMenu("Coffre "..Label, "Interaction")
        RageUI.Visible(MenuCoffre, not RageUI.Visible(MenuCoffre))
            while MenuCoffre do
            Citizen.Wait(0)
            RageUI.IsVisible(MenuCoffre, true, true, true, function()

                RageUI.Separator("~r~Organisation : "..Label)

                RageUI.ButtonWithStyle("Prendre objet",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreRetirer()
                        RageUI.CloseAll()
                    end
                end)
                
                RageUI.ButtonWithStyle("Déposer objet",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreDeposer()
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Prendre Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreRetirerWeapon()
                        RageUI.CloseAll()
                    end
                end)
                
                RageUI.ButtonWithStyle("Déposer Arme(s)",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        CoffreDeposerWeapon()
                        RageUI.CloseAll()
                    end
                end)

                end, function()
                end)
            if not RageUI.Visible(MenuCoffre) then
            MenuCoffre = RMenu:DeleteType("MenuCoffre", true)
        end
    end
end


itemstock = {}
function CoffreRetirer()
    local StockCoffre = RageUI.CreateMenu("Coffre", GangsInServer.Coffre.Label)
    ESX.TriggerServerCallback('rGangBuilder:getStockItems', function(items) 
    itemstock = items
    RageUI.Visible(StockCoffre, not RageUI.Visible(StockCoffre))
        while StockCoffre do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffre, true, true, true, function()
                        for k,v in pairs(itemstock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local cbRetirer = rGangBuilderKeyboardInput("Combien ?", "", 15)
                                    TriggerServerEvent('rGangBuilder:getStockItem', v.name, tonumber(cbRetirer), GangsInServer.Coffre.Name)
                                    CoffreRetirer()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffre) then
            StockCoffre = RMenu:DeleteType("Coffre", true)
        end
    end
    end, GangsInServer.Coffre.Name)
end

function CoffreDeposer()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire")
    ESX.TriggerServerCallback('rGangBuilder:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                        RageUI.ButtonWithStyle("~r~→~s~ "..item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local cbDeposer = rGangBuilderKeyboardInput("Combien ?", '' , 15)
                                            TriggerServerEvent('rGangBuilder:putStockItems', item.name, tonumber(cbDeposer), GangsInServer.Coffre.Name)
                                            CoffreDeposer()
                                        end
                                    end)
                            end
                    end
                end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


weaponsStock = {}
function CoffreRetirerWeapon()
    local StockCoffreWeapon = RageUI.CreateMenu("Coffre", GangsInServer.Coffre.Label)
    ESX.TriggerServerCallback('rGangBuilder:getArmoryWeapons', function(weapons) 
        weaponsStock = weapons
    RageUI.Visible(StockCoffreWeapon, not RageUI.Visible(StockCoffreWeapon))
        while StockCoffreWeapon do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffreWeapon, true, true, true, function()
                        for k,v in pairs(weaponsStock) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..ESX.GetWeaponLabel(v.name), nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    --local cbRetirer = rGangBuilderKeyboardInput("Combien ?", "", 15)
                                    ESX.TriggerServerCallback('rGangBuilder:removeArmoryWeapon', function()
                                        CoffreRetirerWeapon()
                                    end, v.name, GangsInServer.Coffre.Name)
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffreWeapon) then
            StockCoffreWeapon = RMenu:DeleteType("Coffre", true)
        end
    end
    end, GangsInServer.Coffre.Name)
end

function CoffreDeposerWeapon()
    local StockPlayerWeapon = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire d'armes")
        RageUI.Visible(StockPlayerWeapon, not RageUI.Visible(StockPlayerWeapon))
    while StockPlayerWeapon do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayerWeapon, true, true, true, function()
                
                local weaponList = ESX.GetWeaponList()

                for i=1, #weaponList, 1 do
                    local weaponHash = GetHashKey(weaponList[i].name)
                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    RageUI.ButtonWithStyle("~r~→~s~ "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                        --local cbDeposer = rGangBuilderKeyboardInput("Combien ?", '' , 15)
                        ESX.TriggerServerCallback('rGangBuilder:addArmoryWeapon', function()
                            CoffreDeposerWeapon()
                        end, weaponList[i].name, true, GangsInServer.Coffre.Name)
                    end
                end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Coffre", true)
            end
        end
end


Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rGangBuilder:getAllGang', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == v.Name then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Coffre = vector3(json.decode(v.PosCoffre).x, json.decode(v.PosCoffre).y, json.decode(v.PosCoffre).z)
            local dist = #(plyPos-Coffre)
            if dist <= 10.0 then
                Timer = 0
                DrawMarker(22, Coffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    GangsInServer.Coffre = v
                    MenuCoffreGangs(v.Label)
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)

local GangMembresList = {}

function MenuGangsBoss(LabelJob)
  local MenuBoss = RageUI.CreateMenu("Actions Patron", LabelJob)
  local MenuGestMembresGangs = RageUI.CreateSubMenu(MenuBoss, "Gestion Membres", LabelJob)
  local MenuGestMembresGangs2 = RageUI.CreateSubMenu(MenuGestMembresGangs, "Gestion Membres", LabelJob)
    RageUI.Visible(MenuBoss, not RageUI.Visible(MenuBoss))
            while MenuBoss do
                Citizen.Wait(0)
                    RageUI.IsVisible(MenuBoss, true, true, true, function()

                    if societyGangsmoney ~= nil then
                        RageUI.ButtonWithStyle("Argent société :", nil, {RightLabel = "$" .. societyGangsmoney}, true, function()
                        end)
                    end

                    RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Cbmoney = rGangBuilderKeyboardInput("Combien ?", '' , 15)
                            Cbmoney = tonumber(Cbmoney)
                            if Cbmoney == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('rGangBuilder:withdrawMoney', GangsInServer.Boss.SocietyName, Cbmoney)
                                RefreshGangsMoney()
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local Cbmoneyy = rGangBuilderKeyboardInput("Montant", "", 10)
                            Cbmoneyy = tonumber(Cbmoneyy)
                            if Cbmoneyy == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('rGangBuilder:depositMoney', GangsInServer.Boss.SocietyName, Cbmoneyy)
                                RefreshGangsMoney()
                            end
                        end
                    end)


                    RageUI.ButtonWithStyle("Gestion Membres", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                            local GangName = GangsInServer.Boss.Name
                            loadMembresGangs(GangName)
                        end
                    end, MenuGestMembresGangs)


                    RageUI.Separator("~r~↓ Argent sale ↓")


                if societyblackmoney ~= nil then
                    RageUI.Separator("~y~Argent sale : "..societyblackmoney.."$")
                end

                RageUI.ButtonWithStyle("Déposer argent sale",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local count = rGangBuilderKeyboardInput("Combien ?", "", 100)
                        TriggerServerEvent('rGangBuilder:putblackmoney', 'item_account', 'black_money', tonumber(count), GangsInServer.Boss.Name)
                        RefreshblackMoney()
                    end
                end)

                RageUI.ButtonWithStyle("Retirer argent sale",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local count = rGangBuilderKeyboardInput("Combien ?", "", 100)
                        TriggerServerEvent('rGangBuilder:getItem', 'item_account', 'black_money', tonumber(count), GangsInServer.Boss.Name)
                        RefreshblackMoney()
                    end
                end)

            end, function()
            end)

            RageUI.IsVisible(MenuGestMembresGangs, true, true, true, function()

                if #GangMembresList == 0 then
                    RageUI.Separator("")
                    RageUI.Separator("Aucune Membres")
                    RageUI.Separator("")
                end

                for k,v in pairs(GangMembresList) do
                    RageUI.ButtonWithStyle(v.Name, false, {RightLabel = "~b~→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            Ply = v
                        end
                    end, MenuGestMembresGangs2)
                end

            end, function()
            end)

            RageUI.IsVisible(MenuGestMembresGangs2, true, true, true, function()

                RageUI.ButtonWithStyle("Virer ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rGangBuilder:Bossvirer', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Promouvoir ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rGangBuilder:Bosspromouvoir', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

                RageUI.ButtonWithStyle("Destituer ~y~"..Ply.Name,nil, {RightLabel = "~r~→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('rGangBuilder:Bossdestituer', Ply.InfoMec)
                        RageUI.CloseAll()
                    end
                end)

            end, function()
            end)

            if not RageUI.Visible(MenuBoss) and not RageUI.Visible(MenuGestMembresGangs) and not RageUI.Visible(MenuGestMembresGangs2) then
            MenuBoss = RMenu:DeleteType("MenuBoss", true)
        end
    end
end

function RefreshblackMoney()
    if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
        ESX.TriggerServerCallback('rGangBuilder:getBlackMoneySociety', function(inventory)
            UpdateSocietyblackMoney(inventory)
        end, ESX.PlayerData.job2.name)
    end
end

function UpdateSocietyblackMoney(inventory)
    societyblackmoney = ESX.Math.GroupDigits(inventory.blackMoney)
end

function loadMembresGangs(Gang)
    ESX.TriggerServerCallback('rGangBuilder:GetGangsMembres', function(Membres)
        GangMembresList = Membres
    end, Gang)
end

function RefreshGangsMoney()
    if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
        ESX.TriggerServerCallback('rGangBuilder:getSocietyMoney', function(money)
            UpdateSocietyGangsMoney(money)
        end, "society_"..ESX.PlayerData.job2.name)
    end
end

function UpdateSocietyGangsMoney(money)
    societyGangsmoney = ESX.Math.GroupDigits(money)
end

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rGangBuilder:getAllGang', function(result)
    while true do
        local Timer = 500
            for k,v in pairs(result) do
            if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == v.Name and ESX.PlayerData.job2.grade_name == 'boss' then
            local plyPos = GetEntityCoords(PlayerPedId())
            local Boss = vector3(json.decode(v.PosBoss).x, json.decode(v.PosBoss).y, json.decode(v.PosBoss).z)
            local dist = #(plyPos-Boss)
            if dist <= 10.0 then
                Timer = 0
                DrawMarker(22, Boss, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
            end
            if dist <= 3.0 then
                Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
                if IsControlJustPressed(1,51) then
                    GangsInServer.Boss = v
                    RefreshGangsMoney()
                    RefreshblackMoney()
                    MenuGangsBoss(v.Label)
                end
            end
        end
        end
        Citizen.Wait(Timer)
    end
end)
end)