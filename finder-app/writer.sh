#!/bin/bash

writefile=$1
writestr=$2
args_num=$#

filename=`basename $writefile`	# get filename
foldername=`dirname $writefile`	# get directory path

echo "FILENAME = $filename"
echo "DIRECTORY = $foldername"

if [ ! $args_num -eq 2 ]; then
	echo "ERROR: Invalid Number of Arguments"
	echo "Total number of arguments should be 2"
	echo "The order of the arguments should be:"
	echo "	1) Full path to a file (including filename) on the filesystem."
	echo "	2) Text string to be written within the file specified above."
	exit 1
else
	if [ ! -d $foldername ]; then		# directory is non-existent
		echo "Creating directory..."
		mkdir -p $foldername && cd $foldername
		echo "Directory created: done."
	else	
		echo "Directory already exists"	
	fi
	if [ -e $writefile ]; then
		echo "File $writefile already exists"
		echo "$writestr" >> $writefile
		echo "File $writefile written"
	else
		echo "File $writefile does not exist --> Creating file..."
		touch $writefile
		echo "Done"
		echo "$writestr" >> $writefile
		echo "File $writefile written"
	fi
	exit 0
fi
