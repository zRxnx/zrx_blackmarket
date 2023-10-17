local TriggerServerEvent = TriggerServerEvent

OpenShopMenu = function(data)
    if Config.BlockedJobs[CORE.Bridge.getVariables().job.name] then
        return CORE.Bridge.notification(Strings.not_permitted)
    end

    data = data.args
    local MENU = {}

    for i, data2 in pairs(data.content) do
        local metadata = {}

        if data2.option.buy then
            metadata[#metadata + 1] = { label = Strings.buy, value = (Strings.buy_desc):format(data2.option.buy) }
        end

        if data2.option.sell then
            metadata[#metadata + 1] = { label = Strings.sell, value = (Strings.sell_desc):format(data2.option.sell) }
        end

        if #metadata <= 0 then
            goto continue
        end

		MENU[#MENU + 1] = {
			title = data2.label,
			description = Strings.click_action,
			arrow = true,
            icon = 'fa-solid fa-user',
            iconColor = Config.IconColor,
            metadata = metadata,
			onSelect = function()
                local select = {}

                if data2.option.buy then
                    select[#select + 1] = { label = Strings.buy, value = 'buy' }
                end

                if data2.option.sell then
                    select[#select + 1] = { label = Strings.sell, value = 'sell' }
                end

                if #select <= 0 then
                    return CORE.Bridge.notification(Strings.contact_admin)
                end

                local input = lib.inputDialog(data2.name, {
                    { type = 'select', label = Strings.action, description = Strings.action_desc, options = select, required = true, default = select[1].value },
                    { type = 'number', label = Strings.amount, description = Strings.amount_desc, required = true, default = 1 }
                })

                if not input then
                    return CORE.Bridge.notification(Strings.dialog_error)
                elseif input[1] == 'buy' then
                    TriggerServerEvent('zrx_blackmarket:server:processAction', 'buy', data2.item, input[2], data2.option.buy)
                elseif input[1] == 'sell' then
                    TriggerServerEvent('zrx_blackmarket:server:processAction', 'sell', data2.item, input[2], data2.option.sell)
                end
			end,
		}

        ::continue::
	end

	lib.registerContext({
		id = 'zrx_blackmarket:shopPage',
		title = Strings.title,
		options = MENU,
	})
	lib.showContext('zrx_blackmarket:shopPage')
end

StartCooldown = function()
    if not Config.Cooldown then return end
    COOLDOWN = true

    CreateThread(function()
        SetTimeout(Config.Cooldown * 1000, function()
            COOLDOWN = false
        end)
    end)
end