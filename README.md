# 华为P10支持KernelSU自定义内核EMUI 8版本  
***
特性：
 1. 基于原本的Proto Kernel的所有特性(除了Wireguard)。
 2. 支持KernelSU
 3. 不能切换SELinux为强制模式。(强制为宽容模式。)
 4. 完全屏蔽华为内核级别ROOT检查和扫描。  
***
# 自行构建：  
需求：  
 1. Ubuntu 16.04 x86_64 / Ubuntu 20.04 x86_64
 2. 8GB RAM[最低] / 16GB RAM[推荐]
 3. 64GB 或更多 硬盘空间
 4. 克隆本仓库，Proto文件夹是内核，gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu是交叉编译器，克隆命令：
 > `https://github.com/Coconutat/android_kernel_huawei_vtr_KernelSU.git`  
 1. 安装依赖：
 > `sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libwxgtk3.0-dev adb fastboot`
 1. 在`Build_KSU.sh`脚本里填写好交叉编译器的路径。(内有注释, 交叉编译器在本仓库里提供。)
 2. 开始编译，命令：`bash Build_KSU.sh`
***
# 缺点/求助，如果能有大佬对这些问题有能力修正，请不吝赐教，感激不尽。
1. 不幸的是，这个内核不能切换SELinux的工作状态。如果切换就会导致KernelSU失效。所以我修改了/security/selinux/selinuxfs.c，在171行到174行添加了一些代码。
2. SD卡无法读取，该说这个通用的问题么？我编译官方内核也是读取不了SD卡。刷回华为OTA包里就可以。
3. GSI镜像将不再可用。不知为何，以前支持能开机可用的GSI系统也无法开机了，只能用原本的系统。
  > 什么是GSI：[WIKI](https://github.com/phhusson/treble_experimentations/wiki/Frequently-Asked-Questions-%28FAQ%29)
  > GSI镜像列表：[LIST](https://github.com/phhusson/treble_experimentations/wiki/Generic-System-Image-%28GSI%29-list)
***
# 创建者/贡献者：
[JBolho](https://github.com/JBolho) / [Proto内核](https://github.com/JBolho/Proto)：提供了基础的内核。  
[麦麦观饭](https://github.com/maimaiguanfan) / [麒麟盘古内核](https://github.com/maimaiguanfan/android_kernel_huawei_hi3660/)：提供了一键式编译脚本和研究内核参考。  
[aaron74xda](https://github.com/aaron74xda) / [android_kernel_huawei_hi3660
](https://github.com/aaron74xda/android_kernel_huawei_hi3660):启发了我对于EMUI 8内核的强制SElinux宽容的具体思路。  
[术哥](https://github.com/tiann) / [KernelSU](https://github.com/tiann)：开发了牛逼闪闪的各种炫酷东东的大佬。没有他就没有KernelSU。感谢他在我折腾华为内核期间给予的帮助。  