local hasAlreadyEnteredMarker, currentActionData = false, {}
local lastZone, currentAction, currentActionMsg, vehiclePart
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function OpenVehicleLocationMenu(object)
    local elements = {}

    for k,v in ipairs(Config.Locations) do
        for i=1, #v.Models, 1 do
            table.insert(elements, {
                label = ('%s - <span style="color:green;">%s</span>'):format(v.Models[i].label, _U('vehicle_item', ESX.Math.GroupDigits(v.Models[i].price))),
                name = v.Models[i].label,
                model = v.Models[i].model,
                price = v.Models[i].price
            })
        end
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
        title = _U('title_location_menu'),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_confirm', {
            title = _U('vehicle_menu_confirm', data.current.name, data.current.price),
            align = 'top-left',
            elements = {{label = _U('no'), value = 'no'},{label = _U('yes'), value = 'yes'}}
        }, function(subData, subMenu)
            if subData.current.value == 'yes' then
                local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(object)

                ESX.TriggerServerCallback('esx:vehicle_location:buy', function(bought)
                    if bought then
                        if spawnPoint then
                            ESX.Game.SpawnVehicle(data.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
                                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                ESX.ShowNotification(_U('buy_succes'))
                            end)
                        end
                    else
                        ESX.ShowNotification(_U('buy_error'))
                        subMenu.close()
                    end
                end, data.current.price)
            else
                subMenu.close()
            end
        end, function(subData, subMenu)
            subMenu.close()
        end)
    end, function(data, menu)
        menu.close()

        currentAction = 'location_menu'
        currentActionMsg = _U('open_location_menu')
        currentActionData = {}
    end)
end

function GetAvailableVehicleSpawnPoint(object)
    local found, foundSpawnPoint = false, nil

    for i=1, #object.SpawnPoints, 1 do
        if ESX.Game.IsSpawnPointClear(object.SpawnPoints[i].coords, object.SpawnPoints[i].radius) then
           found, foundSpawnPoint = true, object.SpawnPoints[i]
           break
        end
    end

    if found then
        return true, foundSpawnPoint
    else
        ESX.ShowNotification(_U('vehicle_blocked'))
        return false
    end
end

AddEventHandler('esx:vehicle_location:hasEnteredMarker', function(zone)
    currentAction = 'location_menu'
    currentActionMsg = _U('open_location_menu')
    currentActionData = {}
end)

AddEventHandler('esx:vehicle_location:hasExitedMarker', function(zone)
    ESX.UI.Menu.CloseAll()
    currentAction = nil
end)

-- Create blip
Citizen.CreateThread(function()
    for i=1, #Config.Locations do
        local blip = AddBlipForCoord(Config.Locations[i].Spawner)

        SetBlipSprite(blip, Config.Blip.Sprite)
        SetBlipDisplay(blip, Config.Blip.Display)
        SetBlipScale(blip, Config.Blip.Scale)
        SetBlipColour(blip, Config.Blip.Color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U('map_blip'))
        EndTextCommandSetBlipName(blip)
    end
end)

-- Enter / Exit marker events & draw markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), nil, nil, true

        for k,v in pairs(Config.Locations) do
            local distance = #(playerCoords - v.Spawner)

            if distance < Config.DrawDistance then
                DrawMarker(Config.MarkerType, v.Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, MarkerSize.x, MarkerSize.y, MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, nil, nil, false)
                letSleep = false

                if distance < Config.MarkerSize.x + 0.5 then
                    isInMarker, currentZone, vehiclePart = true, k, v
                end
            end
        end

        if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
            hasAlreadyEnteredMarker, lastZone = true, currentZone
            TriggerEvent('esx:vehicle_location:hasEnteredMarker', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('esx:vehicle_location:hasExitedMarker', lastZone)
        end

        if letSleep then
            Citizen.Wait(500)
        end
    end
end)

-- Key controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if currentAction then
            ESX.ShowHelpNotification(currentActionMsg)

            if IsControlJustReleased(0, 38) then
                if currentAction == 'location_menu' then
                    OpenVehicleLocationMenu(vehiclePart)
                end

                currentAction = nil
            end
        else
            Citizen.Wait(500)
        end
    end
end)
