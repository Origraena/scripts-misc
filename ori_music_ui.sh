#!/bin/sh

M_INPUT=~/music/_music.fifo
M_OUTPUT=~/music/_music.out

if [ $# == 0 ]; then
	exit 1;
fi;

TARGET=$(echo "$1" | perl -n -e '/(.*)=(.*)/ && print "$1\n"');
CMD=$(echo "$1" | perl -n -e '/(.*)=(.*)/ && print "$2\n"');

M_CMD="";

if [ ${TARGET} == 'track' ] || [ ${TARGET} == 't' ]; then
	if [ ${CMD} == 'next' ] || [ ${CMD} == 'n' ]; then
		M_CMD="pt_step 1";
	elif [ ${CMD} == 'prev' ] || [ ${CMD} == 'p' ]; then
		M_CMD="pt_step -1";
	fi;
elif [ ${TARGET} == 'playlist' ] || [ ${TARGET} == 'p' ]; then
	if [ ${CMD} == 'toggle' ] || [ ${CMD} == 't' ]; then
		M_CMD="pause";
	fi;
fi;

echo "${M_CMD}" >> ${M_INPUT};

