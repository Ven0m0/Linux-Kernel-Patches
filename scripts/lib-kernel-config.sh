#!/usr/bin/env bash
# Kernel configuration library for Linux-Kernel-Patches
# Provides modular functions to apply various kernel configuration optimizations
#
# Usage: Source this file and call the desired functions
#   source lib-kernel-config.sh
#   apply_performance_opts "$kernel_src_dir"
#
# All functions require the kernel source directory as the first argument

set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Validate kernel source directory
_validate_kernel_dir() {
  local kdir="${1:?Kernel source directory required}"
  [[ -d "$kdir" ]] || {
    echo "Error: Directory not found: $kdir" >&2
    return 1
  }
  [[ -f "$kdir/scripts/config" ]] || {
    echo "Error: Not a valid kernel source tree: $kdir" >&2
    return 1
  }
  return 0
}

# Helper to run scripts/config
_kconfig() {
  local kdir="$1"
  shift
  "$kdir/scripts/config" "$@"
}

# =============================================================================
# BASIC KERNEL OPTIONS
# =============================================================================

# Answer unconfigured (NEW) kernel options
apply_new_options() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d DRM_MGAG200_DISABLE_WRITECOMBINE \
    -d GPIO_BT8XX \
    -d INTEL_TDX_HOST \
    -d SND_SE6X
}

# Enable dead code elimination
apply_dead_code_elimination() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -e HAVE_LD_DEAD_CODE_DATA_ELIMINATION \
    -e LD_DEAD_CODE_DATA_ELIMINATION
}

# =============================================================================
# DEBUG FEATURE DISABLING
# =============================================================================

# Disable debug symbols and BTF
apply_debug_symbols_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d DEBUG_INFO \
    -d DEBUG_INFO_BTF \
    -d DEBUG_INFO_DWARF4 \
    -d PAHOLE_HAS_SPLIT_BTF \
    -d DEBUG_INFO_BTF_MODULES
}

# Disable general debugging features
apply_debug_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
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
    -d GENERIC_IRQ_STAT_SNAPSHOT \
    -d SCHED_DEBUG \
    -d DEBUG_PREEMPT \
    -d CRASH_DUMP \
    -d USB_PRINTER \
    -d BPF \
    -d FTRACE \
    -d FUNCTION_TRACER
}

# Disable subsystem-specific debugging
apply_debug_subsystems_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
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
    -d XEN_DEBUG_FS
}

# Disable all tracers
apply_tracers_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d ATH5K_TRACER \
    -d DM_UEVENT \
    -d FUNCTION_PROFILER \
    -d FTRACE_RECORD_RECURSION \
    -d FTRACE_SORT_STARTUP_TEST \
    -d FTRACE_VALIDATE_RCU_IS_WATCHING \
    -d HWLAT_TRACER \
    -d IRQSOFF_TRACER \
    -d KPROBE_EVENTS_ON_NOTRACE \
    -d LOCK_EVENT_COUNTS \
    -d MMIOTRACE \
    -d MMIOTRACE_TEST \
    -d OSNOISE_TRACER \
    -d PM_DEVFREQ_EVENT \
    -d PREEMPT_TRACER \
    -d PSTORE_FTRACE \
    -d TIMERLAT_TRACER \
    -d SYNTH_EVENTS \
    -d USER_EVENTS \
    -d HIST_TRIGGERS
}

# =============================================================================
# PERFORMANCE OPTIMIZATIONS
# =============================================================================

# Apply performance and scheduling optimizations
apply_performance_opts() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE \
    -d HZ_PERIODIC \
    -d NO_HZ_IDLE \
    -d CONTEXT_TRACKING_FORCE \
    -e NO_HZ_FULL_NODEF \
    -e NO_HZ_FULL \
    -e NO_HZ \
    -e NO_HZ_COMMON \
    -e CONTEXT_TRACKING
}

# Apply preemption settings
apply_preemption_opts() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -e PREEMPT_DYNAMIC \
    -d PREEMPT \
    -d PREEMPT_VOLUNTARY \
    -e PREEMPT_LAZY \
    -d PREEMPT_NONE
}

# Apply compiler optimizations
apply_compiler_opts() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d CC_OPTIMIZE_FOR_PERFORMANCE \
    -e CC_OPTIMIZE_FOR_PERFORMANCE_O3
}

# Apply network optimizations (BBR congestion control)
apply_network_opts() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -m TCP_CONG_CUBIC \
    -d DEFAULT_CUBIC \
    -e TCP_CONG_BBR \
    -e DEFAULT_BBR \
    --set-str DEFAULT_TCP_CONG bbr \
    -e NET_SCH_FQ_CODEL \
    -e NET_SCH_FQ \
    -e CONFIG_DEFAULT_FQ_CODEL \
    -d CONFIG_DEFAULT_FQ
}

# Apply memory optimizations
apply_memory_opts() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d TRANSPARENT_HUGEPAGE_MADVISE \
    -e TRANSPARENT_HUGEPAGE_ALWAYS \
    -e USER_NS
}

# =============================================================================
# CLEAR LINUX DEFAULTS (x86)
# =============================================================================

# Apply Clear Linux defaults for x86 systems
apply_clear_defaults() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  # Only apply on x86 systems
  if [[ $(uname -m) != *"x86"* ]]; then
    return 0
  fi

  _kconfig "$kdir" \
    -d IOMMU_DEFAULT_DMA_LAZY -e IOMMU_DEFAULT_PASSTHROUGH \
    -d DAMON \
    -d HWPOISON_INJECT \
    -d PARAVIRT_TIME_ACCOUNTING \
    -d PVPANIC \
    -e PSI_DEFAULT_DISABLED \
    -d READ_ONLY_THP_FOR_FS \
    -d SECURITY_IPE \
    -d SND_UTIMER \
    -d WATCH_QUEUE \
    -d WATCHDOG \
    -d PCIEASPM_DEFAULT -e PCIEASPM_PERFORMANCE \
    -d WQ_POWER_EFFICIENT_DEFAULT \
    -d X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK \
    -d X86_BUS_LOCK_DETECT \
    -d X86_CPA_STATISTICS \
    -d X86_DECODER_SELFTEST \
    -d X86_5LEVEL \
    -d STACKPROTECTOR_STRONG -e STACKPROTECTOR \
    -d LEGACY_VSYSCALL_XONLY -e LEGACY_VSYSCALL_NONE \
    -d UID16 -d X86_16BIT -d MODIFY_LDT_SYSCALL \
    -d SYSFS_SYSCALL \
    -e STRICT_SIGALTSTACK_SIZE \
    -d KEXEC -d KEXEC_FILE -d CRASH_DUMP \
    -d KFENCE \
    -d INIT_STACK_ALL_ZERO -e INIT_STACK_NONE \
    -d UCLAMP_TASK \
    -d CGROUP_RDMA \
    -d CPUMASK_OFFSTACK -d MAXSMP \
    --set-val NR_CPUS_RANGE_BEGIN 2 \
    --set-val NR_CPUS_RANGE_END 512 \
    --set-val NR_CPUS_DEFAULT 64 \
    --set-val NR_CPUS 512 \
    --set-val NODES_SHIFT 10
}

# =============================================================================
# HARDWARE/DRIVER TRIMMING
# =============================================================================

# Disable laptop-specific drivers
apply_laptop_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
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
}

# Disable DRM/GPU drivers
apply_drm_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d DRM_ACCEL_AMDXDNA \
    -d DRM_AMDGPU \
    -d DRM_APPLETBDRM \
    -d DRM_ARCPGU \
    -d DRM_HISI_HIBMC \
    -d DRM_I915 \
    -d DRM_RADEON \
    -d DRM_XE \
    -d DRM_AST \
    -d DRM_MGAG200 \
    -d DRM_VKMS \
    -d DRM_GMA500
}

# Disable network vendor drivers
apply_network_vendors_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
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
}

# Disable wireless vendor support
apply_wireless_vendors_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d WLAN \
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
}

# Disable unnecessary subsystems
apply_subsystems_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d CAN \
    -d IIO \
    -d INFINIBAND \
    -d BE2NET \
    -d PARPORT \
    -d SSB \
    -d AGP \
    -d ATA_SFF \
    -d ISDN \
    -d NET_FC \
    -d RD_BZIP2 \
    -d RD_LZMA \
    -d RD_LZO \
    -d RD_LZ4 \
    -d FUSION \
    -d MACINTOSH_DRIVERS \
    -d SCSI_PROC_FS \
    -d SCSI_CONSTANTS \
    -d SCSI_LOWLEVEL \
    -d WAN \
    -d 6LOWPAN \
    -d IEEE802154
}

# Disable input devices (keyboards, mice, touchscreens)
apply_input_devices_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d KEYBOARD_ATKBD \
    -d MOUSE_PS2 \
    -d SERIO_I8042 \
    -d INPUT_TOUCHSCREEN
}

# Disable Mellanox ethernet drivers
apply_mellanox_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d MLX4_EN \
    -d MLX5_CORE \
    -d MLXSW_CORE \
    -d MLXFW
}

# Disable platform support
apply_platform_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d CZNIC_PLATFORMS \
    -d MELLANOX_PLATFORM \
    -d SURFACE_PLATFORMS
}

# Disable security features (for performance)
apply_security_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d AMD_MEM_ENCRYPT \
    -d X86_SGX
}

# Disable hardware monitors
apply_hwmon_disable() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d IGB_HWMON \
    -d IXGBE_HWMON \
    -d TIGON3_HWMON \
    -d SCSI_UFS_HWMON \
    -d SENSORS_IIO_HWMON
}

# =============================================================================
# SIZE REDUCTION
# =============================================================================

# Apply kernel size reduction settings
apply_size_reduction() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  _kconfig "$kdir" \
    -d MEMORY_HOTPLUG \
    --set-val LOG_BUF_SHIFT 16 \
    --set-val VGA_ARB_MAX_GPUS 4 \
    --set-val RCU_FANOUT 32
}

# =============================================================================
# COMBINED PROFILES
# =============================================================================

# Minimal configuration (basic optimizations)
apply_minimal_profile() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  apply_new_options "$kdir"
  apply_dead_code_elimination "$kdir"
  apply_debug_symbols_disable "$kdir"
  apply_debug_disable "$kdir"
  apply_tracers_disable "$kdir"
  apply_performance_opts "$kdir"
  apply_compiler_opts "$kdir"
  apply_network_opts "$kdir"
  apply_memory_opts "$kdir"
  apply_size_reduction "$kdir"
}

# Trim profile (aggressive driver/subsystem removal)
apply_trim_profile() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  apply_minimal_profile "$kdir"
  apply_debug_subsystems_disable "$kdir"
  apply_laptop_disable "$kdir"
  apply_drm_disable "$kdir"
  apply_network_vendors_disable "$kdir"
  apply_wireless_vendors_disable "$kdir"
  apply_subsystems_disable "$kdir"
  apply_input_devices_disable "$kdir"
  apply_mellanox_disable "$kdir"
  apply_platform_disable "$kdir"
  apply_hwmon_disable "$kdir"
  apply_security_disable "$kdir"
}

# CachyOS profile (performance-focused with CachyOS defaults)
apply_cachy_profile() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  apply_trim_profile "$kdir"
  apply_clear_defaults "$kdir"
  apply_preemption_opts "$kdir"
}

# Full profile (all optimizations)
apply_full_profile() {
  local kdir="${1:?Kernel source directory required}"
  _validate_kernel_dir "$kdir" || return 1

  apply_cachy_profile "$kdir"
}
