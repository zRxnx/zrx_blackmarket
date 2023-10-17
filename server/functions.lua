local TriggerClientEvent = TriggerClientEvent

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