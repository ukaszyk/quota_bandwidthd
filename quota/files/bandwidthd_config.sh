#!/bin/sh
#===============================================================================
#
#          FILE:  bandwidthd_config.sh
#
#         USAGE:  ./bandwidthd_config.sh
#
#   DESCRIPTION:  ---
#
#        AUTHOR:  Lukasz Plewa (), ukaszyk@gmail.com
#       VERSION:  1.0
#       CREATED:  2015-06-30 10:28:53
# LAST MODIFIED:  2015-06-30 10:47:11
#      REVISION:  ---
#===============================================================================

# This is IP address for monitoring monthly quota limit
IP_ADDR=10.1.1.100

uci set bandwidthd.@bandwidthd[-1].dev='eth0'
uci set bandwidthd.@bandwidthd[-1].subnets='10.1.1.0/24'
uci set bandwidthd.@bandwidthd[-1].skip_intervals='0'
uci set bandwidthd.@bandwidthd[-1].graph_cutoff='1024'
uci set bandwidthd.@bandwidthd[-1].promiscuous='true'
uci set bandwidthd.@bandwidthd[-1].output_cdf='true'
uci set bandwidthd.@bandwidthd[-1].recover_cdf='true'
uci set bandwidthd.@bandwidthd[-1].filter='ip'
uci set bandwidthd.@bandwidthd[-1].graph='true'
uci set bandwidthd.@bandwidthd[-1].meta_refresh='30'

# This is additional setting needed only by "check_quota.sh" script. It defines quota limit
# in Mega bytes and IP address for that limit
uci add bandwidthd quota
uci set bandwidthd.@quota[-1].limit_mb='1000'
uci set bandwidthd.@quota[-1].quota_ip="\'${IP_ADDR}\'"

# Commit changes to file
uci commit bandwidthd

# You need to have properly set firewall zones and modified setting "dest" if your wan zone have different name.
uci add firewall rule
uci set firewall.@rule[-1].name='quota_disable'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].src_ip="\'${IP_ADDR}\'"
uci set firewall.@rule[-1].dest='wan_gsm'
uci set firewall.@rule[-1].target='REJECT'
uci set firewall.@rule[-1].enabled='0'

uci commit firewall

grep -q "check_quota" /etc/crontabs/root || echo "*/10    *   *   *   *       /sbin/check_quota.sh" >> /etc/crontabs/root
grep -q "bandwidthd" /etc/crontabs/root || echo "0 0 * * * * /bin/kill -HUP `cat /var/run/bandwidthd.pid`" >> /etc/crontabs/root
sync
