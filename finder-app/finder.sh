#!/bin/bash
filesdir=$1
searchstr=$2
args_num=$# 

#check man test for if-arguments 

if [ ! $args_num -eq 2 ]; then
	echo "ERROR: Invalid Number of Arguments"
	echo "Total number of arguments should be 2"
	echo "The order of the arguments should be:"
	echo "	1) File Directory Path."
	echo "	2) String to be searched in the specified directory path."
	exit 1
else
	if [ -d "$filesdir" ]; then
		echo "$filesdir is a directory"
		cd $filesdir 
		num_files=`sudo find . -type f -print | wc -l`
		match_lines=`grep -ar "$searchstr" * | wc -l`
		echo "The number of files are $num_files and the number of matching lines are $match_lines"
		exit 0
	else
		echo "$filesdir does not represent a directory in the filesystem"
		exit 1
	fi
fi


