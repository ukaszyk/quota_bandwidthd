# quota_bandwidthd
Very simple method to manage o monthly quota in per IP basis as installable package for OpenWRT.

---

###Usage
- file **bandwidthd\_config.sh** - this is uci\_default script, which will modify default settings for bandwidthd. You can modify it according to your network settings.
It also adds firewall rule for blocking traffic when quota is exceeded.
Finally it adds new cron tasks which are needed for bandwidthd and *check_quota.sh* script.
- file **check_quota.sh** - shell script ran by cron tab rule (every 10 minutes by default). It checks if quota is exceeded and modifies firewall rule according to result of that check.

### Idea
Bandwitdthd tool collects all data transferred by connected devices and present it in table with per IP basis.
Script check_quota.sh runs every 10 minutes (it is configurable by crontab) and checks if monthly quota for selected IP address is not exceeded.
If it detects that data used by IP is greather than configured (in file /etc/config/bandwidthd) then it will enable firewall rule wchich will block access to WAN port.

---
