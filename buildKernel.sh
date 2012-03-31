#!/bin/bash

# Copyright (C) 2011 Twisted Playground

# This script is designed to compliment .bash_profile code to automate the build process by adding a typical shell command such as:
# function buildKernel { echo "Ace, Mecha, Sholes, Release?"; read device; cd /Volumes/android/android-tzb_ics4.0.1/kernel;  ./buildChosenKernel.sh $device; }
# This script is designed by Twisted Playground for use on MacOSX 10.7 but can be modified for other distributions of Mac and Linux

PROPER=`echo $2 | sed 's/\([a-z]\)\([a-zA-Z0-9]*\)/\u\1\2/g'`

HANDLE=TwistedZero
KERNELSPEC=/Volumes/android/htc-kernel-msm7x30
ANDROIDREPO=/Volumes/android/Twisted-Playground
TOOLCHAINDIR=/Volumes/android/android-tzb_ics4.0.1/prebuilt/darwin-x86/toolchain/arm-eabi-4.4.0/bin
DROIDGITHUB=TwistedUmbrella/Twisted-Playground.git
SPADEREPO=/Volumes/android/github-aosp_source/android_device_htc_ace
SPADEGITHUB=ThePlayground/android_device_htc_ace.git
zipfile=$HANDLE"_Andromadus-hijack_ICS.zip"

CPU_JOB_NUM=16
TOOLCHAIN_PREFIX=$TOOLCHAINDIR/arm-eabi-

echo "Config Name? "
ls config
read configfile
cp -R config/$configfile .config

make clean -j$CPU_JOB_NUM

make -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN_PREFIX

find . -name "*.ko" | xargs ${TOOLCHAIN_PREFIX}strip --strip-unneeded

if [ "$2" == "ace" ]; then

echo "adding to build"

cp -R arch/arm/boot/zImage $SPADEREPO/kernel/kernel
for j in $(find . -name "*.ko"); do
cp "${j}" $SPADEREPO/kernel/lib/modules
done

if [ -e arch/arm/boot/zImage ]; then
cd $SHOOTREPO
git commit -a -m "Automated Kernel Update - ${PROPER}"
git push git@github.com:$SHOOTGITHUB HEAD:ics -f
fi

else

rm -fr tmpdir
mkdir tmpdir
cp arch/arm/boot/zImage tmpdir/
for j in $(find . -name "*.ko"); do
    cp "${j}" tmpdir/
done

cp -a anykernel.tpl tmpdir/anykernel
mkdir -p tmpdir/anykernel/kernel
mkdir -p tmpdir/anykernel/system/lib/modules
cp tmpdir/zImage tmpdir/anykernel/kernel
for j in tmpdir/*.ko; do
    cp "${j}" tmpdir/anykernel/system/lib/modules/
done

if [ -e arch/arm/boot/zImage ]; then
echo "making zip file"
cd tmpdir/anykernel
zip -r $zipfile *
cp -R $zipfile $ANDROIDREPO/Kernel/$zipfile
cd ../../
rm -fr tmpdir
cd $ANDROIDREPO
git checkout gh-pages
git commit -a -m "Automated Patch Kernel Build - ${PROPER}"
git push git@github.com:$DROIDGITHUB HEAD:ics -f
fi

fi

cd $KERNELSPEC