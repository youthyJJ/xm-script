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
  \033[36msa\033[0m \033[32mkeyword\033[0m \t\t启动包名包含关键字的应用程序;
  \033[36mkey\033[0m \033[32mkeyname\033[0m \t\t模拟按键键盘[ home / back / menu / mute / v+ / v- ];
  \033[36mdev\033[0m \t\t\t打印设备基本信息;
  \033[36mb\033[0m \t\t\t模拟发送广播;"

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

  elif [ "$cmd" == "key" ]; then
    return 9

  elif [ "$cmd" == "dev" ]; then
    return 10

  elif [ "$cmd" == "b" ]; then
    return 11

  else
    echo -e "\033[31m命令未找到: $cmd\033[0m"
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
    adb shell dumpsys activity activities | grep mResumedActivity | awk '{print $4}' | grep -E "/"
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
    array=($(adb shell pm list packages | grep "$parm1" | sed 's/^package://'))
    if [ ${#array[@]} -eq 0 ]; then
      echo -e "> \033[31m没有有效的包!\033[0m"
    elif [ ${#array[@]} -eq 1 ]; then
      echo -e "> \033[36m启动\033[0m\t${array[0]}"
      adb shell am start -n $(adb shell dumpsys package "${array[input]}" | grep -A 1 "android.intent.action.MAIN:" | tail -n 1 | awk '{print $2}')
    else
      for ((i = 0; i < ${#array[@]}; i++)); do
        echo -e " \033[32m$i\033[0m\t${array[i]}"
      done
      echo -e "> 请选择需要启动的应用\033[36m[默认:0]\033[0m:"
      read input
      if [ ! "$input" ]; then
        echo -e "> \033[36m启动\033[0m\t${array[0]}"
        adb shell am start -n $(adb shell dumpsys package "${array[input]}" | grep -A 1 "android.intent.action.MAIN:" | tail -n 1 | awk '{print $2}')
      elif [ "$input" -lt ${#array[@]} ]; then
        echo -e "> \033[36m启动\033[0m\t${array[input]}"
        adb shell am start -n $(adb shell dumpsys package "${array[input]}" | grep -A 1 "android.intent.action.MAIN:" | tail -n 1 | awk '{print $2}')
      else
        echo -e "> \033[31m超过有效数值!\033[0m"
      fi
    fi
  fi

# key keyname 模拟按键键盘[ home / back / menu / mute / v+ / v-]
# 按键过多, 如果有需要可以自行扩展, 参考: https://developer.android.com/reference/android/view/KeyEvent?hl=zh-cn
elif [ $cmdCode -eq 9 ]; then
  if [ ! "$parm1" ]; then
    echo -e "> \033[31m请输入按键名\033[0m \033[32m[ home / back / menu / mute / v+ / v- ]\033[0m "
  elif [ "$parm1" == "home" ]; then
    echo "Home键"
    adb shell input keyevent 3
  elif [ "$parm1" == "back" ]; then
    echo "返回键"
    adb shell input keyevent 4
  elif [ "$parm1" == "menu" ]; then
    echo "菜单键"
    adb shell input keyevent 82
  elif [ "$parm1" == "mute" ]; then
    echo "静音键"
    adb shell input keyevent 164
  elif [ "$parm1" == "v+" ]; then
    echo "音量+"
    adb shell input keyevent 24
    adb shell input keyevent 24
  elif [ "$parm1" == "v-" ]; then
    echo "音量-"
    adb shell input keyevent 25
    adb shell input keyevent 25
  else
    echo -e "> \033[31m请输入按键名\033[0m \033[32m[ home / back / menu / mute / v+ / v- ]\033[0m "
  fi

# dev 打印设备基本信息
elif [ $cmdCode -eq 10 ]; then
  size=$(adb shell wm size | tail -n 1 | awk -F": " '{print $2}')
  density=$(adb shell wm density | tail -n 1 | awk -F": " '{print $2}')
  version=$(adb shell getprop ro.build.version.release)
  api=$(adb shell getprop ro.build.version.sdk)
  echo "分辨率: $size"
  echo "像素密度: $density"
  echo "Android版本: $version(api:$api)"

# b 模拟发送广播
elif [ $cmdCode -eq 11 ]; then
  echo -n "请输入Action:"
  read action
  finalCmd="adb shell am broadcast -a $action"
  while true; do
    echo "  1: 添加extra(string)"
    echo "  2: 添加extra(int)"
    echo "  3: 添加extra(boolean)"
    echo "  4: 添加flag"
    echo "  5: 添加component"
    echo "  6: 发送广播"
    echo -n "请输入选项:"
    read input

    if [ ! "$input" ]; then
      echo "无效的选项"
      continue

    elif [ "$input" == "1" ]; then
      while true; do echo -n "extra(string) key: " ; read key_string ; if [ ! "$key_string" ]; then echo "无效的值" ; continue; fi ; break; done
      while true; do echo -n "extra(string) value: "; read value_string; if [ ! "$value_string" ]; then echo "无效的值"; continue; fi; break; done
      echo "已添加: [ $key_string = $value_string ] "
      finalCmd="$finalCmd --es $key_string $value_string"
      sleep 0.5

    elif [ "$input" == "2" ]; then
      while true; do echo -n "extra(int) key: "; read key_int; if [ ! "$key_int" ]; then echo "无效的值"; continue; fi; break; done
      while true; do echo -n "extra(int) value: "; read value_int; if [ ! "$value_int" ]; then echo "无效的值"; continue; fi; break; done
      echo "已添加: [ $key_int = $value_int ] "
      finalCmd="$finalCmd --ei $key_int $value_int"
      sleep 0.5

    elif [ "$input" == "3" ]; then
      while true; do echo -n "extra(boolean) key: "; read key_boolean; if [ ! "$key_boolean" ]; then echo "无效的值"; continue; fi; break; done
      while true; do echo -n "extra(boolean) value: "; read value_boolean; if [ ! "$value_boolean" ]; then echo "无效的值"; continue; fi; break; done
      echo "已添加: [ $key_boolean = $value_boolean ] "
      finalCmd="$finalCmd --ez $key_boolean $value_boolean"
      sleep 0.5

    elif [ "$input" == "4" ]; then
      while true; do echo -n "flag: "; read flag; if [ ! "$flag" ]; then echo "无效的值"; continue; fi; break; done
      echo "已添加: flag: $flag "
      finalCmd="$finalCmd -f $flag"
      sleep 0.5

    elif [ "$input" == "5" ]; then
      while true; do echo -n "component: "; read component; if [ ! "$component" ]; then echo "无效的值"; continue; fi; break; done
      echo "已添加: component: $component "
      finalCmd="$finalCmd -n $component"
      sleep 0.5

    elif [ "$input" == "6" ]; then
      echo "$finalCmd"
      break

    else
      echo "无效的选项"
      continue

    fi

  done

  eval "$finalCmd"

fi
