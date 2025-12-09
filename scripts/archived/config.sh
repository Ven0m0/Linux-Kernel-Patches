#!/usr/bin/env bash
# Set extra kernel options for optimized kernel builds

set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Validate kernel source directory
[[ -n ${1:-} ]] || {
  echo "Error: Kernel source directory not specified" >&2
  exit 1
}
cd "$1" || {
  echo "Error: Directory not found: $1" >&2
  exit 1
}
[[ -f "scripts/config" ]] || {
  echo "Error: Not a valid kernel source tree" >&2
  exit 1
}

# commands:
#     --enable   | -e option   Enable option
#     --disable  | -d option   Disable option
#     --module   | -m option   Turn option into a module
#     --set-str option string  Set option to "string"
#     --set-val option value   Set option to value
#     --undefine | -u option   Undefine option

scripts/config -e LD_DEAD_CODE_DATA_ELIMINATION

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

# Disable debug symbols and BTF (batched for performance)
scripts/config \
  -d DEBUG_INFO \
  -d DEBUG_INFO_BTF \
  -d DEBUG_INFO_DWARF4 \
  -d PAHOLE_HAS_SPLIT_BTF \
  -d DEBUG_INFO_BTF_MODULES

# Disable general debugging features (batched)
scripts/config \
  -d SLUB_DEBUG \
  -d SLUB_DEBUG_ON \
  -d PAGE_POISONING \
  -d GDB_SCRIPTS \
  -d ACPI_DEBUG \
  -d PM_DEBUG \
  -d PM_ADVANCED_DEBUG \
  -d PM_SLEEP_DEBUG \
  -d PM_TRACE_RTC \
  -d LATENCYTOP \
  -d LEDS_TRIGGER_CPU \
  -d LEDS_TRIGGER_GPIO \
  -d PCIEAER_INJECT \
  -d PCIE_ECRC \
  -d GENERIC_IRQ_DEBUGFS \
  -d GENERIC_IRQ_INJECTION \
  -d FUNCTION_ERROR_INJECTION \
  -d PRINTK_INDEX \
  -d SOFTLOCKUP_DETECTOR_INTR_STORM \
  -d GENERIC_IRQ_STAT_SNAPSHOT
# Disable subsystem-specific debugging (batched for performance)
scripts/config \
  -d 6LOWPAN_DEBUGFS \
  -d AF_RXRPC_DEBUG \
  -d AFS_DEBUG \
  -d AFS_DEBUG_CURSOR \
  -d ATA_VERBOSE_ERROR \
  -d ATH10K_DEBUG \
  -d ATH10K_DEBUGFS \
  -d ATH12K_DEBUG \
  -d ATH5K_DEBUG \
  -d ATH6KL_DEBUG \
  -d ATH9K_HTC_DEBUGFS \
  -d ATM_ENI_DEBUG \
  -d ATM_IA_DEBUG \
  -d ATM_IDT77252_DEBUG \
  -d BCACHE_DEBUG \
  -d BCACHEFS_DEBUG \
  -d BEFS_DEBUG \
  -d BLK_DEBUG_FS \
  -d BT_DEBUGFS \
  -d CEPH_LIB_PRETTYDEBUG \
  -d CFG80211_DEBUGFS \
  -d CIFS_DEBUG \
  -d CIFS_DEBUG2 \
  -d CIFS_DEBUG_DUMP_KEYS \
  -d CMA_DEBUGFS \
  -d CROS_EC_DEBUGFS \
  -d CRYPTO_DEV_AMLOGIC_GXL_DEBUG \
  -d CRYPTO_DEV_CCP_DEBUGFS \
  -d DEBUG_KMAP_LOCAL_FORCE_MAP \
  -d DEBUG_MEMORY_INIT \
  -d DEBUG_RODATA_TEST \
  -d DEBUG_RSEQ \
  -d DEBUG_WX \
  -d DLM_DEBUG \
  -d DM_DEBUG_BLOCK_MANAGER_LOCKING \
  -d DM_DEBUG_BLOCK_STACK_TRACING \
  -d DRM_ACCEL_IVPU_DEBUG \
  -d DRM_DEBUG_DP_MST_TOPOLOGY_REFS \
  -d DRM_DEBUG_MODESET_LOCK \
  -d DRM_DISPLAY_DP_TUNNEL_STATE_DEBUG \
  -d DRM_I915_DEBUG \
  -d DRM_I915_DEBUG_GUC \
  -d DRM_I915_DEBUG_MMIO \
  -d DRM_I915_DEBUG_VBLANK_EVADE \
  -d DRM_I915_DEBUG_WAKEREF \
  -d DRM_I915_SW_FENCE_DEBUG_OBJECTS \
  -d DRM_XE_DEBUG \
  -d DRM_XE_DEBUG_MEM \
  -d DRM_XE_DEBUG_MEMIRQ \
  -d DRM_XE_DEBUG_SRIOV \
  -d DRM_XE_DEBUG_VM \
  -d DVB_USB_DEBUG \
  -d EARLY_PRINTK_DBGP \
  -d EARLY_PRINTK_USB_XDBC \
  -d EXT4_DEBUG \
  -d HIST_TRIGGERS_DEBUG \
  -d INFINIBAND_MTHCA_DEBUG \
  -d IWLEGACY_DEBUG \
  -d IWLWIFI_DEBUG \
  -d JFS_DEBUG \
  -d LDM_DEBUG \
  -d LIBERTAS_THINFIRM_DEBUG \
  -d NETFS_DEBUG \
  -d NFS_DEBUG \
  -d NVME_TARGET_DEBUGFS \
  -d NVME_VERBOSE_ERRORS \
  -d OCFS2_DEBUG_FS \
  -d PNP_DEBUG_MESSAGES \
  -d QUOTA_DEBUG \
  -d RTLWIFI_DEBUG \
  -d RTW88_DEBUG \
  -d RTW88_DEBUGFS \
  -d RTW89_DEBUGFS \
  -d RTW89_DEBUGMSG \
  -d SHRINKER_DEBUG \
  -d SMS_SIANO_DEBUGFS \
  -d SND_SOC_SOF_DEBUG \
  -d SUNRPC_DEBUG \
  -d UFS_DEBUG \
  -d USB_DWC2_DEBUG \
  -d VFIO_DEBUGFS \
  -d VIRTIO_DEBUG \
  -d VISL_DEBUGFS \
  -d WCN36XX_DEBUGFS \
  -d WWAN_DEBUGFS \
  -d XEN_DEBUG_FS \
  -d USB_PRINTER

# Disable security features not needed for desktop
scripts/config \
  -d AMD_MEM_ENCRYPT \
  -d X86_SGX

# Disable direct rendering manager drivers (batched)
scripts/config \
  -d DRM_ACCEL_AMDXDNA \
  -d DRM_AMDGPU \
  -d DRM_APPLETBDRM \
  -d DRM_ARCPGU \
  -d DRM_HISI_HIBMC \
  -d DRM_I915 \
  -d DRM_RADEON \
  -d DRM_XE \
  -d DRM_AST \
  -d DRM_MGAG200

# Disable laptop support (batched)
scripts/config \
  -d CHROMEOS_LAPTOP \
  -d COMPAL_LAPTOP \
  -d DELL_LAPTOP \
  -d EEEPC_LAPTOP \
  -d FUJITSU_LAPTOP \
  -d IDEAPAD_LAPTOP \
  -d LG_LAPTOP \
  -d MSI_LAPTOP \
  -d PANASONIC_LAPTOP \
  -d SAMSUNG_LAPTOP \
  -d SONY_LAPTOP \
  -d TOPSTAR_LAPTOP

# Disable platform support (batched)
scripts/config \
  -d CZNIC_PLATFORMS \
  -d MELLANOX_PLATFORM \
  -d SURFACE_PLATFORMS

# Disable input devices not needed (batched)
scripts/config \
  -d KEYBOARD_ATKBD \
  -d MOUSE_PS2 \
  -d SERIO_I8042 \
  -d INPUT_TOUCHSCREEN

# Disable subsystems not needed (batched)
scripts/config \
  -d CAN \
  -d IIO \
  -d INFINIBAND \
  -d BE2NET \
  -d PARPORT \
  -d SSB

# Disable Mellanox ethernet (batched)
scripts/config \
  -d MLX4_EN \
  -d MLX5_CORE \
  -d MLXSW_CORE \
  -d MLXFW

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

# Disable network vendor drivers (batched for faster configuration)
scripts/config \
  -d NET_VENDOR_ADI \
  -d NET_VENDOR_AGERE \
  -d NET_VENDOR_AMAZON \
  -d NET_VENDOR_AMD \
  -d NET_VENDOR_AQUANTIA \
  -d NET_VENDOR_ASIX \
  -d NET_VENDOR_ATHEROS \
  -d NET_VENDOR_BROADCOM \
  -d NET_VENDOR_CADENCE \
  -d NET_VENDOR_CHELSIO \
  -d NET_VENDOR_CISCO \
  -d NET_VENDOR_CORTINA \
  -d NET_VENDOR_DAVICOM \
  -d NET_VENDOR_DLINK \
  -d NET_VENDOR_EMULEX \
  -d NET_VENDOR_ENGLEDER \
  -d NET_VENDOR_FUNGIBLE \
  -d NET_VENDOR_GOOGLE \
  -d NET_VENDOR_HISILICON \
  -d NET_VENDOR_HUAWEI \
  -d NET_VENDOR_I825XX \
  -d NET_VENDOR_INTEL \
  -d NET_VENDOR_LITEX \
  -d NET_VENDOR_MARVELL \
  -d NET_VENDOR_MELLANOX \
  -d NET_VENDOR_META \
  -d NET_VENDOR_MICROSOFT \
  -d NET_VENDOR_NETRONOME \
  -d NET_VENDOR_NI \
  -d NET_VENDOR_PACKET_ENGINES \
  -d NET_VENDOR_QLOGIC \
  -d NET_VENDOR_SOCIONEXT \
  -d NET_VENDOR_SOLARFLARE \
  -d NET_VENDOR_STMICRO \
  -d NET_VENDOR_VERTEXCOM \
  -d NET_VENDOR_WANGXUN

# Disable wireless and serial networking (batched)
scripts/config \
  -d SLIP \
  -d WAN \
  -d 6LOWPAN \
  -d IEEE802154 \
  -d WLAN

# Disable wireless vendor support (batched)
scripts/config \
  -d WLAN_VENDOR_ADMTEK \
  -d WLAN_VENDOR_ATH \
  -d WLAN_VENDOR_ATMEL \
  -d WLAN_VENDOR_BROADCOM \
  -d WLAN_VENDOR_INTEL \
  -d WLAN_VENDOR_INTERSIL \
  -d WLAN_VENDOR_MARVELL \
  -d WLAN_VENDOR_MEDIATEK \
  -d WLAN_VENDOR_PURELIFI \
  -d WLAN_VENDOR_QUANTENNA \
  -d WLAN_VENDOR_RALINK \
  -d WLAN_VENDOR_REALTEK \
  -d WLAN_VENDOR_RSI \
  -d WLAN_VENDOR_SILABS \
  -d WLAN_VENDOR_ST \
  -d WLAN_VENDOR_TI \
  -d WLAN_VENDOR_ZYDAS

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
if [[ $(uname -m) == *"x86"* ]]; then
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
