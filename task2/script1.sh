#!/bin/bash

function error_msg() {
	echo "Wrong arguments!"
	echo "Script requires 3 arguments: ./script1.sh --input [] --train_ratio [] --y_column []"
	exit 1
}

if ! [[ $# == 6 ]]
then
	error_msg
fi

argc=$#
argv=("$@")

for (( j=0; j<argc; j++ ))
do
	if ! (($j % 2))
	then
		if [[ ${argv[j]} == "--input" ]]; then
			input=${argv[j+1]}
		elif [[ ${argv[j]} == "--train_ratio" ]]; then
			train=${argv[j+1]}
		elif [[ ${argv[j]} == "--y_column" ]]; then
			y=${argv[j+1]}
		else
			error_msg
		fi
	fi
done

if ! [[ -f ${input} ]]
then
	echo "Such file doesn't exist"
	exit 1
fi

reg='^[0-9]+$'
if [[ ! ${train} =~ $reg || ${train} -lt 0 || ${train} -gt 100 ]]
then
	echo "Train ratio should be from 0 to 100"
	exit 1
fi

if [[ $y =~ $reg ]]
then
	column=${y}
	NF=$(head -1 ${input} | awk -F'\t' '{print NF}')
	if [[ column -gt NF || column -eq 0 ]]
	then
		echo "y_column doesn't exist"
		exit 1
	fi
else
	column=`head -1 ${input} |
	awk -F'\t' '{for (i = 1; i <= NF; i++) {if ($i == "'${y}'") print i}}'`
	if ! [[ $column ]]
	then
		echo "y_column doesn't exist"
		exit 1
	fi
fi

NR=$(wc -l ${input} | awk '{print $1}')
awk -v seed=$RANDOM -v train=$train -v rows=$(($NR-1)) -f train.awk ${input}
