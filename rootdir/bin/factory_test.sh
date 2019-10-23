#!/vendor/bin/sh
slFPProp='sys.service.silead'
slFPTestProp='debug.synafp.senortest'
slFPFupProp='debug.synafp.fingerup'
slFPFDownProp='debug.synafp.fingerdown'

setprop "$slFPTestProp" -1
setprop "$slFPFupProp" 0
setprop "$slFPFDownProp" 0

setSlFPSvc()
{
    slFPSvcP=`getprop '$slFPProp'`
    #  get the function argument
    if [ '' = "$1" ]; then
        echo "$slFPSvcP"
        return 1
    elif [ 'enable' = $1 ]; then
        echo 'setSlFPSvc enable fpsvcd'
        reTry=0
        slFPSvc=`ps -A | grep -is fpsvcd`
        while [ "$slFPSvc" = '' ]; do
            if [ "$reTry" = '50' ]; then
                echo 'start silead fingerprint service failed!!!'
                return 1
            fi
            setprop "$slFPProp" enabled
            let reTry+=1
            sleep 0.1
            slFPSvc=`ps -A | grep -is fpsvcd`
        done
    elif [ 'disable' = "$1" ]; then
        echo 'setSlFPSvc disable fpsvcd'
        reTry=0
        slFPSvc=`ps -A | grep -is fpsvcd`
        while [ "$slFPSvc" != '' ]; do
            if [ "$reTry" = '50' ]; then
                echo 'stop silead fingerprint service failed!!!'
                return 1
            fi
            setprop "$slFPProp" disabled
            let reTry+=1
            sleep 0.1
            slFPSvc=`ps -A | grep -is fpsvcd`
        done
    else
        echo 'illegal arguments!'
        return 1
    fi
        return 0
}

delResult()
{
    rSpiTest=-1
    rDeadPixel=-1
    while read line; do
        if [ "$rSpiTest" = '1' ] && [ "$rDeadPixel" = '1' ]; then
                if [ -z "${line#SLFPTestResult: finger_state_test down}" ]; then
                    pDown=`getprop "$slFPFDownProp"`
                    echo "$pDown" | grep -sE "^[0-9]+$"
                    if [ $? != '0' ]; then
                        pDown=0
                    fi
                    let pDown+=1
                    setprop "$slFPFDownProp" "$pDown"
                    elif [ -z "${line#SLFPTestResult: finger_state_test up}" ]; then
                        pUp=`getprop "$slFPFupProp"`
                        echo "$pUp" | grep -sE "^[0-9]+$"
                        if [ $? != '0' ]; then
                            pUp=0
                        fi
                        let pUp+=1
                        setprop "$slFPFupProp" "$pUp"
                    fi
                elif [ -z "${line#SLFPTestResult: spi_test --> PASSED}" ]; then
                    rSpiTest=1
                    if [ "$rSpiTest" = '1' ] && [ "$rDeadPixel" = '1' ]; then
                        setprop "$slFPTestProp" 1
                    fi
                elif [ -z "${line#SLFPTestResult: spi_test --> FAILED}" ]; then
                    rSpiTest=0
                    setprop "$slFPTestProp" 0
                    /vendor/bin/factorytoold_cmd -k
                    if [ '0' != $? ]; then
                        echo 'restart silead fingerprint service failed!!!'
                    fi
                    exit 1
                elif [ -z "${line#SLFPTestResult: deadpixel_test --> PASSED}" ]; then
                    rDeadPixel=1
                    if [[ "$rSpiTest" = '1' ]] && [[ "$rDeadPixel" = '1' ]]; then
                        setprop "$slFPTestProp" 1
                    fi
                elif [ -z "${line#SLFPTestResult: deadpixel_test --> FAILED}" ]; then
                    rDeadPixel=0
                    setprop "$slFPTestProp" 0
                    /vendor/bin/factorytoold_cmd -k
                    if [ '0' != $? ]; then
                        echo 'restart silead fingerprint service failed!!!'
                    fi
                    exit 1
                 fi
    done
}

setSlFPSvc disable
if [ '0' != $? ]; then
    echo 'stop silead fingerprint service failed!!! exit test cases'
    setSlFPSvc enable
    exit -1
fi

# check fatory test deamon - fatorytoold service
ps -A | grep -is factorytoold
if [ '0' != $? ]; then
    echo "can't find fatory test deamon - fatorytoold service!!! exit test cases"
    setSlFPSvc enable
    exit -1
fi

/vendor/bin/factorytoold_cmd -s 0 -p -S 0 2>&1 >/dev/null | delResult

setSlFPSvc enable
if [ '0' != $? ]; then
    echo 'restart silead fingerprint service failed!!!'
    exit -1
fi
