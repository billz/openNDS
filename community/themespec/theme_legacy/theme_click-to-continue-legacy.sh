#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2022
#Copyright (C) BlueWave Projects and Services 2015-2022
#This software is released under the GNU GPL license.
#
# Warning - shebang sh is for compatibliity with busybox ash (eg on OpenWrt)
# This should be changed to bash for generic Linux
#

# Title of this theme:
title="theme_click-to-continue-legacy"

# Description:
# This theme allows the legacy splash.html splash page to be used

# functions:

generate_splash_sequence() {
	click_to_continue
}

header() {
# Define a dummy header return code for libopennds
	type header &>/dev/null
}

click_to_continue() {
	# This ThemeSpec imports a legacy splash.html file for a simple click to continue splash page with no client validation.
	# The client is NOT required to accept a terms of service statement and does not receive any indication of a privacy policy.
	#
	# Warning:
	# Use of this ThemeSpec may make you personally liable for misuse of the Internet connection and may not comply with your country or state regulations.
	# Use at your own risk at public venues.
	#
	# The legacy splash.html file can be stored anywhere that this script can access.
	# Traditionally it was stored in /etc/opennds/htdocs, so make sure you set the variable "legacy" to match the location.
	legacy="/etc/opennds/htdocs/splash.html"
	legacysplash=$mountpoint/ndscids/$hid.html

	if [ -e "$legacy" ]; then
		cp $legacy $legacysplash

		sedstr="s|\$gatewayname|$gatewayname|"
		sed -i "$sedstr" "$legacysplash"

		authaction="/opennds_auth/"
		sedstr="s|\$authaction|$authaction|"
		sed -i "$sedstr" "$legacysplash"

		option="gatewayfqdn"
		get_option_from_config

		if [ -z "$gatewayfqdn" ]; then
			gatewayfqdn="status.client"
		fi

		redir="http://$gatewayfqdn"
		sedstr="s|\$redir|$redir|"
		sed -i "$sedstr" "$legacysplash"

		tok=$(printf "$hid$key" | sha256sum | awk -F' ' '{printf $1}')
		sedstr="s|\$tok|$tok|"
		sed -i "$sedstr" "$legacysplash"

		cat "$legacysplash"
		rm "$legacysplash"
		exit 0
	else
		exit 1
	fi
}

#### end of functions ####


#################################################
#						#
#  Start - Main entry point for this Theme	#
#						#
#  Parameters set here overide those		#
#  set in libopennds.sh			#
#						#
#################################################

# Quotas and Data Rates
#########################################
# Set length of session in minutes (eg 24 hours is 1440 minutes - if set to 0 then defaults to global sessiontimeout value):
# eg for 100 mins:
# session_length="100"
#
# eg for 20 hours:
# session_length=$((20*60))
#
# eg for 20 hours and 30 minutes:
# session_length=$((20*60+30))
session_length="0"

# Set Rate and Quota values for the client
# The session length, rate and quota values could be determined by this script, on a per client basis.
# rates are in kb/s, quotas are in kB. - if set to 0 then defaults to global value).
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$session_length $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters we expect to be sent sent from openNDS ($ndsparamlist):
# Note you can add custom parameters to the config file and to read them you must also add them here.
# Custom parameters are "Portal" information and are the same for all clients eg "admin_email" and "location" 
ndscustomparams=""
ndscustomimages=""
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables used in the Login Dialogue generated by this script is $fasvarlist and defined in libopennds.sh
#
# Additional custom FAS variables defined in this theme should be added to $fasvarlist here.
additionalthemevars=""

fasvarlist="$fasvarlist $additionalthemevars"

# You can choose to define a custom string. This will be b64 encoded and sent to openNDS.
# There it will be made available to be displayed in the output of ndsctl json as well as being sent
#	to the BinAuth post authentication processing script if enabled.
# Set the variable $binauth_custom to the desired value.
# Values set here can be overridden by the themespec file

#binauth_custom="This is sample text sent from \"$title\" to \"BinAuth\" for post authentication processing."

# Encode and activate the custom string
#encode_custom

# Set the user info string for logs (this can contain any useful information)
userinfo="$title"

# Customise the Logfile location. Note: the default uses the tmpfs "temporary" directory to prevent flash wear.
# Override the defaults to a custom location eg a mounted USB stick.
#mountpoint="/mylogdrivemountpoint"
#logdir="$mountpoint/ndslog/"
#logname="ndslog.log"



