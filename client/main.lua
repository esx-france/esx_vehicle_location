local hasAlreadyEnteredMarker, currentActionData = false, {}
local lastZone, currentAction, currentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenVehicleLocationMenu()
    local elements = {}

    for k,vehicle in ipairs(Config.Location) do
        table.insert(elements, {
            label = ('%s - <span style="color:green;">%s</span>'):format(vehicle.label, _U('vehicle_item', ESX.Math.GroupDigits(vehicle.price))),
            name = vehicle.label,
            model = vehicle.model,
            price = vehicle.price
        })
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
            elements = {
                {label = _U('no'), value = 'no'},
                {label = _U('yes'), value = 'yes'}
            }
        }, function(subData, subMenu)
            if subData.current.value == 'yes' then
                local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint()

                ESX.TriggerServerCallback('esx_vehicle_location:buy', function(bought)
                    if bought then
                        if spawnPoint then
                            ESX.Game.SpawnVehicle(data.current.model, spawnPoint.coords, spawnPoint.heading, function(vehicle)
                                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            end)
            
                            ESX.ShowNotification(_U('buy_succes'))
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

        currentAction     = 'location_menu'
        currentActionMsg  = _U('open_location_menu')
        currentActionData = {}
    end)
end

function GetAvailableVehicleSpawnPoint()
    local spawnPoints = Config.Vehicles.SpawnPoints
    local found, foundSpawnPoint = false, nil
    
    for i=1, #spawnPoints, 1 do
        if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
            found, foundSpawnPoint = true, spawnPoints[i]
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

AddEventHandler('esx_vehicle_location:hasEnteredMarker', function(zone)
    currentAction     = 'location_menu'
    currentActionMsg  = _U('open_location_menu')
    currentActionData = {}
end)

AddEventHandler('esx_vehicle_location:hasExitedMarker', function(zone)
    ESX.UI.Menu.CloseAll()
    currentAction = nil
end)

-- Enter / Exit marker events & draw markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

        for k,v in pairs(Config.Vehicles.Spawner) do
            local distance = #(playerCoords - v)

            if distance < Config.DrawDistance then
                letSleep = false
                DrawMarker(Config.MarkerType, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
                
                if distance < Config.MarkerSize.x then
                    isInMarker, currentZone = true, k
                end
            end
        end

        if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
	    hasAlreadyEnteredMarker, lastZone = true, currentZone
	    TriggerEvent('esx_vehicle_location:hasEnteredMarker', currentZone)
	end

        if not isInMarker and hasAlreadyEnteredMarker then
	    hasAlreadyEnteredMarker = false
	    TriggerEvent('esx_vehicle_location:hasExitedMarker', lastZone)
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
                    OpenVehicleLocationMenu()
                end

                currentAction = nil
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- Create blip
Citizen.CreateThread(function()
    for k,v in pairs(Config.Blip) do
        local blip = AddBlipForCoord(v.Coords)

        SetBlipSprite (blip, v.Sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, v.Scale)
        SetBlipColour (blip, v.Color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(_U('map_blip'))
        EndTextCommandSetBlipName(blip)
    end
end)
