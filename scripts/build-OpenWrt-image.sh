#!/bin/bash


export profile="xiaomi_redmi-router-ac2100"
export version="22.03.5"
export target="ramips"
export subtarget="mt7621"
export include_dir="include.d"
export manifest_file="openwrt-${version}-${target}-${subtarget}.manifest"

export manifest_packages=`cat ${manifest_file} | cut -d ' ' -f1`
export extra_packages="adb adblock attr collectd coreutils coreutils-base64 coreutils-sort curl etherwake htop iw \
logd luci-app-adblock luci-app-nlbwmon luci-app-wol luci-app-statistics luci-theme-material msmtp nano nmap \
openssh-sftp-server rsync samba4-admin shadow-useradd \
"
export packages=`echo ${manifest_packages} ${extra_packages} | tr ' ' '\n' | sort -u | uniq | tr '\n' ' ' `

mkdir -p ${include_dir}/etc/build-info.d/
cd ${include_dir}/
find . -type l -o -type f -o -type d > etc/build-info.d/included_files.txt
echo "${manifest_packages}" > etc/build-info.d/manifest_packages.txt
echo "${extra_packages}" > etc/build-info.d/extra_packages.txt
cd ..

cd openwrt-imagebuilder-${version}-${target}-${subtarget}.Linux-x86_64
mkdir -p tmp
make image PROFILE="${profile}" PACKAGES="${packages}" FILES="../${include_dir}"

cp ../openwrt-imagebuilder-${version}-${target}-${subtarget}.Linux-x86_64/build_dir/target-mipsel_24kc_musl/linux-${target}_${subtarget}/tmp/openwrt-${version}-${target}-${subtarget}-${profile}-squashfs-sysupgrade.bin ..
