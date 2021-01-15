#!/usr/bin/env bash
XM_LOG=":xm~"
COMMAND_MANUAL="命令列表
  \033[36mtop\033[0m \t\t\t监听当前设备的顶部Activity;
  \033[36mrn\033[0m \t\t\t查询当前设备上正在运行的Activity;
  \033[36mua\033[0m \033[32mkeyword\033[0m \t\t卸载包名包含关键字的应用;
  \033[36mk/kill\033[0m \033[32mkeyword\033[0m \t结束包名包含关键字的应用进程;
  \033[36mrk/rkill\033[0m \033[32mkeyword\033[0m \t[Root]结束包名包含关键字的应用进程;"

cmd=$1
parm1=$2
parm2=$3
parm3=$4
parm4=$5
parm5=$6

function isNull() {
    if test -z $1
    then return 0
    else return 1
    fi
}

function pickCommand() {
    cmd=$1
    if isNull $cmd; then
        echo -e "$COMMAND_MANUAL"
        return 255;

    elif [ $cmd == "ua" ] ; then
        return 1;

    elif [ $cmd == "k" ] \
      || [ $cmd == "kill" ] ; then
        return 2;

    elif [ $cmd == "rk" ] \
      || [ $cmd == "rkill" ] ; then
        return 3;

    elif [ $cmd == "top" ] ; then
        return 4;

    elif [ $cmd == "rn" ] ; then
        return 5;

    else
        echo "[ Command [ $cmd ] not matched ]"
        echo -e "$COMMAND_MANUAL"
        return 255;
    fi
}

pickCommand $cmd
cmdCode=$?

if [ $cmdCode -eq 1 ]; then
  adb shell pm list packages |grep $parm1 |sed 's/^package://' |while read -r package; do echo "uninstalling [ $package ]"; eval "adb uninstall $package"; done

elif [ $cmdCode -eq 2 ]; then
  adb shell am force-stop `adb shell dumpsys activity activities|grep -E "Run #.*"|awk '{print $5}'|grep $parm1|awk -F"/" '{print $1}'`

elif [ $cmdCode -eq 3 ]; then
  adb shell ps -A |grep $parm1 |awk '{print $2}' |while read -r pid ; do echo "killing [ $pid ]" ; eval `adb shell kill $pid` ; done

elif [ $cmdCode -eq 4 ]; then
  while true ; do adb shell dumpsys activity activities |grep mResumedActivity |awk '{print $4}' ; sleep 1 ; done

elif [ $cmdCode -eq 5 ]; then
  adb shell dumpsys activity activities|grep -E "Run #.*"|awk '{print $5}'

fi