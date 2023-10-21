if not Config.CheckForUpdates then return end
local curResName = GetCurrentResourceName()
local curVersion = GetResourceMetadata(curResName, 'version')
local resourceName = 'zrx_blackmarket'
local continueCheck = true
local PerformHttpRequest = PerformHttpRequest

local getRepoInformations = function()
    local repoVersion, repoURL

    PerformHttpRequest('https://api.github.com/repos/zRxnx/zrx_blackmarket/releases/latest', function(err, response)
        if err == 200 then
            local data = json.decode(response)

            repoVersion = data.tag_name
            repoURL = data.html_url
        else
            repoVersion = curVersion
            repoURL = 'https://github.com/zRxnx/zrx_blackmarket'
        end
    end, 'GET')

    lib.waitFor(function()
        return (repoVersion and repoURL)
    end, 'Version check Timeout', 5000)

    return repoVersion or 'INVALID RESPONSE', repoURL or 'INVALID RESPONSE'
end

local checkVersion = function()
    local repoVersion, repoURL = getRepoInformations()

    if curVersion ~= repoVersion then
        print(('^0[^3WARNING^0] %s is ^1NOT ^0up to date!'):format(resourceName))
        print(('^0[^3WARNING^0] Your Version: ^2%s^0'):format(curVersion))
        print(('^0[^3WARNING^0] Latest Version: ^2%s^0'):format(repoVersion))
        print(('^0[^3WARNING^0] Get the latest Version from: ^2%s^0'):format(repoURL))
    elseif repoVersion == 'INVALID RESPONSE' or repoURL == 'INVALID RESPONSE' then
        print('^0[^1ERROR^0] Failed to fetch version')
        continueCheck = false
    else
        print(('^0[^2INFO^0] %s is up to date! (^2%s^0)'):format(resourceName, curVersion))
        continueCheck = false
    end
end

CreateThread(function()
    if (curResName ~= resourceName) then
        print("^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^3!^1FATAL ERROR^3!^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1^7\n")
        print(("^1%s has failed to load!^7\n"):format(resourceName))
        print(("Please ensure that the resource folder is called ^2%s^7, or ^1you may encounter errors!^7\n"):format(resourceName))
        print("^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^4-^5-^6-^8-^9-^1-^2-^3-^3!^1FATAL ERROR^3!^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1-^9-^8-^6-^5-^4-^3-^2-^1^7\n")
        return
    end
    print(('^0[^2INFO^0] %s has started successfully!'):format(resourceName))
    PerformHttpRequest('https://github.com/zRxnx/zrx_blackmarket/releases/latest', checkVersion, 'GET')
end)