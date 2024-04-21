---@diagnostic disable: cast-local-type, need-check-nil
CORE = exports.zrx_utility:GetUtility()
PLAYER_CACHE, FETCHED, COOLDOWN, LOC_DATA, PLAYERS = {}, {}, {}, {}, {}
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords
local vector3 = vector3
local GetGameTimer = GetGameTimer

RegisterNetEvent('zrx_utility:bridge:playerLoaded', function(player)
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
end)

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_blackmarket')
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
        PLAYERS[player] = true
    end

    math.randomseed(GetGameTimer())
    for i, data in ipairs(Config.Locations) do
        LOC_DATA[i] = data.location.coords[math.random(1, #data.location.coords)]

        if data.location.randomLocationInterval then
            StartRandomLocation(i)
        end
    end
end)

lib.callback.register('zrx_blackmarket:server:getLocations', function(source)
    if not FETCHED[source] then
        FETCHED[source] = true

        lib.waitFor(function()
            return #LOC_DATA == #Config.Locations
        end, 'Location timeout', 10000)

	    return LOC_DATA or {}
    else
        Config.PunishPlayer(source, 'Tried to trigger "zrx_blackmarket:server:getLocations"')
    end
end)

AddEventHandler('playerDropped', function()
    PLAYERS[source] = nil
end)

RegisterNetEvent('zrx_blackmarket:server:processAction', function(action, item, amount, price)
    price = price * amount
    local xPlayer = CORE.Bridge.getPlayerObject(source)
    local ped = GetPlayerPed(source)
	local pedCoords = GetEntityCoords(ped)
    local isAllowed = false

    if Player.HasCooldown(source) then
        return CORE.Bridge.notification(source, Strings.on_cooldown)
    end

    for i, data in pairs(Config.Locations) do
        for k, data2 in pairs(data.location.coords) do
            if #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(data2.x, data2.y, data2.z)) < 2 then
                isAllowed = true
                break
            end
        end
	end

	if not isAllowed then
        print('ban')
		--return Config.PunishPlayer(source, 'Tried to trigger "zrx_blackmarket:server:processAction"')
	end

    if action == 'buy' then
        local xMoney = xPlayer.getAccount(Config.Account).money

        if xMoney >= price then
            if xPlayer.canCarryItem(item, amount) then
                xPlayer.removeAccountMoney(Config.Account, price)
                xPlayer.addInventoryItem(item, amount)
                xPlayer.notification((Strings.bought):format(amount, item, lib.math.groupdigits(price, '.')))

                if Webhook.Links.bought:len() > 0 then
                    local message = ([[
                        The player bought items
            
                        Item: **%s**
                        Amount: **%s**
                        Cost: **%s**
                    ]]):format(item, amount, lib.math.groupdigits(price, '.'))

                    CORE.Server.DiscordLog(source, 'BOUGHT', message, Webhook.Links.bought)
                end
            else
                CORE.Bridge.notification(source, (Strings.cannot_carry):format(amount, item))
            end
        else
            CORE.Bridge.notification(source, (Strings.lack_money):format(lib.math.groupdigits(price - xMoney, '.')))
        end
    elseif action == 'sell' then
        local count = xPlayer.getItemCount(item)

        if count >= amount then
            xPlayer.addAccountMoney(Config.Account, price)
            xPlayer.removeInventoryItem(item, amount)
            xPlayer.notification((Strings.sold):format(amount, item, lib.math.groupdigits(price, '.')))

            if Webhook.Links.sold:len() > 0 then
                local message = ([[
                    The player sold items
        
                    Item: **%s**
                    Amount: **%s**
                    Cost: **%s**
                ]]):format(item, amount, lib.math.groupdigits(price, '.'))

                CORE.Server.DiscordLog(source, 'SOLD', message, Webhook.Links.sold)
            end
        else
            CORE.Bridge.notification(source, (Strings.lack_items):format(amount, item))
        end
    end

    if Config.Alert.enabled then
        local player = source
        SetTimeout(Config.Alert.after * 1000, function()
            CORE.Bridge.notification(player, Strings.sawn)
            StartSyncBlip(pedCoords)
        end)
    end
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[PLAYER_CACHE[player].identifier]
end)