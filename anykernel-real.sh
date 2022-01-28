# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=ExampleKernel by osm0sis @ xda-developers
kernel.for=KernelForDriver
kernel.compiler=SDPG
kernel.made=Ryuuji @ItsRyuujiX
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
supported.versions=9-12
supported.patchlevels=
'; } # end properties

# Installation Method
X00TD=0

# shell variables
if [ "$X00TD" = "1" ];then
block=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
else
block=/dev/block/bootdevice/by-name/boot;
fi
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;


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
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chmod -R root:root $ramdisk/*;
else
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 755 755 $ramdisk/init* $ramdisk/sbin;
fi


## AnyKernel install
dump_boot;

# begin ramdisk changes

#Remove old kernel stuffs from ramdisk
if [ "$X00TD" = "1" ];then
 rm -rf $ramdisk/init.special_power.sh
 rm -rf $ramdisk/init.darkonah.rc
 rm -rf $ramdisk/init.spectrum.rc
 rm -rf $ramdisk/init.spectrum.sh
 rm -rf $ramdisk/init.boost.rc
 rm -rf $ramdisk/init.trb.rc
 rm -rf $ramdisk/init.azure.rc
 rm -rf $ramdisk/init.PBH.rc
 rm -rf $ramdisk/init.Pbh.rc
 rm -rf $ramdisk/init.overdose.rc
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
	if [ -e $ramdisk/init.spectrum.rc ];then
	  rm -rf $ramdisk/init.spectrum.rc
	  ui_print "delete /init.spectrum.rc"
	fi
	if [ -e $ramdisk/init.spectrum.sh ];then
	  rm -rf $ramdisk/init.spectrum.sh
	  ui_print "delete /init.spectrum.sh"
	fi
	if [ -e $ramdisk/sbin/init.spectrum.rc ];then
	  rm -rf $ramdisk/sbin/init.spectrum.rc
	  ui_print "delete /sbin/init.spectrum.rc"
	fi
	if [ -e $ramdisk/sbin/init.spectrum.sh ];then
	  rm -rf $ramdisk/sbin/init.spectrum.sh
	  ui_print "delete /sbin/init.spectrum.sh"
	fi
	if [ -e $ramdisk/etc/init.spectrum.rc ];then
	  rm -rf $ramdisk/etc/init.spectrum.rc
	  ui_print "delete /etc/init.spectrum.rc"
	fi
	if [ -e $ramdisk/etc/init.spectrum.sh ];then
	  rm -rf $ramdisk/etc/init.spectrum.sh
	  ui_print "delete /etc/init.spectrum.sh"
	fi
	if [ -e $ramdisk/init.aurora.rc ];then
	  rm -rf $ramdisk/init.aurora.rc
	  ui_print "delete /init.aurora.rc"
	fi
	if [ -e $ramdisk/sbin/init.aurora.rc ];then
	  rm -rf $ramdisk/sbin/init.aurora.rc
	  ui_print "delete /sbin/init.aurora.rc"
	fi
	if [ -e $ramdisk/etc/init.aurora.rc ];then
	  rm -rf $ramdisk/etc/init.aurora.rc
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

# Switch SELinux
if [ "`$BB grep -w "selected.3=2" /tmp/aroma-data/spectrum.prop`" ] || [ "`$BB grep -w "selected.3=1" /tmp/aroma-data/spectrum.prop`" ];then
if [ "`$BB grep -w "selected.3=1" /tmp/aroma-data/spectrum.prop`" ];then
	patch_cmdline androidboot.selinux androidboot.selinux=enforcing
	SELINUXSTATE="Enforcing"
elif [ "`$BB grep -w "selected.3=2" /tmp/aroma-data/spectrum.prop`" ];then
	patch_cmdline androidboot.selinux androidboot.selinux=permissive
	SELINUXSTATE="Permissive"
fi
if [ "$REG" = "IDN" ];then
ui_print "- SELinux diganti ke: $SELINUXSTATE";
elif [ "$REG" = "JAV" ];then
ui_print "- SELinux diganti dadi: $SELINUXSTATE";
elif [ "$REG" = "SUN" ];then
ui_print "- SELinux digantikeun ka: $SELINUXSTATE";
elif [ "$REG" = "EN" ];then
ui_print "- SELinux switched to: $SELINUXSTATE";
fi;
fi;

# Put Android Version on cmdline
android_ver=$(file_getprop /system/build.prop ro.build.version.release);
patch_cmdline androidboot.version androidboot.version=$android_ver

# Switch Vibration Type
NLVib() {
if [ "$REG" = "IDN" ] || [ "$REG" = "JAV" ] || [ "$REG" = "SUN" ];then
ui_print "- Tipe Driver Getaran: NLV";
elif [ "$REG" = "EN" ];then
ui_print "- Vibrate Driver Type: NLV";
fi;
patch_cmdline led.vibration led.vibration=0
}

if [ "`$BB grep -w "selected.1=1" /tmp/aroma-data/refrate.prop`" ];then
	if [ "$android_ver" -lt "11" ];then
	if [ "$REG" = "IDN" ] || [ "$REG" = "SUN" ];then
	ui_print "! Versi Android tidak didukung untuk LV. NLV diatur sebagai default !";
	elif [ "$REG" = "JAV" ];then
	ui_print "! Versi Android ora didukung kanggo LV. NLV disetel minangka standar !";
	elif [ "$REG" = "EN" ];then
	ui_print "! Unsupported Android Version for LV. NLV is set as default !";
	fi;
	NLVib
	else
	if [ "$REG" = "IDN" ] || [ "$REG" = "JAV" ] || [ "$REG" = "SUN" ];then
	ui_print "- Tipe Driver Getaran: LV";
	elif [ "$REG" = "EN" ];then
	ui_print "- Vibrate Driver Type: LV";
	fi;
	patch_cmdline led.vibration led.vibration=1
	fi;
else
	NLVib
fi;

# end ramdisk changes

write_boot;
## end install

