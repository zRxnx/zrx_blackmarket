ESX, COOLDOWN, LOC_DATA, PED_DATA, BLIP_DATA = Config.EsxImport(), false, {}, {}, {}
local GetCurrentResourceName = GetCurrentResourceName
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local DoesEntityExist = DoesEntityExist
local SetPedAsNoLongerNeeded = SetPedAsNoLongerNeeded
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteEntity = DeleteEntity
local CreateThread = CreateThread
local vector3 = vector3
local GetEntityCoords = GetEntityCoords
local CreatePed = CreatePed
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityInvincible = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local TaskPlayAnim = TaskPlayAnim
local RemoveAnimDict = RemoveAnimDict
local Wait = Wait
local SetBlipRoute = SetBlipRoute
local RemoveBlip = RemoveBlip

RegisterNetEvent('esx:playerLoaded',function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('onResourceStop', function(res)
	if GetCurrentResourceName() ~= res then return end

	for i, data in pairs(PED_DATA) do
		if DoesEntityExist(data) then
			SetPedAsNoLongerNeeded(data)
            SetEntityAsMissionEntity(data, true, true)
			DeleteEntity(data)
		end
	end
end)

CreateThread(function()
	LOC_DATA = lib.callback.await('zrx_blackmarket:server:getLocations', 100)

	for i, data in pairs(Config.Locations) do
		exports.ox_target:addBoxZone({
			coords = vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z),
			size = vector3(1, 1, 4),
			options = {
				{
					name = 'box',
					icon = 'fa-solid fa-briefcase',
					label = Strings.title,
					distance = 1.0,
                    args = {
                        content = data.content,
                        name = data.name
                    },
                    onSelect = function(args)
                        if COOLDOWN then
                            return Config.Notification(nil, Strings.on_cooldown)
                        end

                        StartCooldown()
                        OpenShopMenu(args)
                    end
				}
			}
		})
	end

	local pedCoords, curPos, dist, entity

	while true do
		pedCoords = GetEntityCoords(cache.ped)

		for i, data in pairs(Config.Locations) do
			curPos = LOC_DATA[i]
			dist = #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z))

			if dist <= Config.DrawDistance and not DoesEntityExist(PED_DATA[i]) then
                lib.requestAnimDict(data.animation.dict, 100)
                lib.requestModel(data.ped, 100)

				entity = CreatePed(28, data.ped, curPos.x, curPos.y, curPos.z, curPos[4], false, false)

				FreezeEntityPosition(entity, true)
				SetEntityInvincible(entity, true)
				SetBlockingOfNonTemporaryEvents(entity, true)
				TaskPlayAnim(entity, data.animation.dict, data.animation.name, 8.0, 0.0, -1, 1, 0, 0, 0, 0)

				PED_DATA[i] = entity
			elseif dist > Config.DrawDistance and DoesEntityExist(PED_DATA[i]) then
				SetPedAsNoLongerNeeded(PED_DATA[i])
                SetEntityAsMissionEntity(PED_DATA[i], true, true)
				DeleteEntity(PED_DATA[i])
				RemoveAnimDict(data.animation.dict)

				PED_DATA[i] = nil
			end
		end

		Wait(2000)
	end
end)

RegisterNetEvent('zrx_blackmarket:client:startBlip', function(coords)
	BLIP_DATA[#BLIP_DATA + 1] = {
		blip = Config.Alert.blip(vector3(coords.x, coords.y, coords.z)),
		time = Config.Alert.time
	}
end)

CreateThread(function()
	while true do
		for i, data in pairs(BLIP_DATA) do
			if data.time <= 1 then
				SetBlipRoute(data.blip, false)
				RemoveBlip(data.blip)

				BLIP_DATA[i] = nil
			else
				BLIP_DATA[i].time -= 1
			end
		end

		Wait(1000)
	end
end)

exports('hasCooldown', function()
    return COOLDOWN
end)