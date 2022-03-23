local ESX

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)


ESX.RegisterServerCallback('rGangBuilder:getUsergroup', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local plyGroup = xPlayer.getGroup()
	cb(plyGroup)
end)

RegisterServerEvent('rGangBuilder:addGang')
AddEventHandler('rGangBuilder:addGang', function(gang)
	MySQL.Async.execute([[
INSERT INTO `addon_account` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `addon_account` (name, label, shared) VALUES (@gangBSociety, @gangLabel, 1);
INSERT INTO `datastore` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `addon_inventory` (name, label, shared) VALUES (@gangSociety, @gangLabel, 1);
INSERT INTO `jobs` (`name`, `label`) VALUES (@gangName, @gangLabel);
INSERT INTO `gangbuilder` (name, label, society, posboss, posveh, poscoffre, posspawncar) VALUES (@gangName, @gangLabel, @gangSociety, @posboss, @posveh, @poscoffre, @posspawncar);
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	(@gangName, 0, 'soldato', 'Dealer', 0, '{}', '{}'),
	(@gangName, 1, 'capo', 'Braqueur', 0, '{}', '{}'),
	(@gangName, 2, 'consigliere', 'Bandit', 0, '{}', '{}'),
	(@gangName, 3, 'boss', 'Chef du Gang', 0, '{}', '{}')
;
	]], {
		['gangName'] = gang.Name,
		['gangLabel'] = gang.Label,
		['gangSociety'] = 'society_' .. gang.Name,
        ['posboss'] = json.encode(gang.PosBoss),
        ['posveh'] = json.encode(gang.PosVeh),
        ['poscoffre'] = json.encode(gang.PosCoffre),
		['posspawncar'] = json.encode(gang.PosSpawnVeh),
		['gangBSociety'] = 'society_' ..gang.Name.."_black"
	}, function(rowsChanged)
        print('Nouveau gang enregistrer : '..gang.Label);
	end)
end)


ESX.RegisterServerCallback("rGangBuilder:getAllGang", function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local Gangs = {}

    MySQL.Async.fetchAll("SELECT * FROM gangbuilder", {}, function(res)
        for _, v in pairs(res) do
            table.insert(Gangs, {
				Name = v.name,
				Label = v.label,
				SocietyName = v.society,
				PosBoss = v.posboss,
				PosGarage = v.posveh,
				PosCoffre = v.poscoffre,
				PosVehSpawn = v.posspawncar
			})
        end
        cb(Gangs)
    end)
end)



--- MenuGang

ESX.RegisterServerCallback('rGangBuilder:getOtherPlayerDataa', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            job2 = xPlayer.job2.label,
            grade2 = xPlayer.job2.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout(),
            height = xPlayer.get('height'),
            dob = xPlayer.get('dateofbirth')
        }
            if xPlayer.get('sex') == 'm' then data.sex = 'Homme' else data.sex = 'Femme' end

            TriggerEvent('esx_license:getLicenses', target, function(licenses)
                data.licenses = licenses
        cb(data)
        end)
    end
end)


RegisterServerEvent('rGangBuilder:handcuff')
AddEventHandler('rGangBuilder:handcuff', function(target)
  TriggerClientEvent('rGangBuilder:handcuff', target)
end)

RegisterServerEvent('rGangBuilder:drag')
AddEventHandler('rGangBuilder:drag', function(target)
  local _source = source
  TriggerClientEvent('rGangBuilder:drag', target, _source)
end)

RegisterServerEvent('rGangBuilder:putInVehicle')
AddEventHandler('rGangBuilder:putInVehicle', function(target)
  TriggerClientEvent('rGangBuilder:putInVehicle', target)
end)

RegisterServerEvent('rGangBuilder:OutVehicle')
AddEventHandler('rGangBuilder:OutVehicle', function(target)
    TriggerClientEvent('rGangBuilder:OutVehicle', target)
end)

-------------------------------- Fouiller

RegisterNetEvent('rGangBuilder:confiscatePlayerItem')
AddEventHandler('rGangBuilder:confiscatePlayerItem', function(target, itemType, itemName, amount)
    local _source = source
    local sourceXPlayer = ESX.GetPlayerFromId(_source)
    local targetXPlayer = ESX.GetPlayerFromId(target)

    if itemType == 'item_standard' then
        local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		
			targetXPlayer.removeInventoryItem(itemName, amount)
			sourceXPlayer.addInventoryItem   (itemName, amount)
            TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount..' '..sourceItem.label.."~s~.")
            TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a pris ~b~"..amount..' '..sourceItem.label.."~s~.")
        else
			--TriggerClientEvent("esx:showNotification", source, "~r~Quantidade inválida")
		end
        
    if itemType == 'item_account' then
        targetXPlayer.removeAccountMoney(itemName, amount)
        sourceXPlayer.addAccountMoney   (itemName, amount)
        
        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..amount.."€ ~s~argent non déclaré~s~.")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a pris ~b~"..amount.."€ ~s~argent non déclaré~s~.")
        
    end

	if itemType == 'item_weapon' then
        if amount == nil then amount = 0 end
        targetXPlayer.removeWeapon(itemName, amount)
        sourceXPlayer.addWeapon   (itemName, amount)

        TriggerClientEvent("esx:showNotification", source, "Vous avez confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
        TriggerClientEvent("esx:showNotification", target, "Quelqu'un vous a confisqué ~b~"..ESX.GetWeaponLabel(itemName).."~s~ avec ~b~"..amount.."~s~ balle(s).")
    end
end)

ESX.RegisterServerCallback('rGangBuilder:getOtherPlayerData', function(source, cb, target, notify)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~~Quelqu'un vous fouille")

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
            weapons = xPlayer.getLoadout()
        }

        cb(data)
    end
end)



--- Menu Coffre 


ESX.RegisterServerCallback('rGangBuilder:getStockItems', function(source, cb, society)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('rGangBuilder:getStockItem')
AddEventHandler('rGangBuilder:getStockItem', function(itemName, count, society)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _source, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

ESX.RegisterServerCallback('rGangBuilder:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('rGangBuilder:putStockItems')
AddEventHandler('rGangBuilder:putStockItems', function(itemName, count, society)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..society, function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)


--- MenuBoss

RegisterServerEvent('rGangBuilder:withdrawMoney')
AddEventHandler('rGangBuilder:withdrawMoney', function(societyName, amount)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

		TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
			if amount > 0 and account.money >= amount then
				account.removeMoney(amount)
				xPlayer.addMoney(amount)
                TriggerClientEvent('esx:showNotification', _src, "Vous avez retiré ~r~$"..ESX.Math.GroupDigits(amount))
			else
				TriggerClientEvent('esx:showNotification', _src, "Montant invalide")
			end
		end)
end)

RegisterServerEvent('rGangBuilder:depositMoney')
AddEventHandler('rGangBuilder:depositMoney', function(societyName, amount)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)

		if amount > 0 and xPlayer.getMoney() >= amount then
			TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
				xPlayer.removeMoney(amount)
				TriggerClientEvent('esx:showNotification', _src, "Vous avez déposé ~g~$"..ESX.Math.GroupDigits(amount))
				account.addMoney(amount)
			end)
		else
			TriggerClientEvent('esx:showNotification', _src, "Montant invalide")
		end
end)


ESX.RegisterServerCallback('rGangBuilder:getSocietyMoney', function(source, cb, societyName)
	if societyName then
		TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
			cb(account.money)
		end)
	else
		cb(0)
	end
end)


ESX.RegisterServerCallback('rGangBuilder:GetGangsMembres', function(source, cb, society)
	local xPlayer = ESX.GetPlayerFromId(source)
    local MembresduGang = {}

    MySQL.Async.fetchAll('SELECT * FROM users WHERE job2 = @job2', {
		['@job2'] = society
	},
        function(result)
        for _,v in pairs(result) do
			if v.job2_grade ~= 3 then
            table.insert(MembresduGang, {
				Name = v.firstname.." "..v.lastname,
				InfoMec = v.identifier,
				Gang = v.job2,
				Grade = v.job2_grade,
            })
			end
        end
        cb(MembresduGang)
    end)
end)


RegisterServerEvent('rGangBuilder:Bossvirer')
AddEventHandler('rGangBuilder:Bossvirer', function(target)
	local _src = source
	local sourceXPlayer = ESX.GetPlayerFromId(_src)
	local sourceJob2 = sourceXPlayer.getJob2()

	if sourceJob2.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromIdentifier(target)
		local targetJob2 = targetXPlayer.getJob2()

		if sourceJob2.name == targetJob2.name then
			targetXPlayer.setJob2('unemployed2', 0)
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~viré %s~w~.'):format(targetXPlayer.name))
			TriggerClientEvent('esx:showNotification', targetXPlayer.source, ('Vous avez été ~g~viré par %s~w~.'):format(sourceXPlayer.name))
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)


RegisterServerEvent('rGangBuilder:Bosspromouvoir')
AddEventHandler('rGangBuilder:Bosspromouvoir', function(target)
	local _src = source
	local sourceXPlayer = ESX.GetPlayerFromId(_src)
	local sourceJob2 = sourceXPlayer.getJob2()

	if sourceJob2.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromIdentifier(target)
		local targetJob2 = targetXPlayer.getJob2()

		if sourceJob2.name == targetJob2.name then
			local newGrade = tonumber(targetJob2.grade) + 1

			
			if newGrade ~= sourceJob2.grade then
				targetXPlayer.setJob2(targetJob2.name, newGrade)

				TriggerClientEvent('esx:showNotification', _src, ('Vous avez ~g~promu %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target.source, ('Vous avez été ~g~promu par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', _src, 'Vous devez demander une autorisation ~r~Gouvernementale~w~.')
			end
		else
			TriggerClientEvent('esx:showNotification', _src, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', _src, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)

RegisterServerEvent('rGangBuilder:Bossdestituer')
AddEventHandler('rGangBuilder:Bossdestituer', function(target)
	local _src = source
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceJob2 = sourceXPlayer.getJob2()

	if sourceJob2.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromIdentifier(target)
		local targetJob2 = targetXPlayer.getJob2()

		if sourceJob2.name == targetJob2.name then
			local newGrade = tonumber(targetJob2.grade) - 1

			if newGrade >= 0 then
				targetXPlayer.setJob2(targetJob2.name, newGrade)

				TriggerClientEvent('esx:showNotification', _src, ('Vous avez ~r~rétrogradé %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~r~rétrogradé par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', _src, 'Vous ne pouvez pas ~r~rétrograder~w~ d\'avantage.')
			end
		else
			TriggerClientEvent('esx:showNotification', _src, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', _src, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end)


---- Edit Mode


RegisterServerEvent('rGangBuilder:editGang')
AddEventHandler('rGangBuilder:editGang', function(item, valeur, where)
	local _src = source
	local sourceXPlayer = ESX.GetPlayerFromId(source)

	if item == "Posgarage" then
		MySQL.Async.execute('UPDATE `gangbuilder` SET `posveh` = @posveh  WHERE name = @name', {
            ['@name'] = where,
            ['@posveh'] = json.encode(valeur)
        }, function(rowsChange)
        end)
		TriggerClientEvent('esx:showNotification', _src, 'Position du garage modifier')
	end

	if item == "Posspawn" then
		MySQL.Async.execute('UPDATE `gangbuilder` SET `posspawncar` = @posspawncar  WHERE name = @name', {
            ['@name'] = where,
            ['@posspawncar'] = json.encode(valeur)
        }, function(rowsChange)
        end)
		TriggerClientEvent('esx:showNotification', _src, 'Position spawn véhicule modifier')
	end

	if item == "PosBoss" then
		MySQL.Async.execute('UPDATE `gangbuilder` SET `posboss` = @posboss  WHERE name = @name', {
            ['@name'] = where,
            ['@posboss'] = json.encode(valeur)
        }, function(rowsChange)
        end)
		TriggerClientEvent('esx:showNotification', _src, 'Position du menu boss modifier')
	end

	if item == "PosCoffre" then
		MySQL.Async.execute('UPDATE `gangbuilder` SET `poscoffre` = @poscoffre  WHERE name = @name', {
            ['@name'] = where,
            ['@poscoffre'] = json.encode(valeur)
        }, function(rowsChange)
        end)
		TriggerClientEvent('esx:showNotification', _src, 'Position du coffre modifier')
	end
end)


ESX.RegisterServerCallback('rGangBuilder:getPlayerInventoryBlack', function(source, cb)
	local _source = source
	local xPlayer    = ESX.GetPlayerFromId(_source)
	local blackMoney = xPlayer.getAccount('black_money').money
  
	cb({
	  blackMoney = blackMoney
	})
end)

RegisterServerEvent('rGangBuilder:putblackmoney')
AddEventHandler('rGangBuilder:putblackmoney', function(type, item, count, gang)

  local _source      = source
  local xPlayer      = ESX.GetPlayerFromId(_source)

  if type == 'item_account' then
    local playerAccountMoney = xPlayer.getAccount(item).money

    if playerAccountMoney >= count then

      xPlayer.removeAccountMoney(item, count)
      TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..gang..'_black', function(account)
        account.addMoney(count)
      end)
    else
      TriggerClientEvent('esx:showNotification', _source, 'Montant invalide')
    end
  end
end)


ESX.RegisterServerCallback('rGangBuilder:getBlackMoneySociety', function(source, cb, gang)
    local _source = source
    local xPlayer    = ESX.GetPlayerFromId(_source)
    local blackMoney = 0
  
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..gang..'_black', function(account)
      blackMoney = account.money
    end)
  
    cb({
      blackMoney = blackMoney
    })
end)

RegisterServerEvent('rGangBuilder:getItem')
  AddEventHandler('rGangBuilder:getItem', function(type, item, count, gang)
  
    local _source      = source
    local xPlayer      = ESX.GetPlayerFromId(_source)
  
    if type == 'item_account' then
  
      TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..gang..'_black', function(account)
  
        local roomAccountMoney = account.money
  
        if roomAccountMoney >= count then
          account.removeMoney(count)
          xPlayer.addAccountMoney(item, count)
        else
          TriggerClientEvent('esx:showNotification', _source, 'Montant invalide')
        end
  
      end)
    end
end)



ESX.RegisterServerCallback('rGangBuilder:getArmoryWeapons', function(source, cb, soc)
    TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
        local weapons = store.get('weapons')

        if weapons == nil then
            weapons = {}
        end

        cb(weapons)
    end)
end)

ESX.RegisterServerCallback('rGangBuilder:removeArmoryWeapon', function(source, cb, weaponName, soc)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addWeapon(weaponName, 500)

    TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
        local weapons = store.get('weapons') or {}

        local foundWeapon = false

        for i=1, #weapons, 1 do
            if weapons[i].name == weaponName then
                weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
                foundWeapon = true
                break
            end
        end

        if not foundWeapon then
            table.insert(weapons, {
                name = weaponName,
                count = 0
            })
        end

        store.set('weapons', weapons)
        cb()
    end)
end)

ESX.RegisterServerCallback('rGangBuilder:addArmoryWeapon', function(source, cb, weaponName, removeWeapon, soc)
    local xPlayer = ESX.GetPlayerFromId(source)

    if removeWeapon then
        xPlayer.removeWeapon(weaponName)
    end

    TriggerEvent('esx_datastore:getSharedDataStore', 'society_'..soc, function(store)
        local weapons = store.get('weapons') or {}
        local foundWeapon = false

        for i=1, #weapons, 1 do
            if weapons[i].name == weaponName then
                weapons[i].count = weapons[i].count + 1
                foundWeapon = true
                break
            end
        end

        if not foundWeapon then
            table.insert(weapons, {
                name  = weaponName,
                count = 1
            })
        end

        store.set('weapons', weapons)
        cb()
    end)
end)