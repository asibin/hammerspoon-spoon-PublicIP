--- === PublicIP ===
---
--- Simple spoon for fetching your current public IP address and geolocation and displaying it in menubar.
--- Menubar is displaying IP, ISP and country. Useful if you are switching between VPNs
--- at regular basis or are just interested in your current ISP on public WIFI. Can be manually
--- refreshed by clicking on menubar widget or can be auto-refreshed each time network IP4 is 
--- changed.
---
--- Supports 2 modes of output - terse and normal. If terse variable is set to true it will display
--- short output with only current countryCode with further info available on click. Selecting any
--- of the values from dropdown (in both terse and normal mode) will copy that value to clipboard.
--- 
--- This spoon uses free geolocation service provided by awesome ip-api.com. Big thanks to 
--- them for making this possible. Please consider supporting them by subscribing to their PRO tier.
--- Commercial use of ip-api.com service is prohibited without PRO service plan. Use at your own
--- risk.
--- 
--- Example configuration:
--- ```
--- hs.loadSpoon("PublicIP")
--- spoon.PublicIP.terse = true
--- spoon.PublicIP.refreshIP()
--- ```
---
--- where 'spoon.PublicIP.terse' is optional in case you want to change to short layout
---
--- In case you want to watch for IPv4 address changes and auto refresh after loading spoon also add:
--- ```
--- function networkChangedCallback(store, keys)
---     hs.timer.doAfter(10, function()
---     spoon.PublicIP.refreshIP()
---   end)
--- end
--- 
--- n = hs.network.configuration.open()
--- n:monitorKeys("State:/Network/Service/.*/IPv4", true)
--- n:setCallback(cb)
--- n:start()
--- ```
--- 
--- In case you want to watch both IPv4 and IPv6 you need to monitor keys for IPv4 and IPv6.
---
--- Download: []()

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PublicIP"
obj.version = "2.0.0"
obj.author = "Sibin Arsenijević <sibin.arsenijevic@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "ISC - https://opensource.org/licenses/ISC"

obj.publicIPGeolocationService = "http://ip-api.com/json/"

--- PublicIP.terse
--- Variable
--- Terse layout for small monitors with notch that could hide full menubar
--- Defauts to false
obj.terse = false

--- Callback function for menu items to call refreshIP method
--- Callback
function callRefresh(modifiers, payload)
  obj:refreshIP()
end


function copyToClipboard(modifiers, payload)
  hs.pasteboard.writeObjects(payload.title)
end


function getGeoIPData()

  local status, data, headers = hs.http.get(obj.publicIPGeolocationService)
  
  local decodedJSON = {}

  if status == 200 then
    decodedJSON = hs.json.decode(data)

    if decodedJSON == nil then
      decodedJSON['err'] = "Failed to deserialize JSON from ip-api.com, service returned" .. data
      decodedJSON['errMsg'] = "N/A"
    end

    decodedJSON['err'] = nil
    decodedJSON['errMsg'] = nil

  elseif status == 0 then
    decodedJSON['err'] = "GeoIP service is not resolvable. Either there is no internet connection, DNS servers are not responding or GeoIP provider's DNS does not exist." 
    decodedJSON['errMsg'] = "No Internet"
  end

  if status == 429 then
    decodedJSON['err'] = "GeoIP requests are throttled, we are over 45 requests per minute from our IP. We will retry after 30 seconds. Consider subscribing to https://members.ip-api.com to support providers of geoip service)"
    decodedJSON['errMsg'] = "Throttled. Retrying..."
    
    hs.timer.doAfter(30, function()
     obj:refreshIP()
    end)

  end
  
  decodedJSON['httpStatus'] = status
  decodedJSON['rawData'] = data

  return decodedJSON
end


--- PublicIP:refreshIP()
--- Method
--- Refreshes IP information and redraws menubar widget
function obj:refreshIP()
  obj.public_ip_menu:setTitle("Refreshing...")

  local geoIPData = getGeoIPData()
  -- print(hs.inspect(geoIPData))

  local ISP = geoIPData.isp
  local country = geoIPData.country
  local publicIP = geoIPData.query  
  local countryCode = geoIPData.countryCode
  local lat = geoIPData.lat
  local lon = geoIPData.lon
 
  local errorMessage = geoIPData.errorMessage
  local fetchError = geoIPData.err
  local httpStatus = geoIPData.httpStatus

  if fetchError == nil then

    if obj.terse == true then
      obj.public_ip_menu:setTitle(countryCode)
      obj.public_ip_menu:setMenu(
        {
          {title = "🌍 " .. publicIP, fn = copyToClipboard},
          {title = "📇 " .. ISP, fn = copyToClipboard},
          {title = "📍 " .. country .. ", " .. countryCode, fn = copyToClipboard},
          {title = "🌐 " .. lat .. ", " .. lon, fn = copyToClipboard},
          {title = "Refresh", fn = callRefresh}
        }
      )
    else 
      obj.public_ip_menu:setTitle("🌍 " .. publicIP .. " 📇 " .. ISP .. " 📍 " .. country)
      obj.public_ip_menu:setMenu(
        {
          {title = "🌍 " .. publicIP, fn = copyToClipboard},
          {title = "📇 " .. ISP, fn = copyToClipboard},
          {title = "📍 " .. country .. ", " .. countryCode, fn = copyToClipboard},
          {title = "🌐 " .. lat .. ", " .. lon, fn = copyToClipboard},
          {title = "Refresh", fn = callRefresh}
        }
      )
    end

  else
    print("[CRITICAL] Failed fetching data from " .. obj.publicIPGeolocationService .. ", status: ", geoIPData.err)
    obj.public_ip_menu:setTitle("N/A")
    obj.public_ip_menu:setMenu(
      {
        {title = geoIPData.errMsg, fn = copyToClipboard, disabled = false},
        {title = "Check logs for more details.", disabled = true},
        {title = "Refresh", fn = callRefresh}
      }
    )
  end
end


function obj:init()
  obj.public_ip_menu = hs.menubar.new()

  obj.public_ip_menu:setTitle("Refreshing...")
  obj.public_ip_menu:setMenu(
    {
      {title = "Gathering data...", disabled = false},
      {title = "Refresh", fn = callRefresh}
    }
  )
end

return obj
