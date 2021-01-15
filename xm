#!/usr/bin/env bash
XM_LOG=":xm~"
COMMAND_MANUAL="命令列表
  \033[36mtop\033[0m \t\t\t监听当前设备的顶部Activity;
  \033[36mrn\033[0m \t\t\t查询当前设备上正在运行的Activity;
  \033[36mua\033[0m \033[32mkeyword\033[0m \t\t卸载包名包含关键字的应用;
  \033[36mk/kill\033[0m \033[32mkeyword\033[0m \t结束包名包含关键字的应用进程;
  \033[36mrk/rkill\033[0m \033[32mkeyword\033[0m \t[Root]结束包名包含关键字的应用进程;
  \033[36mq\033[0m \033[32mkeyword\033[0m \t\t查询包名包含关键字的应用程序;
  \033[36mp\033[0m \033[32mkeyword\033[0m \t\t查询包名包含关键字的应用程序的安装位置;
  \033[36msa\033[0m \033[32mkeyword\033[0m \t\t启动包名包含关键字的应用程序;"

cmd=$1
parm1=$2
parm2=$3
parm3=$4
parm4=$5
parm5=$6

function isNull() {
  if test -z "$1"; then
    return 0
  else
    return 1
  fi
}

function pickCommand() {
  cmd=$1
  if isNull "$cmd"; then
    echo -e "$COMMAND_MANUAL"
    return 255

  elif [ "$cmd" == "ua" ]; then
    return 1

  elif [ "$cmd" == "k" ] ||
    [ "$cmd" == "kill" ]; then
    return 2

  elif [ "$cmd" == "rk" ] ||
    [ "$cmd" == "rkill" ]; then
    return 3

  elif [ "$cmd" == "top" ]; then
    return 4

  elif [ "$cmd" == "rn" ]; then
    return 5

  elif [ "$cmd" == "q" ]; then
    return 6

  elif [ "$cmd" == "p" ]; then
    return 7

  elif [ "$cmd" == "sa" ]; then
    return 8

  else
    echo "[ Command [ $cmd ] not matched ]"
    echo -e "$COMMAND_MANUAL"
    return 255
  fi
}

pickCommand "$cmd"
cmdCode=$?

# ua 卸载包名包含关键字的应用
if [ $cmdCode -eq 1 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入关键字\033[0m"
  else
    adb shell pm list packages | grep "$parm1" | sed 's/^package://' | while read -r package; do
      echo -e "uninstalling \033[32m[ $package ]\033[0m"
      eval "adb uninstall $package"
    done
  fi

# k/kill 结束包名包含关键字的应用进程
elif [ $cmdCode -eq 2 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入关键字\033[0m"
  else
    component=$(adb shell dumpsys activity activities | grep -E "Run #.*" | awk '{print $5}' | grep "$parm1" | awk -F"/" '{print $1}')
    echo -e "killing \033[32m[ $component ]\033[0m"
    adb shell am force-stop "$component"
  fi

# rk/rkill (Root)结束包名包含关键字的应用进程
elif [ $cmdCode -eq 3 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入关键字\033[0m"
  else
    adb shell ps -A | grep "$parm1" | awk '{print $2}' | while read -r pid; do
      echo -e "killing \033[32m[ $pid ]\033[0m"
      eval $(adb shell kill "$pid")
    done
  fi

# top 监听当前设备的顶部Activity
elif [ $cmdCode -eq 4 ]; then
  while true; do
    adb shell dumpsys activity activities | grep mResumedActivity | awk '{print $4}' |grep -E "/"
    sleep 1
  done

# rn 查询当前设备上正在运行的Activity
elif [ $cmdCode -eq 5 ]; then
  adb shell dumpsys activity activities | grep -E "Run #.*" | awk '{print $5}'

# q 查询包名包含关键字的应用程序
elif [ $cmdCode -eq 6 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入关键字\033[0m"
  else
    adb shell pm list packages | grep "$parm1" | sed 's/^package://'
  fi

# p 查询包名包含关键字的应用程序的安装位置
elif [ $cmdCode -eq 7 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入关键字\033[0m"
  else
    adb shell pm list packages -f | grep "$parm1" | sed 's/^package://'
  fi

# sa 启动包名包含关键字的应用程序
elif [ $cmdCode -eq 8 ]; then
    if [ ! "$parm1" ]; then
        echo -e "> \033[31m请输入关键字\033[0m"
    else
        array=($(adb shell pm list packages |grep "$parm1" |sed 's/^package://'))
        if [ ${#array[@]} -eq 0 ]; then
            echo -e "> \033[31m没有有效的包!\033[0m"
        elif [ ${#array[@]} -eq 1 ]; then
            echo -e "> \033[36m启动\033[0m\t${array[0]}"
            adb shell am start -n $(adb shell dumpsys package "${array[input]}" |grep -A 1 "android.intent.action.MAIN:" |tail -n 1 |awk '{print $2}')
        else
            for(( i=0;i<${#array[@]};i++)) do
            echo -e " \033[32m$i\033[0m\t${array[i]}";
            done;
            echo -e "> 请选择需要启动的应用\033[36m[默认:0]\033[0m:";
            read input
            if [ ! "$input" ]; then
                echo -e "> \033[36m启动\033[0m\t${array[0]}"
                adb shell am start -n $(adb shell dumpsys package "${array[input]}" |grep -A 1 "android.intent.action.MAIN:" |tail -n 1 |awk '{print $2}')
            elif [ "$input" -lt ${#array[@]} ]; then
                echo -e "> \033[36m启动\033[0m\t${array[input]}"
                adb shell am start -n $(adb shell dumpsys package "${array[input]}" |grep -A 1 "android.intent.action.MAIN:" |tail -n 1 |awk '{print $2}')
            else
                echo -e "> \033[31m超过有效数值!\033[0m"
            fi
        fi
    fi

fi