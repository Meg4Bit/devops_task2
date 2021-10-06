#!/bin/bash

function error_msg() {
	echo "Wrong number of arguments!"
	echo "Tip: ./script1.sh --workers [] --column [] --destination [] --dataset []"
	exit 1
}

if ! [[ $# = 8 ]]
then
	error_msg
fi

argc=$#
argv=("$@")

for (( j=0; j<argc; j++ ))
do
	if ! (($j % 2))
	then
		if [[ ${argv[j]} == "--workers" ]]; then
			workers=${argv[j+1]}
		elif [[ ${argv[j]} == "--column" ]]; then
			column=${argv[j+1]}
		elif [[ ${argv[j]} == "--destination" ]]; then
			destination=${argv[j+1]}
		elif [[ ${argv[j]} == "--dataset" ]]; then
			dataset=${argv[j+1]}
		else
			error_msg
		fi
	fi
done

if ! [[ -f ${dataset} ]]
then
	echo "Such dataset doesn't exist"
	exit 1
fi

reg='^[0-9]+$'
if [[ ! ${workers} =~ $reg ]]
then
	echo "Workers should be a positive number"
	exit 1
fi

if [[ $column =~ $reg ]]
then
	NF=$(head -1 ${dataset} | awk -F'\t' '{print NF}')
	if [[ column -gt NF || column -eq 0 ]]
	then
		echo "Column doesn't exist"
		exit 1
	fi
else
	column=`head -1 ${dataset} |
	awk -F\; '{for (i = 1; i <= NF; i++) {if ($i == "'${column}'") print i}}'`
	if ! [[ $column ]]
	then
		echo "Column doesn't exist $column"
		exit 1
	fi
fi

if ! [[ -d ${destination} ]]
then
	mkdir ${destination}
fi
awk -F\; "{if (FNR != 1) print \$$column}" ${dataset} | parallel -j ${workers} wget -q -P ${destination}
