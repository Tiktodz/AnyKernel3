# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
kernel.for=KernelForDriver
kernel.compiler=SDPG
kernel.made=dotkit @fakedotkit
kernel.version=44xxx
kernel.type=xxx
message.word=blablabla
build.date=2077
build.type=stable
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=X01BD
device.name2=X01BDA
device.name3=Zenfone Max Pro M2 (X01BD)
device.name4=ASUS_X01BD
device.name5=ASUS_X01BDA
supported.versions=9-14
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# Installation Method
X00TD=0

# shell variables
if [ "$X00TD" = "1" ];then
BLOCK=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
else
BLOCK=/dev/block/bootdevice/by-name/boot;
fi
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

# Mount partitions as rw
mount /system;
mount /vendor;
mount -o remount,rw /system;
mount -o remount,rw /vendor;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
if [ "$X00TD" = "1" ];then
chmod -R 750 $RAMDISK/*;
chmod -R 755 $RAMDISK/sbin;
chmod -R root:root $RAMDISK/*;
else
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 755 755 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes
fi


## AnyKernel install
dump_boot;

# Check if boot img has Magisk Patched
cd $split_img;
if [ ! "$magisk_patched" ]; then
  $bin/magiskboot cpio ramdisk.cpio test;
  magisk_patched=$?;
fi;
if [ $((magisk_patched & 3)) -eq 1 ]; then
	if [ "$REG" = "IDN" ];then
	ui_print "! Magisk Terdeteksi, Tidak Perlu Menginstall Magisk lagi !";
	elif [ "$REG" = "EN" ];then
	ui_print "! Magisk Detected, U don't need to reinstall Magisk !";
	fi;
	WITHMAGISK=Y
fi;
cd $home

# begin ramdisk changes

# activate New Novatek Touchscreen Driver by boot cmdline
patch_cmdline use_new_nvtouch use_new_nvtouch=0

#Remove old kernel stuffs from ramdisk
if [ "$X00TD" = "1" ];then
 rm -rf $RAMDISK/init.special_power.sh
 rm -rf $RAMDISK/init.darkonah.rc
 rm -rf $RAMDISK/init.spectrum.rc
 rm -rf $RAMDISK/init.spectrum.sh
 rm -rf $RAMDISK/init.boost.rc
 rm -rf $RAMDISK/init.trb.rc
 rm -rf $RAMDISK/init.azure.rc
 rm -rf $RAMDISK/init.PBH.rc
 rm -rf $RAMDISK/init.Pbh.rc
 rm -rf $RAMDISK/init.overdose.rc
fi

backup_file init.rc;
if [ "$X00TD" = "1" ];then
	remove_line init.rc "import /init.darkonah.rc";
	remove_line init.rc "import /init.spectrum.rc";
	remove_line init.rc "import /init.boost.rc";
	remove_line init.rc "import /init.trb.rc"
	remove_line init.rc "import /init.azure.rc"
	remove_line init.rc "import /init.PbH.rc"
	remove_line init.rc "import /init.Pbh.rc"
	remove_line init.rc "import /init.overdose.rc"
else
	replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";
	
	# init.tuna.rc
	backup_file init.tuna.rc;
	insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
	append_file init.tuna.rc "bootscript" init.tuna;
	
	# fstab.tuna
	backup_file fstab.tuna;
	patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
	patch_fstab fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
	patch_fstab fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
	append_file fstab.tuna "usbdisk" fstab;

# remove spectrum profile
	if [ -e $RAMDISK/init.spectrum.rc ];then
	  rm -rf $RAMDISK/init.spectrum.rc
	  ui_print "delete /init.spectrum.rc"
	fi
	if [ -e $RAMDISK/init.spectrum.sh ];then
	  rm -rf $RAMDISK/init.spectrum.sh
	  ui_print "delete /init.spectrum.sh"
	fi
	if [ -e $RAMDISK/sbin/init.spectrum.rc ];then
	  rm -rf $RAMDISK/sbin/init.spectrum.rc
	  ui_print "delete /sbin/init.spectrum.rc"
	fi
	if [ -e $RAMDISK/sbin/init.spectrum.sh ];then
	  rm -rf $RAMDISK/sbin/init.spectrum.sh
	  ui_print "delete /sbin/init.spectrum.sh"
	fi
	if [ -e $RAMDISK/etc/init.spectrum.rc ];then
	  rm -rf $RAMDISK/etc/init.spectrum.rc
	  ui_print "delete /etc/init.spectrum.rc"
	fi
	if [ -e $RAMDISK/etc/init.spectrum.sh ];then
	  rm -rf $RAMDISK/etc/init.spectrum.sh
	  ui_print "delete /etc/init.spectrum.sh"
	fi
	if [ -e $RAMDISK/init.aurora.rc ];then
	  rm -rf $RAMDISK/init.aurora.rc
	  ui_print "delete /init.aurora.rc"
	fi
	if [ -e $RAMDISK/sbin/init.aurora.rc ];then
	  rm -rf $RAMDISK/sbin/init.aurora.rc
	  ui_print "delete /sbin/init.aurora.rc"
	fi
	if [ -e $RAMDISK/etc/init.aurora.rc ];then
	  rm -rf $RAMDISK/etc/init.aurora.rc
	  ui_print "delete /etc/init.aurora.rc"
	fi
fi

# rearm perfboostsconfig.xml
if [ ! -f /vendor/etc/perf/perfboostsconfig.xml ]; then
	mv /vendor/etc/perf/perfboostsconfig.xml.bak /vendor/etc/perf/perfboostsconfig.xml;
	mv /vendor/etc/perf/perfboostsconfig.xml.bkp /vendor/etc/perf/perfboostsconfig.xml;
fi

# rearm commonresourceconfigs.xml
if [ ! -f /vendor/etc/perf/commonresourceconfigs.xml ]; then
	mv /vendor/etc/perf/commonresourceconfigs.xml.bak /vendor/etc/perf/commonresourceconfigs.xml;
	mv /vendor/etc/perf/commonresourceconfigs.xml.bkp /vendor/etc/perf/commonresourceconfigs.xml;
fi

# rearm targetconfig.xml
if [ ! -f /vendor/etc/perf/targetconfig.xml ]; then
	mv /vendor/etc/perf/targetconfig.xml.bak /vendor/etc/perf/targetconfig.xml;
	mv /vendor/etc/perf/targetconfig.xml.bkp /vendor/etc/perf/targetconfig.xml;
fi

# rearm targetresourceconfigs.xml
if [ ! -f /vendor/etc/perf/targetresourceconfigs.xml ]; then
	mv /vendor/etc/perf/targetresourceconfigs.xml.bak /vendor/etc/perf/targetresourceconfigs.xml;
	mv /vendor/etc/perf/targetresourceconfigs.xml.bkp /vendor/etc/perf/targetresourceconfigs.xml;
fi

# rearm powerhint.xml
if [ ! -f /vendor/etc/powerhint.xml ]; then
	mv /vendor/etc/powerhint.xml.bak /vendor/etc/powerhint.xml;
	mv /vendor/etc/powerhint.xml.bkp /vendor/etc/powerhint.xml;
fi

# Put Android Version on cmdline
# android_ver=$(file_getprop /system/build.prop ro.build.version.release);
# patch_cmdline androidboot.version androidboot.version=$android_ver

Overclock CPU & GPU
if [ "`$BB grep -w "selected.1=1" /tmp/aroma-data/refrate.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- CPU di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Overclock CPU Freq";
	fi;
	patch_cmdline overclock.cpu overclock.cpu=1
elif [ "`$BB grep -w "selected.1=2" /tmp/aroma-data/refrate.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- CPU tidak di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Use Stock CPU Freq";
	fi;
	patch_cmdline overclock.cpu overclock.cpu=0
fi;

if [ "`$BB grep -w "selected.2=1" /tmp/aroma-data/refrate.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- GPU di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Overclock GPU Freq";
	fi;
	patch_cmdline overclock.gpu overclock.gpu=1
elif [ "`$BB grep -w "selected.2=2" /tmp/aroma-data/refrate.prop`" ];then
	if [ "$REG" = "IDN" ];then
	ui_print "- GPU tidak di-Overclock";
	elif [ "$REG" = "EN" ];then
	ui_print "- Use Stock GPU Freq";
	fi;
	patch_cmdline overclock.gpu overclock.gpu=0
fi;

# end ramdisk changes

write_boot;
## end install

