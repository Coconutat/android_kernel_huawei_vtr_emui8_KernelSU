#!/bin/bash
#设置环境

# Special Clean For Huawei EMUI 8.0 Kernel.
if [ -d include/config ];
then
    echo "Find config,will remove it"
	rm -rf include/config
else
	echo "No Config,good."
fi


echo " "
echo "***Setting environment...***"
rm -rf out/arch/arm64/boot/Image.gz

# 交叉编译器的路径
export PATH=$PATH:$(pwd)/../../TOOLS/ToolChains/bin
export CROSS_COMPILE=aarch64-linux-gnu-
export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi

#输入内核版本号
printf "输入P10内核的版本号,输入完成后按下回车: "
read v
echo " "
echo "Setting EXTRAVERSION"
export EV=EXTRAVERSION=_Proto_P10_V$v

start_time=$(date +%Y.%m.%d-%I_%M)

start_time_sum=$(date +%s)

#构建P10部分
echo "***Building for P10 version...***"
make ARCH=arm64 O=out $EV Proto_P10_KSU_reg_defconfig
make ARCH=arm64 O=out $EV -j128  2>&1 | tee kernel_log-${start_time}.txt

end_time_sum=$(date +%s)

end_time=$(date +%Y.%m.%d-%I_%M)

# 计算运行时间（秒）
duration=$((end_time_sum - start_time_sum))

# 将秒数转化为 "小时:分钟:秒" 形式输出
hours=$((duration / 3600))
minutes=$(( (duration % 3600) / 60 ))
seconds=$((duration % 60))

# 打印运行时间
echo "脚本运行时间为：${hours}小时 ${minutes}分钟 ${seconds}秒"

#打包P10版内核
if [ -f out/arch/arm64/boot/Image.gz ];
then
	echo "***Packing P10 version kernel...***"
	cp out/arch/arm64/boot/Image.gz Image.gz
	cp out/arch/arm64/boot/Image.gz tools/Proto8_Anykernel/Image.gz
	cd tools/Proto8_Anykernel
	zip -r9 P10_V"$v"_8.0_P10.zip * > /dev/null
	cd ../..
	mv tools/Proto8_Anykernel/P10_V"$v"_8.0_P10.zip Proto8_Huawei_Kernel_V"$v"_8.0_P10-${end_time}.zip
	rm -rf tools/Proto8_Anykernel/Image.gz
	echo " "
	echo "***Sucessfully built P10 version kernel...***"
	echo " "
else
	echo " "
	echo "***Failed!***"
fi