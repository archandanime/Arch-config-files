#!/bin/bash

RESOURCES_NAME="Resources"
RESOURCES_RKEY=""
RESOURCES_DEVICE="/dev/sdb2"

SCHOOL_NAME="School"
SCHOOL_RKEY=""
SCHOOL_DEVICE="/dev/sdb4"

WINDOWS_NAME="Windows"
WINDOWS_RKEY=""
WINDOWS_DEVICE="/dev/sda3"

WORK_NAME="Work"
WORK_RKEY=""
WORK_DEVICE="/dev/sdb1"

declare -a NAME=("$RESOURCES_NAME" "$SCHOOL_NAME" "$WINDOWS_NAME" "$WORK_NAME")
declare -a RKEY=("$RESOURCES_RKEY" "$SCHOOL_RKEY" "$WINDOWS_RKEY" "$WORK_RKEY")
declare -a DEVICE=("$RESOURCES_DEVICE" "$SCHOOL_DEVICE" "$WINDOWS_DEVICE" "$WORK_DEVICE")


syntax() {
	echo "desc-bitlk.sh <-lock/-unlock>"
}

unlock() {
	for ((i=0;i<4;i++)); do
		name="${NAME[$i]}"
		rkey="${RKEY[$i]}"
		device="${DEVICE[$i]}"
		if ! df | grep -q /winmount/$name ; then
			sudo dislocker -p$rkey -V $device -- /winmount/mapper/$name
			sudo mount /winmount/mapper/$name/dislocker-file /winmount/$name
			df -h /winmount/$name | tail -n 1
		else
			echo "$name already mounted"
		fi
		#echo $name . $rkey . $device
	done
}

lock() {
	for ((i=0;i<4;i++)); do
		name="${NAME[$i]}"
		sudo umount /winmount/$name
		sudo umount /winmount/mapper/$name
	done
}



case "$1" in
	"-lock" )
		lock ;;
	"-unlock" )
		unlock ;;
	* )
		syntax ;;
esac

