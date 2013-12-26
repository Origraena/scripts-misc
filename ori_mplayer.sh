#!/bin/sh

M_INPUT=~/music/_music.fifo
M_OUTPUT=~/music/_music.out

mplayer2 --quiet --idle --input=file=${M_INPUT} > ${M_OUTPUT} 2> /dev/null

