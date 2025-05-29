#!/usr/bin/env bash
# Set extra kernel options.

### Exit immediately on error.
set -e

cd "$1" || { echo "Directory not found: $1"; exit 1; }

# commands:
#     --enable   | -e option   Enable option
#     --disable  | -d option   Disable option
#     --module   | -m option   Turn option into a module
#     --set-str option string  Set option to "string"
#     --set-val option value   Set option to value
#     --undefine | -u option   Undefine option

### Answer unconfigured (NEW) kernel options in the CachyOS config.
scripts/config -d DRM_MGAG200_DISABLE_WRITECOMBINE
scripts/config -d GPIO_BT8XX
scripts/config -d INTEL_TDX_HOST
scripts/config -d SND_SE6X

### Disable memory hotplug not needed for desktop use.
scripts/config -d MEMORY_HOTPLUG

### Set the minimal base_slice_ns option for BORE.
### 1000Hz = 2.0ms, 800Hz = 2.5ms, 600Hz = 1.6(6)ms, 500Hz = 2.0ms.
#scripts/config --set-val MIN_BASE_SLICE_NS 1600000

### Decrease the kernel log buffer size (default 17).
scripts/config --set-val LOG_BUF_SHIFT 16

### Decrease the maximum number of vCPUs per KVM guest.
scripts/config --set-val KVM_MAX_NR_VCPUS 128

### Decrease the maximum number of GPUs.
scripts/config --set-val VGA_ARB_MAX_GPUS 4

### Enable ACPI options. (default -m)
scripts/config -e ACPI_TAD -e ACPI_VIDEO -e ACPI_WMI -e INPUT_SPARSEKMAP

### Enable input modules. (default -m)
scripts/config -e SERIO -e SERIO_I8042 -e SERIO_LIBPS2 -e UHID -e USB_HID
scripts/config -d HID_APPLE 
scripts/config -e HID_GENERIC 
#scripts/config -e HID_LOGITECH -e HID_LOGITECH_DJ -e HID_LOGITECH_HIDPP
scripts/config -e HID_MICROSOFT -e HID_SAMSUNG -e HID_VIVALDI
scripts/config -e SERIO_GPIO_PS2 -e SERIO_SERPORT

### Enable storage modules. (default -m)
scripts/config -e NVME_KEYRING -e NVME_AUTH -e NVME_CORE
scripts/config -e BLK_DEV_DM -e BLK_DEV_LOOP -e BLK_DEV_NVME
scripts/config -e BLK_DEV_MD -d MD_AUTODETECT -d DM_INIT
scripts/config -e USB_XHCI_PCI -e USB_XHCI_PCI_RENESAS -e USB_XHCI_PLATFORM
scripts/config -e USB_STORAGE -e USB_STORAGE_REALTEK -e USB_UAS

### Enable file systems. (default -m)
scripts/config -d MSDOS_FS -e FAT_FS -e VFAT_FS
scripts/config -e EXT4_FS -e FS_MBCACHE -e JBD2
scripts/config -e BTRFS_FS -e F2FS_FS -e XFS_FS
scripts/config -d BCACHEFS_FS

### Set tree-based hierarchical RCU fanout value. (default 64)
scripts/config --set-val RCU_FANOUT 32

### Disable hardware monitors.
scripts/config -d IGB_HWMON
scripts/config -d IXGBE_HWMON
scripts/config -d TIGON3_HWMON
scripts/config -d SCSI_UFS_HWMON
scripts/config -d SENSORS_IIO_HWMON

### Disable more drivers.
scripts/config -d AGP
scripts/config -d ATA_SFF
scripts/config -d ISDN
scripts/config -d NET_FC
scripts/config -d RD_BZIP2
scripts/config -d RD_LZMA
scripts/config -d RD_LZO
scripts/config -d RD_LZ4
scripts/config -d FUSION
scripts/config -d MACINTOSH_DRIVERS
scripts/config -d SCSI_PROC_FS
scripts/config -d SCSI_CONSTANTS
scripts/config -d SCSI_LOWLEVEL

### Disable tracers.
scripts/config -d ATH5K_TRACER
scripts/config -d DM_UEVENT
scripts/config -d FUNCTION_PROFILER
scripts/config -d FTRACE_RECORD_RECURSION
scripts/config -d FTRACE_SORT_STARTUP_TEST
scripts/config -d FTRACE_VALIDATE_RCU_IS_WATCHING
scripts/config -d HWLAT_TRACER
scripts/config -d IRQSOFF_TRACER
scripts/config -d KPROBE_EVENTS_ON_NOTRACE
scripts/config -d LOCK_EVENT_COUNTS
scripts/config -d MMIOTRACE
scripts/config -d MMIOTRACE_TEST
scripts/config -d OSNOISE_TRACER
scripts/config -d PM_DEVFREQ_EVENT
scripts/config -d PREEMPT_TRACER
scripts/config -d PSTORE_FTRACE
scripts/config -d TIMERLAT_TRACER
scripts/config -d SYNTH_EVENTS
scripts/config -d USER_EVENTS
scripts/config -d HIST_TRIGGERS

# Debug https://git.staropensource.de/JeremyStarTM/aur-linux-clear/src/branch/develop/PKGBUILD
scripts/config -d DEBUG_INFO
scripts/config -d DEBUG_INFO_BTF
scripts/config -d DEBUG_INFO_DWARF4
scripts/config -d PAHOLE_HAS_SPLIT_BTF
scripts/config -d DEBUG_INFO_BTF_MODULES

### Disable debug.
scripts/config -d SLUB_DEBUG
scripts/config -d SLUB_DEBUG_ON
scripts/config -d PAGE_POISONING
scripts/config -d GDB_SCRIPTS
scripts/config -d ACPI_DEBUG
scripts/config -d PM_DEBUG
scripts/config -d PM_ADVANCED_DEBUG
scripts/config -d PM_SLEEP_DEBUG
scripts/config -d PM_TRACE_RTC
scripts/config -d LATENCYTOP
scripts/config -d LEDS_TRIGGER_CPU
scripts/config -d LEDS_TRIGGER_GPIO
scripts/config -d PCIEAER_INJECT
scripts/config -d PCIE_ECRC
scripts/config -d GENERIC_IRQ_DEBUGFS
scripts/config -d GENERIC_IRQ_INJECTION
scripts/config -d FUNCTION_ERROR_INJECTION
scripts/config -d PRINTK_INDEX
scripts/config -d SOFTLOCKUP_DETECTOR_INTR_STORM
scripts/config -d GENERIC_IRQ_STAT_SNAPSHOT
scripts/config -d 6LOWPAN_DEBUGFS
scripts/config -d AF_RXRPC_DEBUG
scripts/config -d AFS_DEBUG
scripts/config -d AFS_DEBUG_CURSOR
scripts/config -d ATA_VERBOSE_ERROR
scripts/config -d ATH10K_DEBUG
scripts/config -d ATH10K_DEBUGFS
scripts/config -d ATH12K_DEBUG
scripts/config -d ATH5K_DEBUG
scripts/config -d ATH6KL_DEBUG
scripts/config -d ATH9K_HTC_DEBUGFS
scripts/config -d ATM_ENI_DEBUG
scripts/config -d ATM_IA_DEBUG
scripts/config -d ATM_IDT77252_DEBUG
scripts/config -d BCACHE_DEBUG
scripts/config -d BCACHEFS_DEBUG
scripts/config -d BEFS_DEBUG
scripts/config -d BLK_DEBUG_FS
scripts/config -d BT_DEBUGFS
scripts/config -d CEPH_LIB_PRETTYDEBUG
scripts/config -d CFG80211_DEBUGFS
scripts/config -d CIFS_DEBUG
scripts/config -d CIFS_DEBUG2
scripts/config -d CIFS_DEBUG_DUMP_KEYS
scripts/config -d CMA_DEBUGFS
scripts/config -d CROS_EC_DEBUGFS
scripts/config -d CRYPTO_DEV_AMLOGIC_GXL_DEBUG
scripts/config -d CRYPTO_DEV_CCP_DEBUGFS
scripts/config -d DEBUG_KMAP_LOCAL_FORCE_MAP
scripts/config -d DEBUG_MEMORY_INIT
scripts/config -d DEBUG_RODATA_TEST
scripts/config -d DEBUG_RSEQ
scripts/config -d DEBUG_WX
scripts/config -d DLM_DEBUG
scripts/config -d DM_DEBUG_BLOCK_MANAGER_LOCKING
scripts/config -d DM_DEBUG_BLOCK_STACK_TRACING
scripts/config -d DRM_ACCEL_IVPU_DEBUG
scripts/config -d DRM_DEBUG_DP_MST_TOPOLOGY_REFS
scripts/config -d DRM_DEBUG_MODESET_LOCK
scripts/config -d DRM_DISPLAY_DP_TUNNEL_STATE_DEBUG
scripts/config -d DRM_I915_DEBUG
scripts/config -d DRM_I915_DEBUG_GUC
scripts/config -d DRM_I915_DEBUG_MMIO
scripts/config -d DRM_I915_DEBUG_VBLANK_EVADE
scripts/config -d DRM_I915_DEBUG_WAKEREF
scripts/config -d DRM_I915_SW_FENCE_DEBUG_OBJECTS
scripts/config -d DRM_XE_DEBUG
scripts/config -d DRM_XE_DEBUG_MEM
scripts/config -d DRM_XE_DEBUG_MEMIRQ
scripts/config -d DRM_XE_DEBUG_SRIOV
scripts/config -d DRM_XE_DEBUG_VM
scripts/config -d DVB_USB_DEBUG
scripts/config -d EARLY_PRINTK_DBGP
scripts/config -d EARLY_PRINTK_USB_XDBC
scripts/config -d EXT4_DEBUG
scripts/config -d HIST_TRIGGERS_DEBUG
scripts/config -d INFINIBAND_MTHCA_DEBUG
scripts/config -d IWLEGACY_DEBUG
scripts/config -d IWLWIFI_DEBUG
scripts/config -d JFS_DEBUG
scripts/config -d LDM_DEBUG
scripts/config -d LIBERTAS_THINFIRM_DEBUG
scripts/config -d NETFS_DEBUG
scripts/config -d NFS_DEBUG
scripts/config -d NVME_TARGET_DEBUGFS
scripts/config -d NVME_VERBOSE_ERRORS
scripts/config -d OCFS2_DEBUG_FS
scripts/config -d PNP_DEBUG_MESSAGES
scripts/config -d QUOTA_DEBUG
scripts/config -d RTLWIFI_DEBUG
scripts/config -d RTW88_DEBUG
scripts/config -d RTW88_DEBUGFS
scripts/config -d RTW89_DEBUGFS
scripts/config -d RTW89_DEBUGMSG
scripts/config -d SHRINKER_DEBUG
scripts/config -d SMS_SIANO_DEBUGFS
scripts/config -d SND_SOC_SOF_DEBUG
scripts/config -d SUNRPC_DEBUG
scripts/config -d UFS_DEBUG
scripts/config -d USB_DWC2_DEBUG
scripts/config -d VFIO_DEBUGFS
scripts/config -d VIRTIO_DEBUG
scripts/config -d VISL_DEBUGFS
scripts/config -d WCN36XX_DEBUGFS
scripts/config -d WWAN_DEBUGFS
scripts/config -d XEN_DEBUG_FS
scripts/config -d USB_PRINTER

# Disable AMD Secure Memory Encryption (SME) support
scripts/config -d AMD_MEM_ENCRYPT

# Disable Intel Software Guard eXtensions (SGX)
scripts/config -d X86_SGX

# Disable direct rendering manager support
scripts/config -d DRM_ACCEL_AMDXDNA
scripts/config -d DRM_AMDGPU
scripts/config -d DRM_APPLETBDRM
scripts/config -d DRM_ARCPGU
scripts/config -d DRM_HISI_HIBMC
scripts/config -d DRM_I915
scripts/config -d DRM_RADEON
scripts/config -d DRM_XE
scripts/config -d DRM_AST
scripts/config -d DRM_MGAG200

# Disable laptop support
#scripts/config -d ASUS_LAPTOP
scripts/config -d CHROMEOS_LAPTOP
scripts/config -d COMPAL_LAPTOP
scripts/config -d DELL_LAPTOP
scripts/config -d EEEPC_LAPTOP
scripts/config -d FUJITSU_LAPTOP
scripts/config -d IDEAPAD_LAPTOP
scripts/config -d LG_LAPTOP
scripts/config -d MSI_LAPTOP
scripts/config -d PANASONIC_LAPTOP
scripts/config -d SAMSUNG_LAPTOP
scripts/config -d SONY_LAPTOP
scripts/config -d TOPSTAR_LAPTOP

# Disable platform support
#scripts/config -d CHROME_PLATFORMS
scripts/config -d CZNIC_PLATFORMS
scripts/config -d MELLANOX_PLATFORM
scripts/config -d SURFACE_PLATFORMS

# Disable PS/2 keyboard and mouse
scripts/config -d KEYBOARD_ATKBD -d MOUSE_PS2 -d SERIO_I8042

# Disable touchscreen input devices
scripts/config -d INPUT_TOUCHSCREEN

# Disable Controller Area Network (CAN) bus subsystem support
scripts/config -d CAN

# Disable industrial I/O subsystem support
scripts/config -d IIO

# Disable InfiniBand support
scripts/config -d INFINIBAND

# Disable ServerEngines' 10Gbps NIC - BladeEngine ethernet support
scripts/config -d BE2NET

# Disable Mellanox Technologies ethernet support
scripts/config -d MLX4_EN
scripts/config -d MLX5_CORE
scripts/config -d MLXSW_CORE
scripts/config -d MLXFW

# Disable parallel port support
scripts/config -d PARPORT

# Disable Sonics Silicon Backplane support
scripts/config -d SSB

# Disable media tuners
scripts/config -d DVB_CORE
scripts/config -d VIDEO_BT848
scripts/config -d VIDEO_CX231XX
scripts/config -d VIDEO_CX25821
scripts/config -d VIDEO_CX88
scripts/config -d VIDEO_DT3155
scripts/config -d VIDEO_EM28XX
scripts/config -d VIDEO_GO7007
scripts/config -d VIDEO_HDPVR
scripts/config -d VIDEO_HEXIUM_GEMINI
scripts/config -d VIDEO_HEXIUM_ORION
scripts/config -d VIDEO_IVTV
scripts/config -d VIDEO_MXB
scripts/config -d VIDEO_SAA7134
scripts/config -d VIDEO_STK1160

# Disable GSPCA based webcams
scripts/config -d USB_GSPCA

# Disable network drivers
scripts/config -d NET_VENDOR_ADI
scripts/config -d NET_VENDOR_AGERE
scripts/config -d NET_VENDOR_AMAZON
scripts/config -d NET_VENDOR_AMD
scripts/config -d NET_VENDOR_AQUANTIA
scripts/config -d NET_VENDOR_ASIX
scripts/config -d NET_VENDOR_ATHEROS
scripts/config -d NET_VENDOR_BROADCOM
scripts/config -d NET_VENDOR_CADENCE
scripts/config -d NET_VENDOR_CHELSIO
scripts/config -d NET_VENDOR_CISCO
scripts/config -d NET_VENDOR_CORTINA
scripts/config -d NET_VENDOR_DAVICOM
scripts/config -d NET_VENDOR_DLINK
scripts/config -d NET_VENDOR_EMULEX
scripts/config -d NET_VENDOR_ENGLEDER
scripts/config -d NET_VENDOR_FUNGIBLE
scripts/config -d NET_VENDOR_GOOGLE
scripts/config -d NET_VENDOR_HISILICON
scripts/config -d NET_VENDOR_HUAWEI
scripts/config -d NET_VENDOR_I825XX
scripts/config -d NET_VENDOR_INTEL
scripts/config -d NET_VENDOR_LITEX
scripts/config -d NET_VENDOR_MARVELL
scripts/config -d NET_VENDOR_MELLANOX
scripts/config -d NET_VENDOR_META
scripts/config -d NET_VENDOR_MICROSOFT
scripts/config -d NET_VENDOR_NETRONOME
scripts/config -d NET_VENDOR_NI
scripts/config -d NET_VENDOR_PACKET_ENGINES
scripts/config -d NET_VENDOR_QLOGIC
scripts/config -d NET_VENDOR_SOCIONEXT
scripts/config -d NET_VENDOR_SOLARFLARE
scripts/config -d NET_VENDOR_STMICRO
scripts/config -d NET_VENDOR_VERTEXCOM
scripts/config -d NET_VENDOR_WANGXUN

# Disable SLIP (serial line) support
scripts/config -d SLIP

# Disable Wan interfaces support
scripts/config -d WAN

# Disable IPv6 over Low power Wireless Personal Area Network
scripts/config -d 6LOWPAN -d IEEE802154

# Disable wireless LAN drivers
scripts/config -d WLAN

# Disable wireless vendor support
# https://github.com/torvalds/linux/blob/master/drivers/net/wireless/
scripts/config -d WLAN_VENDOR_ADMTEK
scripts/config -d WLAN_VENDOR_ATH
scripts/config -d WLAN_VENDOR_ATMEL
scripts/config -d WLAN_VENDOR_BROADCOM
scripts/config -d WLAN_VENDOR_INTEL
scripts/config -d WLAN_VENDOR_INTERSIL
scripts/config -d WLAN_VENDOR_MARVELL
scripts/config -d WLAN_VENDOR_MEDIATEK
scripts/config -d WLAN_VENDOR_PURELIFI
scripts/config -d WLAN_VENDOR_QUANTENNA
scripts/config -d WLAN_VENDOR_RALINK
scripts/config -d WLAN_VENDOR_REALTEK
scripts/config -d WLAN_VENDOR_RSI
scripts/config -d WLAN_VENDOR_SILABS
scripts/config -d WLAN_VENDOR_ST
scripts/config -d WLAN_VENDOR_TI
scripts/config -d WLAN_VENDOR_ZYDAS

# Disable misc sound devices
scripts/config -d SND_HDA_SCODEC_TAS2781_SPI
scripts/config -d SND_I2S_HI6210_I2S
scripts/config -d SND_SOC_CHV3_I2S
scripts/config -d SND_SOC_INTEL_CATPT
#scripts/config -d SND_SOC

scripts/config -d SND_AD1889
scripts/config -d SND_ALI5451
scripts/config -d SND_ALS300
scripts/config -d SND_ALS4000
scripts/config -d SND_ASIHPI
scripts/config -d SND_ATIIXP
scripts/config -d SND_ATIIXP_MODEM
scripts/config -d SND_EMU10K1
scripts/config -d SND_EMU10K1X
scripts/config -d SND_TRIDENT
scripts/config -d SND_VIA82XX
scripts/config -d SND_VIA82XX_MODEM
scripts/config -d SND_VIRTUOSO

### Apply various Clear Linux defaults
if [[ $(uname -m) = *"x86"* ]]; then
    ### Default to IOMMU passthrough domain type.
    scripts/config -d IOMMU_DEFAULT_DMA_LAZY -e IOMMU_DEFAULT_PASSTHROUGH

    ### Disable support for memory balloon compaction.
    #scripts/config -d BALLOON_COMPACTION

    ### Disable the Contiguous Memory Allocator.
    #scripts/config -d CMA

    ### Disable DAMON: Data Access Monitoring Framework.
    scripts/config -d DAMON

    ### Disable HWPoison pages injector.
    scripts/config -d HWPOISON_INJECT

    ### Disable track memory changes and idle page tracking.
    #scripts/config -d MEM_SOFT_DIRTY -d IDLE_PAGE_TRACKING

    ### Disable paravirtual steal time accounting.
    scripts/config -d PARAVIRT_TIME_ACCOUNTING

    ### Disable pvpanic device support.
    scripts/config -d PVPANIC

    ### Require boot param to enable pressure stall information tracking.
    scripts/config -e PSI_DEFAULT_DISABLED

    ### Disable khugepaged to put read-only file-backed pages in THP.
    scripts/config -d READ_ONLY_THP_FOR_FS

    ### Disable Integrity Policy Enforcement (IPE).
    scripts/config -d SECURITY_IPE

    ### Disable support for userspace-controlled virtual timers.
    scripts/config -d SND_UTIMER

    ### Disable the general notification queue.
    scripts/config -d WATCH_QUEUE

    ### Disable Watchdog Timer Support.
    scripts/config -d WATCHDOG

    ### Disable PCI Express ASPM L0s and L1, even if the BIOS enabled them.
    scripts/config -d PCIEASPM_DEFAULT -e PCIEASPM_PERFORMANCE

    ### Disable workqueue power-efficient mode by default.
    scripts/config -d WQ_POWER_EFFICIENT_DEFAULT

    ### Set the default state of memory_corruption_check to off.
    scripts/config -d X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK

    ### Disable Split Lock Detect and Bus Lock Detect support.
    scripts/config -d X86_BUS_LOCK_DETECT

    ### Disable statistic for Change Page Attribute.
    scripts/config -d X86_CPA_STATISTICS

    ### Disable x86 instruction decoder selftest.
    scripts/config -d X86_DECODER_SELFTEST

    ### Disable 5-level page tables support.
    scripts/config -d X86_5LEVEL

    ### Disable strong stack protector.
    scripts/config -d STACKPROTECTOR_STRONG -e STACKPROTECTOR

    ### Default to none for vsyscall table for legacy applications.
    scripts/config -d LEGACY_VSYSCALL_XONLY -e LEGACY_VSYSCALL_NONE

    ### Disable LDT (local descriptor table) to run 16-bit or segmented code such as
    ### DOSEMU or some Wine programs. Enabling this adds a small amount of overhead
    ### to context switches and increases the low-level kernel attack surface.
    scripts/config -d UID16 -d X86_16BIT -d MODIFY_LDT_SYSCALL

    ### Disable obsolete sysfs syscall support.
    scripts/config -d SYSFS_SYSCALL

    ### Enforce strict size checking for sigaltstack.
    scripts/config -e STRICT_SIGALTSTACK_SIZE

    ### Disable Kexec and crash features.
    scripts/config -d KEXEC -d KEXEC_FILE -d CRASH_DUMP

    ### Disable low-overhead sampling-based memory safety error detector.
    scripts/config -d KFENCE

    ### Disable automatic stack variable initialization. (Clear and XanMod default)
    scripts/config -d INIT_STACK_ALL_ZERO -e INIT_STACK_NONE

    ### Disable utilization clamping for RT/FAIR tasks.
    scripts/config -d UCLAMP_TASK

    ### Disable CGROUP controllers.
    #scripts/config -d CGROUP_HUGETLB
    #scripts/config -d CGROUP_NET_PRIO
    #scripts/config -d CGROUP_PERF
    scripts/config -d CGROUP_RDMA

    ### Disable support for latency based cgroup IO protection.
    #scripts/config -d BLK_CGROUP_IOLATENCY

    ### Disable support for cost model based cgroup IO controller.
    #scripts/config -d BLK_CGROUP_IOCOST

    ### Disable cgroup I/O controller for assigning an I/O priority class.
    #scripts/config -d BLK_CGROUP_IOPRIO

    ### Disable netfilter "control group" match support.
    #scripts/config -d NETFILTER_XT_MATCH_CGROUP

    ### Apply Clear defaults for NR_CPUS and NODES_SHIFT.
    scripts/config -d CPUMASK_OFFSTACK -d MAXSMP
    scripts/config --set-val NR_CPUS_RANGE_BEGIN 2
    scripts/config --set-val NR_CPUS_RANGE_END 512
    scripts/config --set-val NR_CPUS_DEFAULT 64
    scripts/config --set-val NR_CPUS 512
    scripts/config --set-val NODES_SHIFT 10
fi
