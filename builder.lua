local ESX = nil

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	while ESX == nil do Citizen.Wait(100) end
end)

function rGangBuilderKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local GestionGang = {};
local modEdit = false
local rGangBuilder = {
    Name = nil,
    Label = nil,
    PosVeh = nil,
    PosBoss = nil,
    PosCoffre = nil,
    PosSpawnVeh = nil
}

local function MenuGangBuilder()
    local MenuP = RageUI.CreateMenu('Créer un gang', '~g~Fataliste RP')
    MenuP.Closed = function()
        resetInfo()
    end
    RageUI.Visible(MenuP, not RageUI.Visible(MenuP))
    while MenuP do
        Citizen.Wait(0)

        RageUI.IsVisible(MenuP, true, true, true, function()

        RageUI.ButtonWithStyle("Nom",nil, {RightLabel = rGangBuilder.Name}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.Name = rGangBuilderKeyboardInput("Nom du gang", "", 30)
                ESX.ShowNotification("Ajouter Nom")
            end
        end)

        RageUI.ButtonWithStyle("Label",nil, {RightLabel = rGangBuilder.Label}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.Label = rGangBuilderKeyboardInput("Label du gang", "", 30)
                ESX.ShowNotification("Ajouter Label")
            end
        end)

        RageUI.ButtonWithStyle("Position du garage",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.PosVeh = GetEntityCoords(PlayerPedId())
                ESX.ShowNotification("Ajouter Position du garage")
            end
        end)

        RageUI.ButtonWithStyle("Position spawn véhicule",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.PosSpawnVeh = GetEntityCoords(PlayerPedId())
                ESX.ShowNotification("Ajouter Position spawn véhicule")
            end
        end)

        RageUI.ButtonWithStyle("Position du menu boss",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.PosBoss = GetEntityCoords(PlayerPedId())
                ESX.ShowNotification("Ajouter Position du menu boss")
            end
        end)

        RageUI.ButtonWithStyle("Position du coffre",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                rGangBuilder.PosCoffre = GetEntityCoords(PlayerPedId())
                ESX.ShowNotification("Ajouter Position du coffre")
            end
        end)

        RageUI.Separator('~y~↓ Action Disponible ↓')

        RageUI.ButtonWithStyle("~g~Valider",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            if Selected then
                if rGangBuilder.Name == nil or rGangBuilder.Label == nil or rGangBuilder.PosVeh == nil or rGangBuilder.PosCoffre == nil or rGangBuilder.PosBoss == nil or rGangBuilder.PosSpawnVeh == nil then
                    ESX.ShowNotification('~r~Un ou plusieurs champs n\'ont pas été défini !')
                else
                    TriggerServerEvent('rGangBuilder:addGang', rGangBuilder)
                    ESX.ShowNotification("Gang ajoute avec succès ~y~!")
                    resetInfo()
                end
            end
        end)

        RageUI.ButtonWithStyle('~r~Annuler' , nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected) 
            if (Selected) then
            resetInfo()
            RageUI.CloseAll()
            ESX.ShowNotification('~r~Annulation')
        end
    end)

        end, function()
        end)

        if not RageUI.Visible(MenuP) then
            MenuP = RMenu:DeleteType("MenuP", true)
        end
    end
end


RegisterCommand('creategang', function()
	ESX.TriggerServerCallback('rGangBuilder:getUsergroup', function(plyGroup)
		if plyGroup ~= nil and (plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
            MenuGangBuilder()
        else
            print("Vous n'avez pas les permissions de ouvrir le ~y~GangBuilder.")
        end
	end)
end, false)


function resetInfo()
    rGangBuilder.Name = nil
    rGangBuilder.Label = nil
    rGangBuilder.PosVeh = nil
    rGangBuilder.PosBoss = nil
    rGangBuilder.PosCoffre = nil
    rGangBuilder.PosSpawnVeh = nil
end


local function MenuGestionGangs()
    local MenuGestion = RageUI.CreateMenu('Gestionnaire Gangs', ' ')
    local MenuGestionSub = RageUI.CreateSubMenu(MenuGestion, 'Gestionnaire Gangs', ' ')
    RageUI.Visible(MenuGestion, not RageUI.Visible(MenuGestion))
    while MenuGestion do
        Citizen.Wait(0)

        RageUI.IsVisible(MenuGestion, true, true, true, function()

            RageUI.Checkbox("Activer/Désactiver le mode modification",nil, modEdit,{},function(Hovered,Ative,Selected,Checked)
                if Selected then

                    modEdit = Checked

                    if Checked then
                        RageUI.Popup({message = "Vous avez ~g~Activer~s~ le mode modification !"})
                    else
                        RageUI.Popup({message = "Vous avez ~r~Désactiver~s~ le mode modification !"})
                    end
                end
            end)

    if modEdit then

        for k,v in pairs(GestionGang) do

        RageUI.ButtonWithStyle("Gang : "..v.Label,nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                GangSelect = v
            end
        end, MenuGestionSub)

        end
    end

        end, function()
        end)

        RageUI.IsVisible(MenuGestionSub, true, true, true, function()

            RageUI.ButtonWithStyle("Position du garage",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rGangBuilder:editGang', 'Posgarage', plyPos, GangSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position spawn véhicule",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rGangBuilder:editGang', 'Posspawn', plyPos, GangSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position du menu boss",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rGangBuilder:editGang', 'PosBoss', plyPos, GangSelect.Name)
                end
            end)
    
            RageUI.ButtonWithStyle("Position du coffre",nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local plyPos = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('rGangBuilder:editGang', 'PosCoffre', plyPos, GangSelect.Name)
                end
            end)

        end, function()
        end)

        if not RageUI.Visible(MenuGestion) and not RageUI.Visible(MenuGestionSub) then
            MenuGestion = RMenu:DeleteType("MenuGestion", true)
        end
    end
end


RegisterCommand('gestiongang', function()
	ESX.TriggerServerCallback('rGangBuilder:getUsergroup', function(plyGroup)
		if plyGroup ~= nil and (plyGroup == 'admin' or plyGroup == 'superadmin' or plyGroup == 'owner' or plyGroup == '_dev') then
            ESX.TriggerServerCallback('rGangBuilder:getAllGang', function(result)
                GestionGang = result
            end)
                MenuGestionGangs()
        else
            print("Vous n'avez pas les permissions de ouvrir le ~y~Gestionnaire de gang.")
        end
	end)
end, false)