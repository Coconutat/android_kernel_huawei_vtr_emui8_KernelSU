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
export PATH=$PATH:

export CROSS_COMPILE=aarch64-linux-gnu-
export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi

#添加或更新AK3

if [ -f tools/AnyKernel3/README.md ];
then
	cd tools/AnyKernel3
	echo " "
	echo "***Updating AnyKernel3...***"
	echo " "
	git pull upstream master
else
	echo " "
	echo "***Adding AnyKernel3...***"
	echo " "
	git submodule update --init --recursive
	cd tools/AnyKernel3
	git remote add upstream https://github.com/osm0sis/AnyKernel3
	echo "***Updating AnyKernel3...***"
	echo " "
	git pull upstream master
fi
cd ../..
echo " "

#输入内核版本号
printf "输入P10内核的版本号,输入完成后按下回车: "
read v
echo " "
echo "Setting EXTRAVERSION"
export EV=EXTRAVERSION=_P10_V$v

#构建P10部分
echo "***Building for P10 version...***"
make ARCH=arm64 O=out $EV merge_hi3660_P10_KSU_defconfig
make ARCH=arm64 O=out $EV -j128

#打包P10版内核
if [ -f out/arch/arm64/boot/Image.gz ];
then
	echo "***Packing P10 version kernel...***"
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x00078000 --cmdline "lloglevel=4 initcall_debug=n page_tracker=on slub_min_objects=16 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=permissive buildvariant=userdebug" --tags_offset 0x07988000 --kernel_offset 0x00008000 --ramdisk_offset 0x07b88000 --header_version 0 --os_version 8.0.0 --os_patch_level 2019-01  --output Huawei_Kernel_V"$v"_8.0_P10_PM.img
	mv out/arch/arm64/boot/Image.gz tools/AnyKernel3/Image.gz
	cd tools/AnyKernel3
	zip -r9 P10_V"$v"_8.0_P10.zip * > /dev/null
	cd ../..
	mv tools/AnyKernel3/P10_V"$v"_8.0_P10.zip Huawei_Kernel_V"$v"_8.0_P10.zip
	rm -rf tools/AnyKernel3/Image.gz
	echo " "
	echo "***Sucessfully built P10 version kernel...***"
	echo " "
else
	echo " "
	echo "***Failed!***"
	exit 0
fi

