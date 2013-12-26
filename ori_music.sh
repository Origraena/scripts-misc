#!/bin/sh

# allows to query the music db and either display information or
# add some tracks to mplayer2 current playlist
# see --help for more details

M_INPUT=~/music/_music.fifo

OK=0;
SQL_LINE="select file from track where";
DB_FILE='~/music/_music.db';	# default value 
PLAYLIST='/tmp/ori_playlist';
AUTOREMOVE=1;
PLAY=0;
SHOW=0;
SQL_USER=0;
RAW=1;
while [ $# -ge 1 ]; do
	if [ $1 == '--help' ] || [ $1 == '-h' ]; then
		echo "      +---------------+";
		echo "      |   ORI_MUSIC   |";
		echo "      +---------------+";

		echo "$0 [-p] [-s] [-n] [-b <base>] [-o <file>] [-r | -f] (-q <query> | -a <artist> | -t <album>)";
		echo "--play    -p               call mplayer2 on the playlist";
		echo "--show    -s               show the playlist";
		echo "--noclean -n               do not automatically delete the playlist file";
		echo "--db      -b    <base>     use <base> as the database file";
		echo "--output  -o    <file>     use <file> to store the playlist";
		echo "--raw     -r               print playlist in a raw output (without filtering)";
		echo "--noraw   -f               print playlist in a filtered output (i.e., only file names will be displayed)";
		echo "--sql     -q    <query>    use <query> as the sql query gathering information";
		echo "--artist  -a    <artist>   get all tracks from a given artist";
		echo "--album   -d    <album>    get all tracks from a given album";
		echo "--track   -t    <track>    get all tracks from a given name";

		echo "+--------------------------------------------------------------------------+";
		echo "|  This script allows one to query a sql database to get a music playlist  |";
		echo "|  then may call mplayer2 to play the selected tracks.                     |";
		echo "|  There must be at least one querying argument (-q, -a, -d or -t).        |";
		echo "|  The 'raw' mode allow one to query database with any sql query, while    |";
		echo "|  the 'noraw' mode filters only file paths in order to create a mplayer2  |";
		echo "|  compatible playlist.                                                    |";
		echo "+--------------------------------------------------------------------------+";
		exit 0;
	elif [ $1 == '--raw' ] || [ $1 == '-r' ]; then
		RAW=1;
	elif [ $1 == '--noraw' ] || [ $1 == '-f' ]; then
		RAW=0;
	elif [ $1 == '--play' ] || [ $1 == '-p' ]; then
		echo "[info] Enabling 'noraw' option to allow playing";
		RAW=0;
		PLAY=1;
	elif [ $1 == '--show' ] || [ $1 == '-s' ]; then
		SHOW=1;
	elif [ $1 == '--noclean' ] || [ $1 == '-n' ]; then
		AUTOREMOVE=0;
	elif [ $1 == '--sql' ] || [ $1 == '-q' ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --sql needs a parameter!"
			exit 1;
		fi;
		SQL_LINE=$1;
		SQL_USER=1;
		OK=2;
	elif [ $1 == '--db' ] || [ $1 == -b ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --db needs a parameter!"
			exit 2;
		fi;
		DB_FILE=$1
	elif [ $1 == '--output' ] || [ $1 == '-o' ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --output needs a parameter!"
			exit 3;
		fi;
		PLAYLIST=$1;
	elif [ $1 == '--artist' ] || [ $1 == '-a' ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --artist needs a parameter!"
			exit 4;
		fi;
		if [ ${OK} == 1 ]; then
			SQL_LINE="${SQL_LINE} and";
		fi
		SQL_LINE="${SQL_LINE} artist_id=(select id from artist where name='$1')";
		OK=1;
	elif [ $1 == '--album' ] || [ $1 == '-d' ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --album needs a parameter!"
			exit 4;
		fi;
		if [ ${OK} == 1 ]; then
			SQL_LINE="${SQL_LINE} and";
		fi
		SQL_LINE="${SQL_LINE} album_id=(select id from album where title='$1')";
		OK=1;
	elif [ $1 == '--track' ] || [ $1 == '-t' ]; then
		shift;
		if [ $# == 0 ]; then
			echo "[ERROR] --track needs a parameter!"
			exit 4;
		fi;
		if [ ${OK} == 1 ]; then
			SQL_LINE="${SQL_LINE} and";
		fi
		SQL_LINE="${SQL_LINE} title='$1'";
		OK=1;
	else
		echo "[warning] Unrecognized argument: $1";
	fi;
	shift;
done;

if [ ${OK} == 0 ]; then
	echo "Missing a mandatory argument!";
	exit 5;
fi;

if [ ${SQL_USER} == 0 ]; then
	SQL_LINE="${SQL_LINE} order by album_id,number"
fi;

if [ ${RAW} == 0 ]; then
	sqlite3 -line ${DB_FILE} "${SQL_LINE}" | perl -n -e '/file = (\/.*\.flac).*/ && print "$1\n"' > ${PLAYLIST}
else
	sqlite3 -line ${DB_FILE} "${SQL_LINE}" > ${PLAYLIST}
fi;

if [ ${SHOW} == 1 ]; then
	cat ${PLAYLIST};
fi;

if [ ${PLAY} == 1 ]; then
#	mplayer2 --playlist=${PLAYLIST}
	echo "loadlist ${PLAYLIST} 1" >> ${M_INPUT}
fi;

if [ ${AUTOREMOVE} == 1 ]; then
	rm ${PLAYLIST}
fi;

