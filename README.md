# ADB实用命令
提供一些快捷的adb指令, 适用于 MacOS / Linux 环境.

### 配置说明:
1. ``` mkdir -p ~/.script_clone ```
2. ``` git clone git@github.com:youthyJJ/xm-script.git ~/.script_clone ```
3. ``` sudo mkdir -p /usr/local/script ```
4. ``` sudo mv ~/.script_clone/xm /usr/local/script/xm ```
5. ``` sudo chmod 555 /usr/local/script/xm ```
6. ``` sudo echo 'PATH=$PATH:/usr/local/script/xm'>>/etc/profile ```
7. ``` source /etc/profile ```
8. ``` rm -r ~/.script_clone ```

### 脚本功能:
- __xm top__ : 监听当前设备的顶部Activity
- __xm rn__ : 查询当前设备上正在运行的Activity
- __xm ua keyword__ : 卸载包名包含关键字的应用
- __xm k/kill keyword__ : 结束包名包含关键字的应用进程
- __xm rk/rkill keyword__ : (Root)结束包名包含关键字的应用进程