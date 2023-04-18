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
export PATH=$PATH:/home/coconutat/Downloads/Github/android_kernel_huawei_vtr_KernelSU/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu/bin

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

#构建P10部分
echo "***Building for P10 version...***"
make ARCH=arm64 O=out $EV merge_hi3660_P10_KSU_defconfig
make ARCH=arm64 O=out $EV -j128

#打包P10版内核
if [ -f out/arch/arm64/boot/Image.gz ];
then
	echo "***Packing P10 version kernel...***"
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 initcall_debug=n page_tracker=on slub_min_objects=16 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user" --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 8.0.0 --os_patch_level 2018-01-01  --output Proto_V"$v"_8.0_P10.img
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 initcall_debug=n page_tracker=on slub_min_objects=16 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=permissive buildvariant=user" --tags_offset 0x07A00000 --kernel_offset 0x00080000 --ramdisk_offset 0x07c00000 --os_version 8.0.0 --os_patch_level 2018-01-01  --output Proto_V"$v"_8.0_P10.img
	cp out/arch/arm64/boot/Image.gz Image.gz
	cd tools/Proto8_Anykernel
	cp out/arch/arm64/boot/Image.gz tools/Proto8_Anykernel/Image.gz
	zip -r9 P10_V"$v"_8.0_P10.zip * > /dev/null
	cd ../..
	mv tools/Proto8_Anykernel/P10_V"$v"_8.0_P10.zip Proto8_Huawei_Kernel_V"$v"_8.0_P10.zip
	rm -rf tools/Proto8_Anykernel/Image.gz
	echo " "
	echo "***Sucessfully built P10 version kernel...***"
	echo " "
else
	echo " "
	echo "***Failed!***"
fi

# 清理每次同步KernelSU产生的软链接
if [ -d drivers/kernelsu ];
then
    echo "Find softlink kernelsu,will remove it"
	rm -rf drivers/kernelsu
	exit 0
else
	echo "No softlink kernelsu,good."
	exit 0
fi