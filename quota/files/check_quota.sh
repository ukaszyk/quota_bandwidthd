#!/bin/sh
#===============================================================================
#
#          FILE:  check_quota.sh
#
#         USAGE:  ./check_quota.sh
#
#   DESCRIPTION:  ---
#
#        AUTHOR:  Lukasz Plewa (), ukaszyk@gmail.com
#       VERSION:  1.0
#       CREATED:  2015-06-26 16:17:32
# LAST MODIFIED:  2015-06-30 11:18:56
#      REVISION:  ---
#===============================================================================
. /lib/functions.sh

handle_rule() {
	local config="$1"
    local custom="$2"
    local name
    local enabled
    config_get name "$config" name
    if [ $name == "quota_disable" ]; then
    	echo "Found rule with name: $name in config=$config"
    	config_get enabled "$config" enabled
    	echo "In this rule enabled=$enabled"
    	if [ $enabled != $custom ]; then
    		echo "Will set \"enabled\" option to value: $custom"
    		uci set firewall.$config.enabled=$custom
    		uci commit firewall
    		/etc/init.d/firewall reload
    	fi
    fi
}


unblock_rule()
{
	local enable="$1"
	config_load firewall
	config_foreach handle_rule rule $enable
}

get_quota()
{
	local quota=0
	local ip=""
	ip=$(uci get -q bandwidthd.@quota[-1].quota_ip)
	echo $ip

	quota=$(uci get -q bandwidthd.@quota[-1].limit_mb)
	if [ -z $quota ]; then
		echo "0"
	elif
		echo "$quota"
	fi
}

to_mb()
{
	local input=$1
	local output_mb="0"
	[ -z $input ] && echo "0" && return 0
	unit=$(echo $input | sed -e 's/.*\(.\)$/\1/')
	[ $unit == "K" ] && exit 0
	if [ $unit == "M" ]; then
		output_mb=$(echo $input | cut -d'.' -f1)
	elif [ $unit == "G" ]; then
		tmp_used=$(echo $input | cut -d'.' -f1)
		output_mb=`expr $tmp_used \* 1024`
	fi
	echo "$output_mb"
}

QUOTA_CONFIG=$( get_quota )
IP=$( echo $QUOTA_CONFIG | cut -f 1 )
QUOTA=$( echo $QUOTA_CONFIG | cut -f 2 )
echo "QUOTA=$QUOTA, IP=$IP"

MONTHLY_USED=$(cat /www/bandwidthd/index3.html |grep "#10.1.1.100"|cut -d">" -f8|cut -d"<" -f1)
MONTHLY_USED_MB=$(to_mb $MONTHLY_USED)
WEEKLY_USED=$(cat /www/bandwidthd/index2.html |grep "#10.1.1.100"|cut -d">" -f8|cut -d"<" -f1)
WEEKLY_USED_MB=$(to_mb $WEEKLY_USED)
DAILY_USED=$(cat /www/bandwidthd/index.html |grep "#10.1.1.100"|cut -d">" -f8|cut -d"<" -f1)
DAILY_USED_MB=$(to_mb $DAILY_USED)


echo "MONTHLY_USED_MB=$MONTHLY_USED_MB"
echo "WEEKLY_USED_MB=$WEEKLY_USED_MB"
echo "DAILY_USED_MB=$DAILY_USED_MB"

# Find maximum
USED_MB=$MONTHLY_USED_MB
[ $USED_MB -lt $WEEKLY_USED_MB ] && USED_MB=$WEEKLY_USED_MB
[ $USED_MB -lt $DAILY_USED_MB ] && USED_MB=$DAILY_USED_MB
echo "Final USED_MB=$USED_MB"

if [ $QUOTA -lt $MONTHLY_USED_MB ]; then
	echo "Exceed quota for this month. Turn on blocking rule for GSM"
	unblock_rule "1"
else
	echo "Quota for this month not exceeded. Turn off blocking rule for GSM"
	unblock_rule "0"
fi
