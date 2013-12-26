#!/bin/sh

# print a battery bar
# with a label to know if AC is on

# battery files
POWER_SUPPLY_DIR=/sys/class/power_supply
BAT_CAPACITY_FILE=${POWER_SUPPLY_DIR}/BAT0/capacity
AC_ONLINE_FILE=${POWER_SUPPLY_DIR}/AC/online

# percent before warning
BAT_WARNING=10

# state for animations
STATE=$1

BAT_BAR=""
BAT_PERCENT=$(cat ${BAT_CAPACITY_FILE})

let "n=${BAT_PERCENT}/5"
SEQ=$(seq ${n})
BAT_BAR="["
for i in $SEQ; do
	BAT_BAR="${BAT_BAR}+"
done;

# check AC
if [ $(cat ${AC_ONLINE_FILE}) == 1 ]; then
	if [ $BAT_PERCENT != 100 ]; then
		# compute current ac frame
		if [ ${STATE} == 0 ]; then
			BAT_BAR="${BAT_BAR}-"
		elif [ ${STATE} == 1 ]; then
			BAT_BAR="${BAT_BAR}\\"
		elif [ ${STATE} == 2 ]; then
			BAT_BAR="${BAT_BAR}|"
		elif [ ${STATE} == 3 ]; then
			BAT_BAR="${BAT_BAR}/"
		fi;
		
		let "n=${n}+1"
		SEQ=$(seq ${n} 19)
		for i in $SEQ; do
			BAT_BAR="${BAT_BAR} "
		done;

		BAT_BAR="${BAT_BAR}][+]"
	else
		BAT_BAR="${BAT_BAR}][*]"
	fi;
else
	let "n=${n}+1"
	SEQ=$(seq ${n} 20)
	for i in $SEQ; do
		BAT_BAR="${BAT_BAR} "
	done;

	if [ ${BAT_PERCENT} -le ${BAT_WARNING} ]; then
		BAT_BAR="${BAT_BAR}][!]"
	else
		if [ ${STATE} == 0 ] || [ ${STATE} == 2 ]; then
			BAT_BAR="${BAT_BAR}][ ]"
		else
			BAT_BAR="${BAT_BAR}][-]"
		fi;
	fi;
fi;

echo "${BAT_BAR}"


