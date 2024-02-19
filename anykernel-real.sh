### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=TheOneMemory kernel v4.19
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=X00TD
device.name2=ASUS_X00TD
device.name3=WW_X00TD
device.name4=X00T
device.name5=WW_X00T
supported.versions=11-14
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# Installation Method
X00TD=1

# shell variables
if [ "$X00TD" = "1" ];then
block=/dev/block/platform/soc/c0c4000.sdhci/by-name/boot;
else
block=/dev/block/bootdevice/by-name/boot;
fi
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

### AnyKernel install
## Mount partitions as rw
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
boot_attributes() {
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 755 755 $ramdisk/init* $ramdisk/sbin;
} # end attributes
fi

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

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
elif [ "$REG" = "EN" ];then
ui_print "- SELinux switched to: $SELINUXSTATE";
fi;
fi;

# Put Android Version on cmdline
android_ver=$(file_getprop /system/build.prop ro.build.version.release);
patch_cmdline androidboot.version androidboot.version=$android_ver

# KernelSU Support
if [ "`$BB grep -w "selected.1=1" /tmp/aroma-data/refrate.prop`" ] || [ "`$BB grep -w "selected.1=2" /tmp/aroma-data/refrate.prop`" ];then
if [ "`$BB grep -w "selected.1=2" /tmp/aroma-data/refrate.prop`" ];then
patch_cmdline kernelsu.safemode kernelsu.safemode=1
if [ "$REG" = "IDN" ];then
KSUSAFEMODE=" (Mode Aman)"
elif [ "$REG" = "EN" ];then
KSUSAFEMODE=" (Safe Mode)"
fi;
else
patch_cmdline kernelsu.safemode kernelsu.safemode=0
KSUSAFEMODE=""
fi;

if [ "$REG" = "IDN" ];then
ui_print "- KernelSU dihidupkan$KSUSAFEMODE !";
elif [ "$REG" = "EN" ];then
ui_print "- KernelSU enabled$KSUSAFEMODE !";
fi;
patch_cmdline kernelsu.enabled kernelsu.enabled=1
else
if [ "$REG" = "IDN" ];then
ui_print "- KernelSU dimatikan !";
elif [ "$REG" = "EN" ];then
ui_print "- KernelSU disabled !";
fi;
patch_cmdline kernelsu.enabled kernelsu.enabled=0
fi

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install


## init_boot files attributes
#init_boot_attributes() {
#set_perm_recursive 0 0 755 644 $ramdisk/*;
#set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;
#} # end attributes

# init_boot shell variables
#block=init_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#block=vendor_kernel_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot files attributes
#vendor_boot_attributes() {
#set_perm_recursive 0 0 755 644 $ramdisk/*;
#set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;
#} # end attributes

# vendor_boot shell variables
#block=vendor_boot;
#is_slot_device=1;
#ramdisk_compression=auto;
#patch_vbmeta_flag=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install
