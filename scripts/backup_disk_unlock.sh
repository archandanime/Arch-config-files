#!/bin/bash
 
# Empty serial means remote block device(nbd)
# Do not use dm-crypt on disk without partition table(msdos/gpt)
# Currently only supports devices encrypted partition as the only partition
# Last edited: 2023-03-23


showSyntax() {
echo "Syntax: ./$(basename $0) <hbu/nbu> <attach/detach>"
exit 1
}


##### DEVICE VARIABLES #####
importHBUvars() {
# nbd
USE_NDB=
NBD_HOST=
NBD_PORT=
NBD_SSH_USER=
NBD_EXPORT_NAME=

# physical
SERIAL=
[ ! "$SERIAL" == "" ] && [ ! "$USE_NDB" == "yes" ] && DISK_SDX=`echo /dev/$(lsblk -o name,serial | grep $SERIAL | awk '{print $1}')`

# dm-crypt - mounting
DMCRYPT_MODE=
DECRYPT_TYPE=
USE_LUKSHEADER=

DEVICE=
MAPPER_NAME=
LUKS_HEADER=
KEYFILE=
HEADERFILE=
PASSPHRASE=
MOUNTPOINT=

# LVM
USE_LVM=
LVM_VG=
LVM_LV=
}


importNBUvars() {
# NBD
USE_NBD=
NBD_HOST=
NBD_PORT=
NBD_SSH_USER=s
NBD_EXPORT_NAME=

SERIAL=""
[ ! "$SERIAL" == "" ] && [ ! "$USE_NBD" == "yes" ] && DISK_SDX=`echo /dev/$(lsblk -o name,serial | grep $SERIAL | awk '{print $1}')`

# dm-crypt - mounting
DMCRYPT_MODE=
DECRYPT_TYPE=
USE_LUKSHEADER=

DEVICE=
MAPPER_NAME=
LUKS_HEADER=
KEYFILE=
PASSPHRASE=
MOUNTPOINT=

# LVM
USE_LVM=
LVM_VG=
LVM_LV=
}

##### DISPLAY TEXT #####
export red="$(tput setaf 1)"
export green="$(tput setaf 2)"
export cyan="$(tput setaf 6)"
export purple="$(tput setaf 057)"
export b="$(tput bold)"
export reset="$(tput sgr0)"


info() {
	printf "${b}${cyan}%s${reset} ${b}%s${reset}\\n" "::" "${@}"
}

fail() {
	printf "${red}%s${reset}\\n" "[ERROR] $*" >&2
	# exit 1
}

succeed() {
	printf "${b}${green}%s${reset} %s\\n\\n" "[OK]" "${@}"
}

msg_head() {
	printf "${b}${cyan}%s${reset} ${b}%s${reset}" "${@}"
}

msg() {
	printf "${purple}%s${reset} %s${reset}\\n" "${@}"
}

##### OPERATIONS #####
checkDiskConnected() {
case $SERIAL in
	"" )
		[ ! "$(ifconfig enp2s0 | grep 'inet' | cut -d: -f2 | awk '{print $2}')" == "fe80::c4ee:c0be:1444:6e%wlo1 192.168.10.32" ] && \
		{ fail "Not connected to local network"; exit 1; } ;;
	* )
		if ! lsblk -o serial | grep -q -e $SERIAL ; then
			fail "Storage device $MAPPER_NAME is not connected, perhaps the device has been powered off, try re-plugging in the device"
		exit 1
		fi ;;
esac
}


setCryptsetupArgs() {
case $DMCRYPT_MODE in
	"plain" ) cryptsetup_arg_mode="plainOpen" ;;
	"luks" ) cryptsetup_arg_mode="luksOpen" ;;
esac
case $DECRYPT_TYPE in
	"keyfile" ) cryptsetup_arg_keyfile="--key-file=$KEYFILE" ;;
	"" ) cryptsetup_arg_keyfile="" ;;
esac
case $USE_LUKSHEADER in
	"" ) cryptsetup_arg_luksheader="" ;;
	* ) cryptsetup_arg_luksheader="--header=$LUKS_HEADER" ;;	
esac		
}

# attach
unlockDisk() {
msg_head "$DEVICE -> /dev/mapper/$MAPPER_NAME -> $MOUNTPOINT"
echo
if [ "$USE_NBD" == "yes" ]; then
	if ! cat /proc/modules | awk '{ print $1 }' | grep -q nbd ;  then
		info "nbd kernel module is not loaded, loading it now"
		sudo modprobe nbd
	fi
	[ ! "$(nbd-client -c $DEVICE)" == "" ] && { lsblk $DEVICE; echo; echo "Device $DEVICE is till in use, exiting..."; exit 1;}
	echo "Creating local port forward at port $NBD_PORT"
	ssh -fN -L $NBD_PORT:127.0.0.1:$NBD_PORT $NBD_SSH_USER@$NBD_HOST
	echo "Mapping NBD to $DEVICE"
	sudo nbd-client 127.0.0.1 $NBD_PORT $DEVICE -systemd-mark -persist -name $NBD_EXPORT_NAME && succeed "Mapped $NBD_EXPORT_NAME from $NBD_HOST:$NBD_PORT to $DEVICE"
fi
case $PASSPHRASE in
	"" ) $( sudo cryptsetup $cryptsetup_arg_mode $DEVICE $cryptsetup_arg_luksheader $cryptsetup_arg_keyfile $MAPPER_NAME ) ;;
	* ) $( echo $PASSPHRASE | sudo cryptsetup $cryptsetup_arg_mode $DEVICE $cryptsetup_arg_luksheader $MAPPER_NAME ) ;;
esac
if ! df | grep -q /dev/mapper/$MAPPER_NAME ; then
	sudo mount /dev/mapper/$MAPPER_NAME $MOUNTPOINT
	else
	fail "There is an error decrypting $DEVICE or mapping to /dev/mapper/$MAPPER_NAME"
fi
echo
df -h /dev/mapper/$MAPPER_NAME
}

# detach
relockDisk() {
	if df | grep -q /dev/mapper/$MAPPER_NAME; then
		info "syncing..."
		sync
		sudo umount $MOUNTPOINT
		info "Device /dev/mapper/$MAPPER_NAME umounted"
	else
		info "Device /dev/mapper/$MAPPER_NAME wasn't mounted!"
	fi
	if [ -b /dev/mapper/$MAPPER_NAME ]; then
		sudo cryptsetup close $MAPPER_NAME
		info "Device /dev/mapper/$MAPPER_NAME re-locked"
	fi
[ "$USE_NBD" == "yes" ] && { sudo nbd-client -d $DEVICE; info "Disconnected network block device at $DEVICE"; }
[ "$USE_LVM" == "yes" ] && { sudo vgchange -an $LVM_VG >/dev/null; sudo udisksctl power-off -b $DISK_SDX; info "Storage device has been powered off! You can safely remove the device" ; }
}


##### START! #####
case "$1" in
	"hbu" ) importHBUvars ;;
	"nbu" ) importNBUvars ;;
	* )
		fail "Invalid device" ;
		showSyntax ;;
esac

checkDiskConnected
setCryptsetupArgs

[ ! -d $MOUNTPOINT ] && { info "mountpoint at $MOUNTPOINT doesn't exist, creating $MOUNTPOINT"; sudo mkdir $MOUNTPOINT; }

case "$2" in
	"attach" )
		unlockDisk ;;
	"detach" )
		relockDisk ;;
	* )
		fail "Invalid operation" ;
		showSyntax ;;
esac

sync
