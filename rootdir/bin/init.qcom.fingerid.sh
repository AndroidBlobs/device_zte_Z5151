#! /vendor/bin/sh


# add for fingerprint
# ZTE_FINGERPRINT_DEFAULT_FPC
default_fpc_chip=`getprop ro.feature.zte_fingerprint_default_fpc`
# ZTE_FINGERPRINT_DEFAULT_SILEAD
default_silead_chip=`getprop ro.feature.zte_fingerprint_default_silead`
if [ "$default_fpc_chip" = "1" ]; then
    default_chip="fpc1028"
elif [ "$default_silead_chip" = "1" ]; then
    default_chip="silead"
else
    default_chip="goodix"
fi

finger_id=`cat /sys/module/zte_misc/parameters/fingerprint_hw`
if [ "$finger_id" = "128" ]; then
    setprop ro.hardware.fingerprint "silead"
elif [ "$finger_id" = "5" ] || [ "$finger_id" = "4" ]; then
    setprop ro.hardware.fingerprint "gf3238"
elif [ "$finger_id" = "32" ]; then
    setprop ro.hardware.fingerprint "synafp"
elif [ "$finger_id" = "64" ]; then
    setprop ro.hardware.fingerprint "fpc"
elif [ "$finger_id" = "65" ]; then
    setprop ro.hardware.fingerprint "fpc1028"
else
    setprop ro.hardware.fingerprint $default_chip
fi
# end to add for fingerprint