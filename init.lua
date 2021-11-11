--- === PublicIP ===
---
--- Simple spoon for fetching your current public IP address and geolocation and displaying it in menubar.
--- Menubar is displaying IP, ISP and country. Useful if you are switching between VPNs
--- at regular basis or are just interested in your current ISP on public WIFI. Can be manually
--- refreshed by clicking on menubar widget or can be auto-refreshed each time network IP4 is 
--- changed.
--- 
--- This spoon uses free geolocation service provided by awesome ip-api.com. Big thanks to 
--- them for making this possible. Please consider supporting them by subscribing to their PRO tier. --- Commercial use of ip-api.com service is prohibited without PRO service plan. Use at your own
--- risk.
--- 
--- Example configuration:
--- ```
--- hs.loadSpoon("PublicIP")
--- ```
--- 
--- In case you want to watch for IPv4 address changes and auto refresh after loading spoon add:
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
--- Download: []()

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "PublicIP"
obj.version = "1.0.0"
obj.author = "Sibin Arsenijević <sibin.arsenijevic@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "ISC - https://opensource.org/licenses/ISC"

obj.publicIPGeolocationService = "http://ip-api.com/json/"

--- PublicIP:refreshIP()
--- Method
--- Refreshes IP information and redraws menubar widget
function obj:refreshIP()
  obj.public_ip_menu:setTitle("Refreshing...")

  local status, data, headers = hs.http.get(obj.publicIPGeolocationService)

  if status == 200 then
    local decodedJSON = hs.json.decode(data)

    if decodedJSON == nil then
      print("[CRITICAL] Failed to deserialize JSON from ip-api.com, service returned " .. data)
      obj.public_ip_menu:setTitle("")
      return
    end

    local ISP = decodedJSON.isp
    local country = decodedJSON.country
    local publicIP = decodedJSON.query
    obj.public_ip_menu:setTitle("🌍 " .. publicIP .. " 📇 " .. ISP .. " 📍 " .. country)

  elseif status == 0 then
    obj.public_ip_menu:setTitle("No Internet")

  elseif status == 429 then
    print("[WARNING] GeoIP requests are throttled, we are over 45 requests per minute from our IP. We will retry after 30 seconds. Consider subscribing to https://members.ip-api.com to support providers of geoip service)")
    hs.timer.doAfter(30, function()
     obj:refreshIP()
    end)

  else
    print("[CRITICAL] Failed fetching data from ip-api.com, status: " .. status .. ", data: " .. data)
    obj.public_ip_menu:setTitle("")
  end
end

function obj:init()
  obj.public_ip_menu = hs.menubar.new()
  obj:refreshIP()
  obj.public_ip_menu:setClickCallback(function()
    obj:refreshIP()
  end)
end

return obj
