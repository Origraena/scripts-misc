#!/bin/sh

# print a volume bar
# the chars being used depend
# on the state of the speaker
# (X for mute, O for unmute)

S_PERCENT=$(amixer -M sget Master | tail -n 1 | perl -n -e '/.* ([0-9]+) \[([0-9]+)%\] \[(.*)dB\] \[(.*)\]/ && print "$2\n"');
S_MUTE=$(amixer -M sget Master | tail -n 1 | perl -n -e '/.* ([0-9]+) \[([0-9]+)%\] \[(.*)dB\] \[on\]/ && print "1\n" or print "0\n"');

S_SOUND="[";

S_FULL_CHAR="O";
S_PART_CHAR="0";

if [ ${S_MUTE} ]; then
	if [ ${S_MUTE} -eq 0 ]; then
		S_FULL_CHAR="X";
		S_PART_CHAR="x";
	fi;
fi;

if [ ${S_PERCENT} ]; then
	let "n=${S_PERCENT}/10";
	let "l=${S_PERCENT}%10";

	SEQ=$(seq ${n});
	for i in ${SEQ}; do
		S_SOUND="${S_SOUND}${S_FULL_CHAR}";
	done;

	let "n=${n}+1";

	if [ ${l} -ge 5 ]; then
		S_SOUND="${S_SOUND}${S_PART_CHAR}";
		let "n=${n}+1";
	fi;

	SEQ=$(seq ${n} 10);
	for i in ${SEQ}; do
		S_SOUND="${S_SOUND} ";
	done;
fi;

S_SOUND="${S_SOUND}]";
echo "${S_SOUND}";

