# Hammerspoon Spoon - PublicIP

![image](https://user-images.githubusercontent.com/8343240/141217557-74630592-670e-47da-85a0-b615ecdad097.png)

**PLEASE NOTE**: you will need to update your configuration if you are switching from version 1.0.0 to 2.0.0. Check configuration example below.

Simple [Hammerspoon](https://www.hammerspoon.org) spoon for fetching your current public IP address and geolocation and displaying it in menubar.
Menubar is displaying IP, ISP and country. Useful if you are switching between VPNs
at regular basis or are just interested in your current ISP on public WIFI. Can be manually
refreshed by clicking on menubar widget or can be auto-refreshed each time network IP4 is 
changed (requires additional configuration, see below).

This spoon uses free[^1] geolocation service provided by awesome [ip-api.com](https://ip-api.com/). Big thanks to 
them for making this possible. Please consider supporting them by subscribing to their PRO tier.

[^1]: Commercial use of ip-api.com service is prohibited without PRO service plan. Use at your own risk.

## How to install
Checkout this repository into your Spoons directory (assuming you are using default spoons path):

```bash
git clone https://github.com/asibin/hammerspoon-spoon-PublicIP.git ~/.hammerspoon/Spoons/PublicIP.spoon
```

In your Hammerspoon config (`~/.hammerspoon/init.lua` if default) file add:

```lua
-- Load PublicIP spoon
hs.loadSpoon("PublicIP")

-- Shorter menubar for use with M1 macbooks that have notch 
spoon.PublicIP.terse = true

-- Get new state when loading configuration, this is required
spoon.PublicIP.refreshIP()
```
Reload you Hammespoon config if you don't have auto-reload.


## Example configuration for dynamic refreshes
In case you want to watch for IPv4 address changes and auto refresh widget add this code block to your Hammerspoon confing file after loading spoon:

```lua
-- After detecting change wait 10 seconds until 
-- new IP address becomes available
function networkChangedCallback(store, keys)
    hs.timer.doAfter(10, function()
    spoon.PublicIP.refreshIP()
  end)
end

-- Watch Network Service for IPv4 changes
n = hs.network.configuration.open()
n:monitorKeys("State:/Network/Service/.*/IPv4", true)
n:setCallback(networkChangedCallback)
n:start()
```

In this case Hammerspoon will wait 10s before refreshing IP after IPv4 address changes to give the time
for WIFI connection to establish. In order to avoid using timers you can use hs.timer.doUntil to force retires
until fetch succeeds.

## TODO
- ~~Allow configuration of wanted segments (ip, isp, country) to accommodate M1 Macs with notch since MacOS is hiding whole widget if it "touches" the notch~~ - "DONE"
- ~~Allow configuration to run widget in "compact" mode where it would be represented as a single icon in menubar and when clicked will open a "dropdown" with all information~~ - DONE
