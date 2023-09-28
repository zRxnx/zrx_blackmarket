Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.DrawDistance = 20 --| Distance in units to see ped
Config.Cooldown = 1 --| In seconds
Config.Account = 'money' --| Used account to pay/sell
Config.IconColor  = 'rgba(173, 216, 230, 1)' --| rgba format

--| These jobs cant access blackmarket
Config.BlockedJobs = {
    police = true,
    ambulance = true
}

--| Locations
Config.Locations = {
    {
        name = 'Drug dealer', --| Name of drug dealer
        animation = {
            dict = 'mini@strip_club@idles@bouncer@base',
            name = 'base'
        }, --| Animation to play
        ped = `a_m_m_og_boss_01`, --| Ped
        coords = { --| Will pick random coords
            vector4(472.2762, -1775.3113, 28.0708, 263.9907),
            vector4(-559.9628, -872.1989, 26.0610, 189.5837)
        },
        content = { --| Your item data
            {
                label = 'Joint',
                item = 'joint',
                option = {
                    buy = 50,
                    sell = false
                }
            },
            {
                label = 'Heroin',
                item = 'heroin',
                option = {
                    buy = 55,
                    sell = false
                }
            },
        }
    },

    {
        name = 'Weapon dealer', --| Name of drug dealer
        animation = {
            dict = 'mini@strip_club@idles@bouncer@base',
            name = 'base'
        }, --| Animation to play
        ped = `a_m_m_og_boss_01`, --| Ped
        coords = { --| Will pick random coords
            vector4(-494.8733, -2687.1360, 16.3676, 41.6353),
            vector4(1252.6681, -2567.5767, 41.7162, 286.8083)
        },
        content = { --| Your item data
            {
                label = 'Pistol',
                item = 'weapon_pistol',
                option = {
                    buy = 1000,
                    sell = 200
                }
            },
            {
                label = 'Ammo',
                item = 'ammo-9',
                option = {
                    buy = 10,
                    sell = false
                }
            },
        }
    }
}

Config.Alert = {
    enabled = true, --| Enabled ?
    jobs = { --| These jobs get alerted
        police = true
    },
    after = 3, --| Alert after x seconds
    time = 30, --| How long should the blip display?
    blip = function(coords)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

		SetBlipSprite(blip, 161)
		SetBlipColour(blip, 1)
		SetBlipScale(blip, 0.5)
		SetBlipAlpha(blip, 255)
		SetBlipAsShortRange(blip, false)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('BLACKARMARKET ALERT')
		EndTextCommandSetBlipName(blip)
		PulseBlip(blip)
		SetBlipRoute(blip, true)
		SetBlipRouteColour(blip, 1)

		return blip
    end
}

--| Place here your notification
Config.Notification = function(player, msg)
    if IsDuplicityVersion() then
        TriggerClientEvent('esx:showNotification', player, msg, 'info')
    else
        ESX.ShowNotification(msg)
    end
end

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Settings.punish then
        DiscordLog(player, 'PUNISH', reason, 'punish')
    end

    DropPlayer(player, reason)
end

--| Place here your esx import
--| Change it if you know what you are doing
Config.EsxImport = function()
	if IsDuplicityVersion() then
		return exports.es_extended:getSharedObject()
	else
		return exports.es_extended:getSharedObject()
	end
end