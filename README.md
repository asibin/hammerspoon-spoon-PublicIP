# PublicIP

Simple spoon for fetching your current public IP address and geolocation and displaying it in menubar.
Menubar is displaying IP, ISP and country. Useful if you are switching between VPNs
at regular basis or are just interested in your current ISP on public WIFI. Can be manually
refreshed by clicking on menubar widget or can be auto-refreshed each time network IP4 is 
changed.

This spoon uses free[^1] geolocation service provided by awesome [ip-api.com](https://ip-api.com/). Big thanks to 
them for making this possible. Please consider supporting them by subscribing to their PRO tier.

[^1]: Commercial use of ip-api.com service is prohibited without PRO service plan. Use at your own risk.

## Example configuration:

In your Hammerspoon config file add:
```
hs.loadSpoon("PublicIP")
```

In case you want to watch for IPv4 address changes and auto refresh after loading spoon add:

```
function networkChangedCallback(store, keys)
    hs.timer.doAfter(10, function()
    spoon.PublicIP.refreshIP()
  end)
end

n = hs.network.configuration.open()
n:monitorKeys("State:/Network/Service/.*/IPv4", true)
n:setCallback(cb)
n:start()
```
