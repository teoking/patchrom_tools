#!/bin/bash

# A tool to suspect id vilation in the smali files under a specific folder then open the meld to merge.
# By teoking.
# e.g. : 
# suspect_res_and_merge.sh $PORT_ROOT/tmoons/android.policy.jar.out \n
# $PORT_ROOT/android/android.policy.jar.out \n
# $PORT_ROOT/android/google-framework/android.policy.jar.out

PWD=`pwd`
SUSPECT_DIR=$1
COMPARE_DIR=$2
BASE_DIR=$3
suspecious_data_dir=$PWD/susp_data
meld_merge_batch=$suspecious_data_dir/meld_merge_batch.txt
not_merge_list=$suspecious_data_dir/not_merge_list.txt

echo "<<< Start suspect dir $SUSPECT_DIR "
#Clean prev data
rm -rf $suspecious_data_dir

mkdir -p $suspecious_data_dir
touch $meld_merge_batch
touch $not_merge_list

function suspect(){
	cd $SUSPECT_DIR

	for file in `find ./ -name "*.smali"`
	do
		is_suspecious=`grep -e "const v[0-9]\+, 0x[0-9a-f]\+" $file`
		if [ -n "$is_suspecious" ];then
			file=`echo $file | sed 's/.\///'`
			echo $file
			if [ -f $COMPARE_DIR/$file ];then
				echo "$COMPARE_DIR/$file"
				if [ -f $BASE_DIR/$file ];then
					echo "meld -a $SUSPECT_DIR/$file $COMPARE_DIR/$file $BASE_DIR/$file" >> $meld_merge_batch
				else
					echo "meld -a $SUSPECT_DIR/$file $COMPARE_DIR/$file" >> $meld_merge_batch
				fi
			else
				echo "$COMPARE_DIR/$file" >> $not_merge_list
			fi
		fi
	done
}

function open_meld() {
	cat $meld_merge_batch | while read line
	do
		command $line
	done
}

function _help() {
	echo "Usage: suspect_res_and_merge.sh SUSPECT_DIR COMPARE_DIR [BASE_DIR]"
	echo
	echo "       SUSPECT_DIR: the dir that is to be suspected."
	echo "       COMPARE_DIR: the dir that will be compare in meld"
	echo "       [BASE_DIR]: base dir that will be the third way in meld"
	echo
	echo " *NOTE* All the dir path should be absolute."
}

# Variables test.
if [ -z "$SUSPECT_DIR" ];then
	echo "Not enough parameters."
	echo
	_help
	exit 0
fi

if [ -z "$COMPARE_DIR" ];then
	echo "Not enough parameters."
	echo
	_help
	exit 0
fi

suspect SUSPECT_DIR
open_meld

echo
echo
echo ">>> check $suspecious_data_dir for suspecious res id vilation"
