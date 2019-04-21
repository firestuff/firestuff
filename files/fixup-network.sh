#!/bin/sh

case "$1" in
	start)
		rmmod tg3
		rmmod bcm5700
		modprobe bcm5700
		;;
esac
