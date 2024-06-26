#!/usr/bin/env bash

cd `dirname $0`
source params

QEMU="../qemu/build/qemu-system-arm"
if [ ! -f linux/uImage ]; then
  echo "Cannot find kernel, run ./get_linux.sh first!"
  exit 1
fi

if [ "$1" == "not_build" ]; then
    QEMU="qemu-system-arm"
fi

if [ ! -f ../qemu/build/qemu-system-arm ] && [ $QEMU == "../qemu/build/qemu-system-arm" ]; then
    echo "No qemu-system-arm has been built, read the README"
    exit 1
fi

# TODO: Figure out how to forward mDNS port 5353 without breaking avahi
$QEMU \
  -machine xilinx-zynq-a9 -cpu cortex-a9 -m $RAM_SIZE \
  -kernel linux/uImage -dtb linux/devicetree.dtb \
  -display none -serial null -serial mon:stdio \
  -append "-rtc base=localtime,clock=vm -icount shift=7,align=off,sleep=off init=/sbin/init console=ttyPS0,115200 earlyprintk root=/dev/mmcblk0 rw" \
  -net user,hostfwd=tcp::${LOCAL_SSH_PORT}-:22,hostfwd=tcp::1741-:1741,hostfwd=tcp::1742-:1742,hostfwd=udp::1164-:1164,hostfwd=udp::1166-:1166 \
  -net nic \
  -sd "$IMG_FILE"

# TODO: how to safely shutdown the system?
