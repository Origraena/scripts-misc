#!/bin/sh

# print various informations about
# current mplayer run
# (also progress bar, and such)

# mplayer in/out-puts
M_INPUT=~/music/_music.fifo
M_OUTPUT=~/music/_music.out

# mplayer infos
MUSIC_BAR=""
ARTIST=""
ALBUM=""
TITLE=""
TRACK=""
PPOS=""
TPOS=""
TLEN=""

M_STATE=$1

# is running ?
echo "get_property filename" >> ${M_INPUT}; 
M_RUNNING=$(tail -n 1 ${M_OUTPUT} | perl -n -e '/ANS_ERROR.*/ && print "0\n" or print "1\n"');
if [ $M_RUNNING -eq "1" ]; then
	# is in pause?
	echo "get_property pause" >> ${M_INPUT};
	M_PAUSE=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_pause=(.*)/ && print "$1\n"');

	# meta infos
	echo "get_meta_artist" >> ${M_INPUT};
	ARTIST=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_META_ARTIST=.(.*)./ && print "$1\n"');
	echo "get_meta_album" >> ${M_INPUT};
	ALBUM=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_META_ALBUM=.(.*)./ && print "$1\n"');
	echo "get_meta_title" >> ${M_INPUT};
	TITLE=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_META_TITLE=.(.*)./ && print "$1\n"');
	echo "get_meta_track" >> ${M_INPUT};
	TRACK=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_META_TRACK=.(.*)./ && print "$1\n"');

	# pos infos (percent, then absolute -in seconds)
	echo "get_percent_pos" >> ${M_INPUT};
	PPOS=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_PERCENT_POSITION=(.*)/ && print "$1\n"');
	# the milliseconds are filtered
	echo "get_time_pos" >> ${M_INPUT};
	TPOS=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_TIME_POSITION=(.*)\..*/ && print "$1\n"');
	echo "get_time_length" >> ${M_INPUT};
	TLEN=$(tail -n 2 ${M_OUTPUT} | perl -n -e '/ANS_LENGTH=(.*)\..*/ && print "$1\n"');

	let "len_min=${TLEN}/60"
	let "len_sec=${TLEN}%60"
	let "pos_min=${TPOS}/60"
	let "pos_sec=${TPOS}%60"

	if [ $len_sec -lt 10 ]; then
		len_sec="0${len_sec}"
	fi;
	if [ $pos_sec -lt 10 ]; then
		pos_sec="0${pos_sec}"
	fi;

	# displays meta infos
	MUSIC_BAR="${ARTIST} - ${ALBUM} - ${TRACK} ${TITLE} [";

	# displays progress bar
	let "n=${PPOS}/5"
	SEQ=$(seq 2 ${n})
	for i in $SEQ; do
		MUSIC_BAR="${MUSIC_BAR}-"
	done;
	# final char
	if [ $M_PAUSE == 'yes' ]; then
		MUSIC_BAR="${MUSIC_BAR}|"
	else
		if [ $M_STATE == 0 ]; then
			MUSIC_BAR="${MUSIC_BAR}>"
		else
			MUSIC_BAR="${MUSIC_BAR}}"
		fi;
	fi;
	let "n=${n}+1"
	SEQ=$(seq ${n} 20)
	for i in $SEQ; do
		MUSIC_BAR="${MUSIC_BAR} " # spaces
	done;
	MUSIC_BAR="${MUSIC_BAR}]"

	MUSIC_BAR="${MUSIC_BAR} ${pos_min}:${pos_sec}/${len_min}:${len_sec}"
fi; # end mplayer is running

echo "${MUSIC_BAR}"

