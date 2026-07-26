-- GANG SISTEM - CLIENT STRANA - ESX LEGACY

local playerGang = nil
local playerGangColor = nil
local gangBlips = {}
local spawnedVehicles = {}
local robberyInProgress = false

-- KONFIGURACIJA
local Config = {}

Config.Gangs = {
    {
        name = "GSF",
        color = {r = 255, g = 0, b = 0},
        vehicles = {
            "sabrturbo", "sabrturbo",
            "dominator", "dominator",
            "buccaneur", "buccaneur",
            "phoenix", "phoenix",
            "tornado", "tornado"
        },
        bankLocation = {x = 150.0, y = -1000.0, z = 30.0, heading = 0.0},
        spawnLocation = {x = 100.0, y = -950.0, z = 29.0, heading = 180.0}
    },
    {
        name = "Ballas",
        color = {r = 0, g = 0, b = 255},
        vehicles = {
            "buccaneur", "buccaneur",
            "phoenix", "phoenix",
            "dominator", "dominator",
            "sabrturbo", "sabrturbo",
            "tornado", "tornado"
        },
        bankLocation = {x = 200.0, y = -1000.0, z = 30.0, heading = 0.0},
        spawnLocation = {x = 150.0, y = -950.0, z = 29.0, heading = 180.0}
    },
    {
        name = "Bloods",
        color = {r = 139, g = 0, b = 0},
        vehicles = {
            "tornado", "tornado",
            "sabrturbo", "sabrturbo",
            "dominator", "dominator",
            "buccaneur", "buccaneur",
            "phoenix", "phoenix"
        },
        bankLocation = {x = 250.0, y = -1000.0, z = 30.0, heading = 0.0},
        spawnLocation = {x = 200.0, y = -950.0, z = 29.0, heading = 180.0}
    },
    {
        name = "Vagos",
        color = {r = 255, g = 255, b = 0},
        vehicles = {
            "dominator", "dominator",
            "buccaneur", "buccaneur",
            "phoenix", "phoenix",
            "tornado", "tornado",
            "sabrturbo", "sabrturbo"
        },
        bankLocation = {x = 300.0, y = -1000.0, z = 30.0, heading = 0.0},
        spawnLocation = {x = 250.0, y = -950.0, z = 29.0, heading = 180.0}
    },
    {
        name = "Marabunta",
        color = {r = 0, g = 255, b = 0},
        vehicles = {
            "phoenix", "phoenix",
            "tornado", "tornado",
            "sabrturbo", "sabrturbo",
            "dominator", "dominator",
            "buccaneur", "buccaneur"
        },
        bankLocation = {x = 350.0, y = -1000.0, z = 30.0, heading = 0.0},
        spawnLocation = {x = 300.0, y = -950.0, z = 29.0, heading = 180.0}
    }
}

Config.RobberySettings = {
    minMembers = 5,
    maxMembers = 10,
    reward = 500000,
    duration = 300000 -- 5 minuta
}

-- ESX INICIJALIZACIJA
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    -- Učitaj igrača gang
    TriggerServerEvent('gangs:getPlayerGang')
    Citizen.Wait(1000)
    
    -- Kreiraj blipe
    CreateGangBlips()
end)

-- KREIRAJ BLIP ZA SVAKU BANKU
function CreateGangBlips()
    if not playerGang then return end
    
    for _, gang in ipairs(Config.Gangs) do
        if gang.name == playerGang then
            local blip = AddBlipForCoord(gang.bankLocation.x, gang.bankLocation.y, gang.bankLocation.z)
            SetBlipSprite(blip, 277) -- Kosturska glava
            SetBlipColour(blip, GetGangBlipColor(gang.color))
            SetBlipAsShortRange(blip, false)
            SetBlipRoute(blip, true)
            AddTextComponentString(gang.name .. " - Pljačka Banke")
            BeginTextCommandDisplayHelp(0)
            AddTextComponentString("Pritisni [E] za pljačku")
            EndTextCommandDisplayHelp(0, false, true, -1)
            
            table.insert(gangBlips, blip)
        end
    end
end

-- DOBIJ BLIP BOJU IZ RGB
function GetGangBlipColor(color)
    if color.r == 255 and color.g == 0 and color.b == 0 then
        return 1 -- Crvena
    elseif color.r == 0 and color.g == 0 and color.b == 255 then
        return 3 -- Plava
    elseif color.r == 139 and color.g == 0 and color.b == 0 then
        return 1 -- Tamno crvena
    elseif color.r == 255 and color.g == 255 and color.b == 0 then
        return 5 -- Žuta
    elseif color.r == 0 and color.g == 255 and color.b == 0 then
        return 2 -- Zelena
    end
    return 0
end

-- PRIMENI GANG BLIPE SAMO AKO JE IGRAČ U GANGU
RegisterNetEvent('gangs:setPlayerGang')
AddEventHandler('gangs:setPlayerGang', function(gang, color)
    playerGang = gang
    playerGangColor = color
    
    if playerGang then
        TriggerEvent('chat:addMessage', {
            color = {color.r, color.g, color.b},
            multiline = true,
            args = {"GANG", "Učitan gang: " .. playerGang}
        })
        CreateGangBlips()
    end
end)

-- KOMANDA /car - SPAWN VOZILA
RegisterCommand('car', function(source, args, rawCommand)
    if not playerGang then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"GREŠKA", "Niste član bande!"}
        })
        return
    end
    
    local vehicleIndex = tonumber(args[1]) or 1
    
    if vehicleIndex < 1 or vehicleIndex > 10 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"GREŠKA", "Vozilo mora biti od 1-10!"}
        })
        return
    end
    
    TriggerServerEvent('gangs:spawnVehicle', playerGang, vehicleIndex)
end)

-- SPAWN VOZILA - CLIENT SIDE
RegisterNetEvent('gangs:spawnVehicleClient')
AddEventHandler('gangs:spawnVehicleClient', function(gang, vehicleModel, spawnLocation, color)
    local playerPed = PlayerPedId()
    
    RequestModel(GetHashKey(vehicleModel))
    while not HasModelLoaded(GetHashKey(vehicleModel)) do
        Wait(100)
    end
    
    local vehicle = CreateVehicle(GetHashKey(vehicleModel), spawnLocation.x, spawnLocation.y, spawnLocation.z, spawnLocation.heading, true, false)
    SetVehicleOnGroundProperly(vehicle)
    
    -- Boja vozila
    SetVehicleCustomPrimaryColour(vehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(vehicle, color.r, color.g, color.b)
    
    -- Plošica
    local plate = gang:sub(1, 3) .. math.random(100, 999)
    SetVehicleNumberPlateText(vehicle, plate)
    
    -- Ključ vozila
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    
    table.insert(spawnedVehicles, vehicle)
    
    TriggerEvent('chat:addMessage', {
        color = {color.r, color.g, color.b},
        multiline = true,
        args = {"VOZILO", "Vozilo " .. vehicleModel .. " je spawnano!"}
    })
end)

-- PLJAČKA BANKE - TRIGGER
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if playerGang then
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for _, gang in ipairs(Config.Gangs) do
                if gang.name == playerGang then
                    local distance = #(playerCoords - vector3(gang.bankLocation.x, gang.bankLocation.y, gang.bankLocation.z))
                    
                    if distance < 2.0 then
                        DrawText3D(gang.bankLocation.x, gang.bankLocation.y, gang.bankLocation.z + 1.0, "~g~[E]~s~ Pljačka banke")
                        
                        if IsControlJustReleased(0, 38) then -- E tipka
                            if not robberyInProgress then
                                TriggerServerEvent('gangs:startRobbery', gang.name)
                            else
                                TriggerEvent('chat:addMessage', {
                                    color = {255, 0, 0},
                                    multiline = true,
                                    args = {"GREŠKA", "Pljačka je već u toku!"}
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- DRAW 3D TEXT
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local factor = (string.len(text)) / 370
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProminence(2)
        BeginTextCommandDisplayText("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

-- PLJAČKA U TOKU
RegisterNetEvent('gangs:robberyInProgress')
AddEventHandler('gangs:robberyInProgress', function(gang, duration)
    robberyInProgress = true
    
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"🏦 PLJAČKA", "Pljačka " .. gang .. " banke je počela! Pazite na policiju!"}
    })
    
    local endTime = GetGameTimer() + duration
    local timerShown = false
    
    Citizen.CreateThread(function()
        while GetGameTimer() < endTime do
            Citizen.Wait(1000)
            local remaining = math.ceil((endTime - GetGameTimer()) / 1000)
            
            if remaining > 0 and remaining % 30 == 0 then
                TriggerEvent('chat:addMessage', {
                    color = {255, 100, 0},
                    multiline = true,
                    args = {"⏱️ TIMER", remaining .. " sekundi do kraja..."}
                })
            end
        end
        
        robberyInProgress = false
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"✅ PLJAČKA", "Pljačka završena! Novac je dodan u tvoj račun!"}
        })
    end)
end)

-- MINI MAPA LOGO - SAMO ZA ČLANOVE
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if playerGang and playerGangColor then
            -- Prikaži gang info na HUD-u
            TriggerEvent('chat:addMessage', {
                color = {playerGangColor.r, playerGangColor.g, playerGangColor.b},
                multiline = true,
                args = {"👤 GANG INFO", "Član ste gangu: " .. playerGang}
            })
        end
    end
end)