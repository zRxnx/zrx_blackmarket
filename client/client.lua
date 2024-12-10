CORE = exports.zrx_utility:GetUtility()
COOLDOWN, LOC_DATA, PED_DATA, BLIP_DATA, BOX_DATA = false, {}, {}, {}, {}

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

if not Config.UseOxTarget then
	RegisterKeyMapping('openNearbyBlackmarket', Strings.command_desc, 'keyboard', 'e')
	RegisterCommand('openNearbyBlackmarket', function()
		local pedCoords = GetEntityCoords(cache.ped)

		for i, data in ipairs(Config.Locations) do
			print(#(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z)))
			if #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z)) <= Config.InteractDistance then
				StartCooldown()
				OpenShopMenu(i)
				PreventPunish(i)

				break
			end
		end
	end)
end

RegisterNetEvent('zrx_blackmarket:server:randomLocation', function(index, coords)
	LOC_DATA[index] = vector4(coords.x, coords.y, coords.z, coords.w)

	if DoesEntityExist(PED_DATA[index]) then
		SetPedAsNoLongerNeeded(PED_DATA[index])
		SetEntityAsMissionEntity(PED_DATA[index], true, true)
		DeleteEntity(PED_DATA[index])
	end

	if Config.UseOxTarget then
		exports.ox_target:removeZone(BOX_DATA[index])

		BOX_DATA[index] = exports.ox_target:addBoxZone({
			coords = vector3(LOC_DATA[index].x, LOC_DATA[index].y, LOC_DATA[index].z),
			size = vector3(1, 1, 4),
			options = {
				{
					icon = 'fa-solid fa-briefcase',
					iconColor = Config.IconColor,
					label = Strings.title,
					distance = 1.0,
					onSelect = function()
						if COOLDOWN then
							return CORE.Bridge.notification(Strings.on_cooldown)
						end

						StartCooldown()
						OpenShopMenu(index)
						PreventPunish(index)
					end
				}
			}
		})
	end
end)

RegisterNetEvent('zrx_blackmarket:client:startBlackmarket', function(coords)
	LOC_DATA = coords

	StartThread()
end)

StartThread = function()

	for index, data in ipairs(Config.Locations) do
		if Config.UseOxTarget then
			BOX_DATA[i] = exports.ox_target:addBoxZone({
				coords = vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z),
				size = vector3(1, 1, 4),
				options = {
					{
						icon = 'fa-solid fa-briefcase',
						iconColor = Config.IconColor,
						label = Strings.title,
						distance = 1.0,
						onSelect = function()
							if COOLDOWN then
								return CORE.Bridge.notification(Strings.on_cooldown)
							end

							StartCooldown()
							OpenShopMenu(index)
							PreventPunish(index)
						end
					}
				}
			})
		end
	end

	local pedCoords, curPos, dist, entity
	local isOpen, text, temp

	while true do
		pedCoords = GetEntityCoords(cache.ped)

		for i, data in ipairs(Config.Locations) do
			curPos = LOC_DATA[i]
			dist = #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z))

			if dist <= Config.DrawDistance and not DoesEntityExist(PED_DATA[i]) then
                lib.requestAnimDict(data.animation.dict)
                lib.requestModel(data.ped)

				entity = CreatePed(28, data.ped, curPos.x, curPos.y, curPos.z, curPos.w, false, false)

				FreezeEntityPosition(entity, true)
				SetEntityInvincible(entity, true)
				SetBlockingOfNonTemporaryEvents(entity, true)
				TaskPlayAnim(entity, data.animation.dict, data.animation.name, 8.0, 0.0, -1, 1, 0, false, false, false)

				PED_DATA[i] = entity
			elseif dist > Config.DrawDistance and DoesEntityExist(PED_DATA[i]) then
				SetPedAsNoLongerNeeded(entity)
                SetEntityAsMissionEntity(entity, true, true)
				DeleteEntity(entity)
				RemoveAnimDict(data.animation.dict)

				PED_DATA[i] = nil
			end

			isOpen, text = lib.isTextUIOpen()

			if data.marker.enabled and #(pedCoords - vector3(curPos.x, curPos.y, curPos.z)) <= Config.ShowDistance then
				DrawMarker(data.marker.type, curPos.x, curPos.y, curPos.z, nil, nil, nil, nil, nil, nil, data.marker.size.x, data.marker.size.y, data.marker.size.z, data.marker.color.r, data.marker.color.g, data.marker.color.b, data.marker.color.a, true, true, 2, true, nil, nil, nil)
			end

			if #(pedCoords - vector3(curPos.x, curPos.y, curPos.z)) <= Config.InteractDistance and not (isOpen and text == Strings.open_menu:format(data.name)) then
				lib.showTextUI(Strings.open_menu:format(data.name), {
					icon = 'hand',
				})
			elseif #(pedCoords - vector3(curPos.x, curPos.y, curPos.z)) > Config.InteractDistance then
				if isOpen and text == Strings.open_menu:format(data.name) then
					lib.hideTextUI()
				end
			end
		end

		Wait(0)
	end
end

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