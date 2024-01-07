local TriggerClientEvent = TriggerClientEvent
local vector4 = vector4
local GetGameTimer = GetGameTimer

Player = {
    HasCooldown = function(player)
        if not Config.Cooldown then return false end
        local identifier = PLAYER_CACHE[player].license

        if COOLDOWN[identifier] then
            if os.time() - Config.Cooldown > COOLDOWN[identifier] then
                COOLDOWN[identifier] = nil
            else
                return true
            end
        else
            COOLDOWN[identifier] = os.time()
        end

        return false
    end
}

StartSyncBlip = function(coords)
    local xPlayer

    for player, state in pairs(PLAYERS) do
        xPlayer = CORE.Bridge.getVariables(player)

        if Config.Alert.jobs[xPlayer.job.name] then
            CORE.Bridge.notification(player, Strings.alert)
            TriggerClientEvent('zrx_blackmarket:client:startBlip', xPlayer.source, coords)
        end
    end
end

StartRandomLocation = function(index)
    CreateThread(function()
        local temp = Config.Locations[index]

        SetTimeout(temp.location.randomLocationInterval * 1000 * 60, function()
            math.randomseed(GetGameTimer())
            Wait(0)
            local coords = temp.location.coords[math.random(#temp.location.coords)]
            local message = ([[
                The dealer moved
    
                Name: **%s**
                Old coords: **%s**
                new coords: **%s**
            ]]):format(temp.name, LOC_DATA[index], coords)

            CORE.Server.DiscordLog(source, 'RANDOM LOCATION', message, Webhook.Links.randomloc)

            TriggerClientEvent('zrx_blackmarket:server:randomLocation', -1, index, vector4(coords.x, coords.y, coords.z, coords[4]))
            StartRandomLocation(index)

            LOC_DATA[index] = coords
        end)
    end)
end