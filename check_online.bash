#!/usr/bin/bash

function usage()
{
	echo "USAGE:"
	echo "./check_online.bash YYYY MM DD"
	echo "Checks to see if rawacf files in the directory are online or only stored on tape archive"
	echo "Options:"
	echo "YYYY -- the year for which data files are requested"
	echo "MM -- the month for which data files are requested"
	echo "DD -- the day for which data files are requested (optional)"
}

function check_online()
{
	local nfiles=`ls $1 | wc -l`
	local noffline=`/opt/SUNWsamfs/bin/sfind $1 -offline | wc -l`
	if [ $noffline == 0 ]; then
		echo 0 #All files are online
	elif [ $nfiles == $noffline ]; then
		echo 1 #All files are offline
	else
		echo 2 #Some but not all files are online
	fi
}

function check_online2()
{
	echo $1
	nfiles=`ls $1 | wc -l`
	echo "number of files: $nfiles"
	noffline=`/opt/SUNWsamfs/bin/sfind $1 | wc -l`
	noffline=`/opt/SUNWsamfs/bin/sfind $1 -offline | wc -l`
	echo "number of offline files: $noffline"
}

SD_DATA="/sam-qfs/SUPERDARN/mirror/sddata/rawacf"
YR=$1
MO=$2
DY=$3
if [ "$#" -lt 2 ]; then
	usage
	exit
fi

DIR=$SD_DATA/$YR/$MO/$YR$MO$DY
if [ -z $DY ]; then
	DIR=$SD_DATA/$YR/$MO/
fi

#echo $DIR
check_online2 $DIR
result=$(check_online $DIR)

if [ $result == 0 ]; then
	echo "All files online"
elif [ $result == 1 ]; then
	echo "No files in the search path are staged"

	exit

	batch_stage $DIR
elif [ $result == 2 ]; then
	echo "Some but not all files in the search path are staged"

	exit

	#sfind $DIR* -offline | batch_stage -i

	echo "All files online for $YR/$MO"
fi

exit
