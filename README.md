# ADB实用命令
提供一些快捷的adb指令, 适用于 MacOS / Linux 环境.

### 配置说明:
- 顺序导入:
    1. ``` rm -r ~/.script_clone ```
    2. ``` mkdir -p ~/.script_clone ```
    3. HTTPS:  
       ``` git clone https://github.com/youthyJJ/xm-script.git ~/.script_clone ```  
       SSH:  
       ``` git clone git@github.com:youthyJJ/xm-script.git ~/.script_clone ```
    4. ``` sudo mkdir -p /usr/local/script ```
    5. ``` sudo rm /usr/local/script/xm ```
    6. ``` sudo rm -r /usr/local/script/xm ```
    7. ``` sudo mv ~/.script_clone/xm /usr/local/script/xm ```
    8. ``` sudo chmod 555 /usr/local/script/xm ```
    9. ``` sudo sh -c "echo 'export PATH=$PATH:/usr/local/script' >> /etc/profile" ```
    10. ``` source /etc/profile ```

- 两行导入:  
    1. HTTPS:    
        ``` sudo sh -c "while true; do rm -r ~/.script_clone ; mkdir -p ~/.script_clone ; git clone https://github.com/youthyJJ/xm-script.git ~/.script_clone ; mkdir -p /usr/local/script ; rm -r /usr/local/script/xm ; rm /usr/local/script/xm ; mv ~/.script_clone/xm /usr/local/script/xm ; chmod 555 /usr/local/script/xm ; echo 'export PATH=$PATH:/usr/local/script' >> /etc/profile ; break ; done " ```  
        SSH:  
        ``` sudo sh -c "while true; do rm -r ~/.script_clone ; mkdir -p ~/.script_clone ; git clone git@github.com:youthyJJ/xm-script.git ~/.script_clone ; mkdir -p /usr/local/script ; rm -r /usr/local/script/xm ; rm /usr/local/script/xm ; mv ~/.script_clone/xm /usr/local/script/xm ; chmod 555 /usr/local/script/xm ; echo 'export PATH=$PATH:/usr/local/script' >> /etc/profile ; break ; done " ```
    2. ``` source /etc/profile ```

### 脚本功能:
- __xm top__ : 监听当前设备的顶部Activity
- __xm rn__ : 查询当前设备上正在运行的Activity
- __xm ua keyword__ : 卸载包名包含关键字的应用
- __xm k/kill keyword__ : 结束包名包含关键字的应用进程
- __xm rk/rkill keyword__ : (Root)结束包名包含关键字的应用进程
- __xm q keyword__ : 查询包名包含关键字的应用程序
- __xm p keyword__ : 查询包名包含关键字的应用程序的安装位置
- __xm sa keyword__ : 启动包名包含关键字的应用程序
- __xm key keyname__ : 模拟按键键盘( home / back / menu / mute / v+ / v- ), 按键过多, 如果有需要可以自行扩展, 可参考[官网](https://developer.android.com/reference/android/view/KeyEvent?hl=zh-cn)  
- __xm dev__ : 打印设备基本信息;
- __xm b__ : 模拟发送广播;