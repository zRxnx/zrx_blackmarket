ESX, PLAYER_CACHE, FETCHED, COOLDOWN, LOC_DATA = Config.EsxImport(), {}, {}, {}, {}
local GetPlayers = GetPlayers
local RegisterNetEvent = RegisterNetEvent
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local vector3 = vector3
local CreateThread = CreateThread
local SetTimeout = SetTimeout

RegisterNetEvent('esx:playerLoaded', function(player)
    PLAYER_CACHE[player] = GetPlayerData(player)
end)

CreateThread(function()
    for i, data in pairs(GetPlayers()) do
        data = tonumber(data)
        PLAYER_CACHE[data] = GetPlayerData(data)
    end

    math.randomseed(os.time())
    for i, data in pairs(Config.Locations) do
        LOC_DATA[i] = data.coords[math.random(1, #data.coords)]
    end
end)

lib.callback.register('zrx_blackmarket:server:getLocations', function(source)
    if not FETCHED[source] then
        FETCHED[source] = true
	    return LOC_DATA
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_blackmarket:server:getLocations"')
    end
end)

RegisterNetEvent('zrx_blackmarket:server:processAction', function(action, item, amount, price)
    price = price * amount
    local xPlayer = ESX.GetPlayerFromId(source)
    local ped = GetPlayerPed(xPlayer.source)
	local pedCoords = GetEntityCoords(ped)
    local isAllowed = false

    if Player.HasCooldown(xPlayer.source) then
        return Config.Notification(xPlayer.source, Strings.on_cooldown)
    end

    for i, data in pairs(Config.Locations) do
		if #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(LOC_DATA[i].x, LOC_DATA[i].y, LOC_DATA[i].z)) < 2 then
			isAllowed = true
            break
		end
	end

	if not isAllowed then
		return Config.PunishPlayer(xPlayer.source, 'Tried to trigger "zrx_blackmarket:server:processAction"')
	end

    if action == 'buy' then
        local xMoney = xPlayer.getAccount(Config.Account).money

        if xMoney >= price then
            if xPlayer.canCarryItem(item, amount) then
                xPlayer.removeAccountMoney(Config.Account, price)
                xPlayer.addInventoryItem(item, amount)
                Config.Notification(xPlayer.source, (Strings.bought):format(amount, item, ESX.Math.GroupDigits(price)))

                if Webhook.Settings.bought then
                    DiscordLog(xPlayer.source, 'BOUGHT ITEMS', ('Player bought %sx %s for %s'):format(amount, item, ESX.Math.GroupDigits(price)), 'bought')
                end
            else
                Config.Notification(xPlayer.source, (Strings.cannot_carry):format(amount, item))
            end
        else
            Config.Notification(xPlayer.source, (Strings.lack_money):format(ESX.Math.GroupDigits(price - xMoney)))
        end
    elseif action == 'sell' then
        if xPlayer.getInventoryItem(item).count >= amount then
            xPlayer.addAccountMoney(Config.Account, price)
            xPlayer.removeInventoryItem(item, amount)
            Config.Notification(xPlayer.source, (Strings.sold):format(amount, item, ESX.Math.GroupDigits(price)))

            if Webhook.Settings.bought then
                DiscordLog(xPlayer.source, 'SOLD ITEMS', ('Player sold %sx %s for %s'):format(amount, item, ESX.Math.GroupDigits(price)), 'sold')
            end
        else
            Config.Notification(xPlayer.source, (Strings.lack_items):format(amount, item))
        end
    end

    if Config.Alert.enabled then
        SetTimeout(Config.Alert.after * 1000, function()
            StartSyncBlip(pedCoords)
        end)
    end
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[player]
end)