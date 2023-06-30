#!/bin/bash


export BASEDIR=~/Pixel4XL-avbroot/

export OTA_ZIP=${BASEDIR}/input/lineage-20.0-20230625-nightly-coral-signed.zip
export MAGISK_FILE=${BASEDIR}/input/Magisk-v26.1.apk
export MAGISK_PREINIT_DEVICE=userdata
export KERNELSU_BOOT_IMG=${BASEDIR}/input/pixel4xl_android13_4.14.276_v061.img

export PASSPHRASE_AVB=""
export PASSPHRASE_OTA=""
export AVB_KEYFILE=${BASEDIR}/signing-keys/avb.key
export OTA_KEYFILE=${BASEDIR}/signing-keys/ota.key
export OTA_CRT=${BASEDIR}/signing-keys/ota.crt
export MAGISK_PATCHED_OTA_ZIP=`echo ${BASEDIR}/output/$(basename -s .zip ${OTA_ZIP})_$(basename -s .apk ${MAGISK_FILE})_PATCHED.zip`
export KERNELSU_PATCHED_OTA_ZIP=`echo ${BASEDIR}/output/$(basename -s .zip ${OTA_ZIP})_$(basename -s .img ${KERNELSU_BOOT_IMG})_PATCHED.zip`

show_syntax() {
	echo "./patch-ota.sh [magisk|kernelsu]"
}

patch_with_magisk() {
	echo -e "Patching ${OTA_ZIP},\nusing ${MAGISK_FILE},\nwith pre-init device: ${MAGISK_PREINIT_DEVICE}"
	python avbroot/avbroot.py patch \
	--input ${OTA_ZIP} \
	--privkey-avb ${AVB_KEYFILE} \
	--privkey-ota ${OTA_KEYFILE} \
	--cert-ota ${OTA_CRT} \
	--magisk ${MAGISK_FILE} \
	--magisk-preinit-device ${MAGISK_PREINIT_DEVICE} \
	--clear-vbmeta-flags \
	--passphrase-avb-env-var PASSPHRASE_AVB \
	--passphrase-ota-env-var PASSPHRASE_OTA \
	--output ${MAGISK_PATCHED_OTA_ZIP}
}

patch_with_kernelsu() {
	echo -e "Patching ${OTA_ZIP},\nusing ${KERNELSU_BOOT_IMG}"
	python avbroot/avbroot.py patch \
	--input ${OTA_ZIP} \
	--privkey-avb ${AVB_KEYFILE} \
	--privkey-ota ${OTA_KEYFILE} \
	--cert-ota ${OTA_CRT} \
	--prepatched ${KERNELSU_BOOT_IMG} \
	--boot-partition @gki_kernel \
	--ignore-prepatched-compat \
	--clear-vbmeta-flags \
	--passphrase-avb-env-var PASSPHRASE_AVB \
	--passphrase-ota-env-var PASSPHRASE_OTA \
	--output ${KERNELSU_PATCHED_OTA_ZIP}
}

case "${@}" in
	"magisk")
		patch_with_magisk ;;
	"kernelsu")
		patch_with_kernelsu ;;
	*)
		show_syntax ;;
esac
