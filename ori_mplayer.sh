#!/bin/sh

M_INPUT=~/music/_music.fifo
M_OUTPUT=~/music/_music.out

mplayer2 --quiet --idle --input=file=${M_INPUT} > ${M_OUTPUT} 2> /dev/null
#
#
## all commands may be prefixed with
## 'pausing_keep' 'pausing_toggle' 'pausing'
## default: 'pausing_keep'
#
## 1 => append, 0 => immediate
## only a single track at a time
#echo "loadfile '${TRACK}' 1" >> ${M_INPUT}
#
## step forward
#echo "pt_step 1" >> ${M_INPUT}
## or backward
#echo "pt_step -1" >> ${M_INPUT}
#
## load a complete playlist
#echo "loadlist ${PLAYLIST} 1" >> ${M_INPUT}

