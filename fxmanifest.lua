fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zRxnx'
description 'Advanced blackmarket system'
version '1.5.1'

docs 'https://docs.zrxnx.at'
discord 'https://discord.gg/mcN25FJ33K'

dependencies {
    'zrx_utility',
	'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
    'configuration/config.lua',
    'configuration/strings.lua',
    'shared/*.lua'
}

server_scripts {
    'configuration/webhook.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}