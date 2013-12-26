#!/bin/sh

# gather various information about
# battery, date, music and such
# then display it to xroot

# if there is a config file ~/.orisbrc
# then display parameters are read from it
# if the file is present but contains not a single line
# then the script won't work
# so create it with "echo '' > ~/.orisbrc"


# repertory where to find all scripts
SCRIPTS_DIR=~/dev/scripts/status_bar/

# sleep between each tick
REFRESH_TIME=1

# global display variables
DISPLAY_BAT=1
DISPLAY_MUSIC=1
DISPLAY_SOUND=1
DISPLAY_DATE=1

# internal state for animations
STATE=0
M_STATE=0

while [ -f /tmp/ori_status-bar.lock ]; do

	# check whether some information need to be masked
	if [ -f ~/.orisbrc ]; then
		DISPLAY_BAT=$(cat ~/.orisbrc | perl -n -e '/^battery=(.).*/ && print "$1\n"');
		DISPLAY_MUSIC=$(cat ~/.orisbrc | perl -n -e '/^music=(.).*/ && print "$1\n"');
		DISPLAY_SOUND=$(cat ~/.orisbrc | perl -n -e '/^sound=(.).*/ && print "$1\n"');
		DISPLAY_DATE=$(cat ~/.orisbrc | perl -n -e '/^date=(.).*/ && print "$1\n"');
		if [ ! $DISPLAY_BAT ]; then
			DISPLAY_BAT=1
		fi;
		if [ ! $DISPLAY_MUSIC ]; then
			DISPLAY_MUSIC=1
		fi;
		if [ ! $DISPLAY_SOUND ]; then
			DISPLAY_SOUND=1
		fi;
		if [ ! $DISPLAY_DATE ]; then
			DISPLAY_DATE=1
		fi;
	fi;

#while [ 1 ]; do # for debug
	STATUS_BAR=""

	# battery part
	if [ ${STATE} == 0 ]; then
		STATE=1;
	elif [ ${STATE} == 1 ]; then
		STATE=2;
	elif [ ${STATE} == 2 ]; then
		STATE=3;
	else
		STATE=0;
	fi;
	BAT_BAR="$(${SCRIPTS_DIR}/ori_battery_display.sh ${STATE})"

	# date part
	DATE_BAR=$(date +"%A %B %d %Y -- %H:%M:%S")

	# mplayer bar
	if [ ${M_STATE} == 0 ]; then
		M_STATE=1;
	else
		M_STATE=0;
	fi;
	MUSIC_BAR="# $(${SCRIPTS_DIR}/ori_music_display.sh ${M_STATE}) #";
	
	# sound bar
	SOUND_BAR="~ $(${SCRIPTS_DIR}/ori_sound_display.sh) ~";

	STATUS_BAR=" ${STATUS_BAR}"

	if [ $DISPLAY_MUSIC == 1 ]; then
		STATUS_BAR="${STATUS_BAR}  ${MUSIC_BAR}"
	fi;

	if [ $DISPLAY_SOUND == 1 ]; then
		STATUS_BAR="${STATUS_BAR}  ${SOUND_BAR}"
	fi;

	if [ $DISPLAY_BAT == 1 ]; then
		STATUS_BAR="${STATUS_BAR}  ${BAT_BAR}"
	fi;

	if [ $DISPLAY_DATE == 1 ]; then
		STATUS_BAR="${STATUS_BAR}  ${DATE_BAR}"
	fi;

	STATUS_BAR="${STATUS_BAR}    "

	xsetroot -name "${STATUS_BAR}"
	sleep $REFRESH_TIME
done;

