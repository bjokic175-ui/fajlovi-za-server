-- GANG SISTEM - SERVER STRANA - ESX LEGACY

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- KONFIGURACIJA
local Config = {}

Config.Gangs = {
    {name = "GSF", color = {r = 255, g = 0, b = 0}},
    {name = "Ballas", color = {r = 0, g = 0, b = 255}},
    {name = "Bloods", color = {r = 139, g = 0, b = 0}},
    {name = "Vagos", color = {r = 255, g = 255, b = 0}},
    {name = "Marabunta", color = {r = 0, g = 255, b = 0}}
}

Config.RobberySettings = {
    minMembers = 5,
    maxMembers = 10,
    reward = 500000,
    duration = 300000 -- 5 minuta
}

local activeRobberies = {}

-- DOBIJ GANG IGRAČA
RegisterServerEvent('gangs:getPlayerGang')
AddEventHandler('gangs:getPlayerGang', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer then
        local identifier = xPlayer.identifier
        
        MySQL.Async.fetchAll('SELECT gang FROM gang_members WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(result)
            if result and result[1] then
                local gang = result[1].gang
                
                -- Dobij boju gangu
                local gangData = GetGangData(gang)
                if gangData then
                    TriggerClientEvent('gangs:setPlayerGang', _source, gang, gangData.color)
                end
            else
                TriggerClientEvent('gangs:setPlayerGang', _source, nil, nil)
            end
        end)
    end
end)

-- DOBIJ PODATKE O GANGU
function GetGangData(gangName)
    for _, gang in ipairs(Config.Gangs) do
        if gang.name == gangName then
            return gang
        end
    end
    return nil
end

-- SPAWN VOZILA
RegisterServerEvent('gangs:spawnVehicle')
AddEventHandler('gangs:spawnVehicle', function(gang, vehicleIndex)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then return end
    
    -- Provjeri je li igrač član bande
    MySQL.Async.fetchAll('SELECT gang FROM gang_members WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result and result[1] and result[1].gang == gang then
            local gangData = GetGangData(gang)
            
            -- Vozila po bandi
            local vehicles = {
                "sabrturbo", "sabrturbo",
                "dominator", "dominator",
                "buccaneur", "buccaneur",
                "phoenix", "phoenix",
                "tornado", "tornado"
            }
            
            if gangData and vehicleIndex >= 1 and vehicleIndex <= #vehicles then
                local vehicleModel = vehicles[vehicleIndex]
                
                TriggerClientEvent('gangs:spawnVehicleClient', _source, gang, vehicleModel, 
                    {x = 100.0, y = -950.0, z = 29.0, heading = 180.0}, gangData.color)
                
                -- Unesi u bazu
                MySQL.Async.execute('INSERT INTO gang_vehicles (gang, vehicle_model, spawned_by) VALUES (@gang, @model, @spawned_by)', {
                    ['@gang'] = gang,
                    ['@model'] = vehicleModel,
                    ['@spawned_by'] = xPlayer.identifier
                })
            else
                TriggerClientEvent('chat:addMessage', _source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"GREŠKA", "Nevaljano vozilo!"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', _source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"GREŠKA", "Niste član bande " .. gang .. "!"}
            })
        end
    end)
end)

-- POČNI PLJAČKU BANKE
RegisterServerEvent('gangs:startRobbery')
AddEventHandler('gangs:startRobbery', function(gang)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then return end
    
    -- Provjeri je li igrač član bande
    MySQL.Async.fetchAll('SELECT gang FROM gang_members WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result and result[1] and result[1].gang == gang then
            -- Provjeri broj članova bande na serveru
            local gangMembers = GetGangMembersOnline(gang)
            
            if #gangMembers < Config.RobberySettings.minMembers then
                TriggerClientEvent('chat:addMessage', _source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"GREŠKA", "Potrebno je najmanje " .. Config.RobberySettings.minMembers .. " članova!"}
                })
                return
            end
            
            if #gangMembers > Config.RobberySettings.maxMembers then
                TriggerClientEvent('chat:addMessage', _source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"GREŠKA", "Maksimalno " .. Config.RobberySettings.maxMembers .. " članova!"}
                })
                return
            end
            
            -- Provjeri da nije pljačka već u toku
            if activeRobberies[gang] then
                TriggerClientEvent('chat:addMessage', _source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"GREŠKA", "Pljačka " .. gang .. " je već u toku!"}
                })
                return
            end
            
            -- Označi pljačku kao aktivnu
            activeRobberies[gang] = true
            
            -- Počni pljačku - obavijesti sve članove
            for _, member in ipairs(gangMembers) do
                TriggerClientEvent('gangs:robberyInProgress', member, gang, Config.RobberySettings.duration)
            end
            
            -- Nakon trajanja - daj nagradu
            SetTimeout(Config.RobberySettings.duration, function()
                for _, member in ipairs(gangMembers) do
                    local player = ESX.GetPlayerFromId(member)
                    if player then
                        player.addMoney(Config.RobberySettings.reward)
                        TriggerClientEvent('chat:addMessage', member, {
                            color = {0, 255, 0},
                            multiline = true,
                            args = {"💰 PLJAČKA", "Dobio si $" .. Config.RobberySettings.reward}
                        })
                    end
                end
                
                -- Označi pljačku kao neaktivnu
                activeRobberies[gang] = false
            end)
        else
            TriggerClientEvent('chat:addMessage', _source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"GREŠKA", "Niste član bande " .. gang .. "!"}
            })
        end
    end)
end)

-- DOBIJ ČLANOVE BANDE KOJI SU ONLINE
function GetGangMembersOnline(gang)
    local members = {}
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            TriggerEvent('esx:getPlayerFromId', playerId, function(player)
                if player then
                    MySQL.Async.fetchAll('SELECT gang FROM gang_members WHERE identifier = @identifier', {
                        ['@identifier'] = player.identifier
                    }, function(result)
                        if result and result[1] and result[1].gang == gang then
                            table.insert(members, playerId)
                        end
                    end)
                end
            end)
        end
    end
    
    -- Čekaj da se učitaju svi članovi
    local startTime = os.time()
    while #members == 0 and os.time() - startTime < 2 do
        Citizen.Wait(100)
    end
    
    return members
end

-- ADMIN KOMANDA - DODAJ U BANGU
RegisterCommand('addgang', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin') then
        local targetId = tonumber(args[1])
        local gangName = args[2]
        
        if targetId and gangName then
            local target = ESX.GetPlayerFromId(targetId)
            if target then
                MySQL.Async.execute('INSERT INTO gang_members (identifier, gang, rank) VALUES (@identifier, @gang, @rank) ON DUPLICATE KEY UPDATE gang = @gang', {
                    ['@identifier'] = target.identifier,
                    ['@gang'] = gangName,
                    ['@rank'] = 'member'
                }, function()
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"✅ ADMIN", target.getName() .. " je dodan u " .. gangName}
                    })
                    TriggerClientEvent('chat:addMessage', targetId, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"🏴‍☠️ GANG", "Dodan si u " .. gangName}
                    })
                    TriggerServerEvent('gangs:getPlayerGang')
                end)
            end
        end
    end
end)

-- ADMIN KOMANDA - UKLONJI IZ BANDE
RegisterCommand('removegang', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin') then
        local targetId = tonumber(args[1])
        
        if targetId then
            local target = ESX.GetPlayerFromId(targetId)
            if target then
                MySQL.Async.execute('DELETE FROM gang_members WHERE identifier = @identifier', {
                    ['@identifier'] = target.identifier
                }, function()
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {0, 255, 0},
                        multiline = true,
                        args = {"✅ ADMIN", target.getName() .. " je uklonjen iz bande"}
                    })
                    TriggerServerEvent('gangs:getPlayerGang')
                end)
            end
        end
    end
end)