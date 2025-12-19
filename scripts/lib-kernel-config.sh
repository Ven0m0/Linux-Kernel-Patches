#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# Unified Kernel Configuration Library & CLI
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
SCRIPT_DIR=$(cd -P -- "${s%/*}" && pwd)
has(){ command -v -- "$1" &>/dev/null; }

# =============================================================================
# CORE HELPERS
# =============================================================================
_validate_kernel_dir(){ local kdir="${1:?Kernel source directory required}"; [[ -d $kdir && -f $kdir/scripts/config ]] || { printf 'Error: Invalid kernel source: %s\n' "$kdir" >&2; return 1; }; }
_apply_config(){ local kdir="${1:?Kernel dir required}"; shift; _validate_kernel_dir "$kdir" || return 1; "$kdir/scripts/config" "$@"; }

# =============================================================================
# BASIC KERNEL OPTIONS
# =============================================================================
apply_new_options(){ _apply_config "$1" -d DRM_MGAG200_DISABLE_WRITECOMBINE -d GPIO_BT8XX -d INTEL_TDX_HOST -d SND_SE6X; }
apply_dead_code_elimination(){ _apply_config "$1" -e HAVE_LD_DEAD_CODE_DATA_ELIMINATION -e LD_DEAD_CODE_DATA_ELIMINATION; }

# =============================================================================
# DEBUG FEATURE DISABLING
# =============================================================================
apply_debug_symbols_disable(){ _apply_config "$1" -d DEBUG_INFO -d DEBUG_INFO_BTF -d DEBUG_INFO_BTF_MODULES -d DEBUG_INFO_DWARF4 -d PAHOLE_HAS_SPLIT_BTF; }
apply_debug_core_disable(){ _apply_config "$1" -d ACPI_DEBUG -d BPF -d CRASH_DUMP -d FTRACE -d FUNCTION_TRACER -d FUNCTION_ERROR_INJECTION -d GDB_SCRIPTS -d GENERIC_IRQ_DEBUGFS -d GENERIC_IRQ_INJECTION -d GENERIC_IRQ_STAT_SNAPSHOT -d LATENCYTOP -d LEDS_TRIGGER_CPU -d LEDS_TRIGGER_GPIO -d PAGE_POISONING -d PCIE_ECRC -d PCIEAER_INJECT -d PM_ADVANCED_DEBUG -d PM_DEBUG -d PM_SLEEP_DEBUG -d PM_TRACE_RTC -d PRINTK_INDEX -d SCHED_DEBUG -d DEBUG_PREEMPT -d SLUB_DEBUG -d SLUB_DEBUG_ON -d SOFTLOCKUP_DETECTOR_INTR_STORM -d USB_PRINTER; }
apply_debug_subsystems_disable(){ _apply_config "$1" -d 6LOWPAN_DEBUGFS -d AF_RXRPC_DEBUG -d AFS_DEBUG -d AFS_DEBUG_CURSOR -d ATA_VERBOSE_ERROR -d ATH5K_DEBUG -d ATH6KL_DEBUG -d ATH9K_HTC_DEBUGFS -d ATH10K_DEBUG -d ATH10K_DEBUGFS -d ATH12K_DEBUG -d BCACHE_DEBUG -d BCACHEFS_DEBUG -d BEFS_DEBUG -d BLK_DEBUG_FS -d BT_DEBUGFS -d CEPH_LIB_PRETTYDEBUG -d CFG80211_DEBUGFS -d CIFS_DEBUG -d CIFS_DEBUG2 -d CIFS_DEBUG_DUMP_KEYS -d CMA_DEBUGFS -d CROS_EC_DEBUGFS -d CRYPTO_DEV_AMLOGIC_GXL_DEBUG -d CRYPTO_DEV_CCP_DEBUGFS -d DEBUG_KMAP_LOCAL_FORCE_MAP -d DEBUG_MEMORY_INIT -d DEBUG_RODATA_TEST -d DEBUG_RSEQ -d DEBUG_WX -d DLM_DEBUG -d DM_DEBUG_BLOCK_MANAGER_LOCKING -d DM_DEBUG_BLOCK_STACK_TRACING -d DRM_ACCEL_IVPU_DEBUG -d DRM_DEBUG_DP_MST_TOPOLOGY_REFS -d DRM_DEBUG_MODESET_LOCK -d DRM_DISPLAY_DP_TUNNEL_STATE_DEBUG -d DRM_I915_DEBUG -d DRM_I915_DEBUG_GUC -d DRM_I915_DEBUG_MMIO -d DRM_I915_DEBUG_VBLANK_EVADE -d DRM_I915_DEBUG_WAKEREF -d DRM_I915_SW_FENCE_DEBUG_OBJECTS -d DRM_XE_DEBUG -d DRM_XE_DEBUG_MEM -d DRM_XE_DEBUG_MEMIRQ -d DRM_XE_DEBUG_SRIOV -d DRM_XE_DEBUG_VM -d DVB_USB_DEBUG -d EARLY_PRINTK_DBGP -d EARLY_PRINTK_USB_XDBC -d EXT4_DEBUG -d HIST_TRIGGERS_DEBUG -d INFINIBAND_MTHCA_DEBUG -d IWLEGACY_DEBUG -d IWLWIFI_DEBUG -d JFS_DEBUG -d LDM_DEBUG -d LIBERTAS_THINFIRM_DEBUG -d NETFS_DEBUG -d NFS_DEBUG -d NVME_TARGET_DEBUGFS -d NVME_VERBOSE_ERRORS -d OCFS2_DEBUG_FS -d PNP_DEBUG_MESSAGES -d QUOTA_DEBUG -d RTLWIFI_DEBUG -d RTW88_DEBUG -d RTW88_DEBUGFS -d RTW89_DEBUGFS -d RTW89_DEBUGMSG -d SHRINKER_DEBUG -d SMS_SIANO_DEBUGFS -d SND_SOC_SOF_DEBUG -d SUNRPC_DEBUG -d UFS_DEBUG -d USB_DWC2_DEBUG -d VFIO_DEBUGFS -d VIRTIO_DEBUG -d VISL_DEBUGFS -d WCN36XX_DEBUGFS -d WWAN_DEBUGFS -d XEN_DEBUG_FS; }
apply_tracers_disable(){ _apply_config "$1" -d ATH5K_TRACER -d DM_UEVENT -d FTRACE_RECORD_RECURSION -d FTRACE_SORT_STARTUP_TEST -d FTRACE_VALIDATE_RCU_IS_WATCHING -d FUNCTION_PROFILER -d HIST_TRIGGERS -d HWLAT_TRACER -d IRQSOFF_TRACER -d KPROBE_EVENTS_ON_NOTRACE -d LOCK_EVENT_COUNTS -d MMIOTRACE -d MMIOTRACE_TEST -d OSNOISE_TRACER -d PM_DEVFREQ_EVENT -d PREEMPT_TRACER -d PSTORE_FTRACE -d SYNTH_EVENTS -d TIMERLAT_TRACER -d USER_EVENTS; }
apply_debug_disable(){ local kdir="${1:?Kernel dir required}"; apply_debug_symbols_disable "$kdir"; apply_debug_core_disable "$kdir"; apply_debug_subsystems_disable "$kdir"; apply_tracers_disable "$kdir"; }

# =============================================================================
# PERFORMANCE OPTIMIZATIONS
# =============================================================================
apply_performance_opts(){ _apply_config "$1" -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE -d CONTEXT_TRACKING_FORCE -d HZ_PERIODIC -d NO_HZ_IDLE -e CONTEXT_TRACKING -e NO_HZ -e NO_HZ_COMMON -e NO_HZ_FULL -e NO_HZ_FULL_NODEF; }
apply_preemption_opts(){ _apply_config "$1" -d PREEMPT -d PREEMPT_NONE -d PREEMPT_VOLUNTARY -e PREEMPT_DYNAMIC -e PREEMPT_LAZY; }
apply_compiler_opts(){ _apply_config "$1" -d CC_OPTIMIZE_FOR_PERFORMANCE -e CC_OPTIMIZE_FOR_PERFORMANCE_O3; }
apply_network_opts(){ _apply_config "$1" -m TCP_CONG_CUBIC -d DEFAULT_CUBIC -e TCP_CONG_BBR -e DEFAULT_BBR --set-str DEFAULT_TCP_CONG bbr -e NET_SCH_FQ_CODEL -e NET_SCH_FQ -e CONFIG_DEFAULT_FQ_CODEL -d CONFIG_DEFAULT_FQ; }
apply_memory_opts(){ _apply_config "$1" -d TRANSPARENT_HUGEPAGE_MADVISE -e TRANSPARENT_HUGEPAGE_ALWAYS -e USER_NS; }

# =============================================================================
# CLEAR LINUX DEFAULTS (x86 only)
# =============================================================================
apply_clear_defaults(){
  [[ $(uname -m) != *x86* ]] && return 0
  _apply_config "$1" -d CGROUP_RDMA -d CPUMASK_OFFSTACK -d CRASH_DUMP -d DAMON -d HWPOISON_INJECT -d INIT_STACK_ALL_ZERO -d IOMMU_DEFAULT_DMA_LAZY -d KEXEC -d KEXEC_FILE -d KFENCE -d LEGACY_VSYSCALL_XONLY -d MAXSMP -d MODIFY_LDT_SYSCALL -d PCIEASPM_DEFAULT -d PARAVIRT_TIME_ACCOUNTING -d PVPANIC -d READ_ONLY_THP_FOR_FS -d SECURITY_IPE -d SND_UTIMER -d STACKPROTECTOR_STRONG -d SYSFS_SYSCALL -d UCLAMP_TASK -d UID16 -d WATCH_QUEUE -d WATCHDOG -d WQ_POWER_EFFICIENT_DEFAULT -d X86_16BIT -d X86_5LEVEL -d X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK -d X86_BUS_LOCK_DETECT -d X86_CPA_STATISTICS -d X86_DECODER_SELFTEST -e INIT_STACK_NONE -e IOMMU_DEFAULT_PASSTHROUGH -e LEGACY_VSYSCALL_NONE -e PCIEASPM_PERFORMANCE -e PSI_DEFAULT_DISABLED -e STACKPROTECTOR -e STRICT_SIGALTSTACK_SIZE --set-val NR_CPUS 512 --set-val NR_CPUS_DEFAULT 64 --set-val NR_CPUS_RANGE_BEGIN 2 --set-val NR_CPUS_RANGE_END 512 --set-val NODES_SHIFT 10
}

# =============================================================================
# HARDWARE/DRIVER TRIMMING
# =============================================================================
apply_laptop_disable(){ _apply_config "$1" -d CHROMEOS_LAPTOP -d COMPAL_LAPTOP -d DELL_LAPTOP -d EEEPC_LAPTOP -d FUJITSU_LAPTOP -d IDEAPAD_LAPTOP -d LG_LAPTOP -d MSI_LAPTOP -d PANASONIC_LAPTOP -d SAMSUNG_LAPTOP -d SONY_LAPTOP -d TOPSTAR_LAPTOP; }
apply_drm_disable(){ _apply_config "$1" -d DRM_ACCEL_AMDXDNA -d DRM_AMDGPU -d DRM_APPLETBDRM -d DRM_ARCPGU -d DRM_AST -d DRM_GMA500 -d DRM_HISI_HIBMC -d DRM_I915 -d DRM_MGAG200 -d DRM_RADEON -d DRM_VKMS -d DRM_XE; }
apply_network_vendors_disable(){ _apply_config "$1" -d NET_VENDOR_ADI -d NET_VENDOR_AGERE -d NET_VENDOR_AMAZON -d NET_VENDOR_AMD -d NET_VENDOR_AQUANTIA -d NET_VENDOR_ASIX -d NET_VENDOR_ATHEROS -d NET_VENDOR_BROADCOM -d NET_VENDOR_CADENCE -d NET_VENDOR_CHELSIO -d NET_VENDOR_CISCO -d NET_VENDOR_CORTINA -d NET_VENDOR_DAVICOM -d NET_VENDOR_DLINK -d NET_VENDOR_EMULEX -d NET_VENDOR_ENGLEDER -d NET_VENDOR_FUNGIBLE -d NET_VENDOR_GOOGLE -d NET_VENDOR_HISILICON -d NET_VENDOR_HUAWEI -d NET_VENDOR_I825XX -d NET_VENDOR_INTEL -d NET_VENDOR_LITEX -d NET_VENDOR_MARVELL -d NET_VENDOR_MELLANOX -d NET_VENDOR_META -d NET_VENDOR_MICROSOFT -d NET_VENDOR_NETRONOME -d NET_VENDOR_NI -d NET_VENDOR_PACKET_ENGINES -d NET_VENDOR_QLOGIC -d NET_VENDOR_SOCIONEXT -d NET_VENDOR_SOLARFLARE -d NET_VENDOR_STMICRO -d NET_VENDOR_VERTEXCOM -d NET_VENDOR_WANGXUN; }
apply_wireless_vendors_disable(){ _apply_config "$1" -d WLAN -d WLAN_VENDOR_ADMTEK -d WLAN_VENDOR_ATH -d WLAN_VENDOR_ATMEL -d WLAN_VENDOR_BROADCOM -d WLAN_VENDOR_INTEL -d WLAN_VENDOR_INTERSIL -d WLAN_VENDOR_MARVELL -d WLAN_VENDOR_MEDIATEK -d WLAN_VENDOR_PURELIFI -d WLAN_VENDOR_QUANTENNA -d WLAN_VENDOR_RALINK -d WLAN_VENDOR_REALTEK -d WLAN_VENDOR_RSI -d WLAN_VENDOR_SILABS -d WLAN_VENDOR_ST -d WLAN_VENDOR_TI -d WLAN_VENDOR_ZYDAS; }
apply_subsystems_disable(){ _apply_config "$1" -d 6LOWPAN -d AGP -d ATA_SFF -d BE2NET -d CAN -d FUSION -d IEEE802154 -d IIO -d INFINIBAND -d ISDN -d MACINTOSH_DRIVERS -d NET_FC -d PARPORT -d RD_BZIP2 -d RD_LZ4 -d RD_LZMA -d RD_LZO -d SCSI_CONSTANTS -d SCSI_LOWLEVEL -d SCSI_PROC_FS -d SSB -d WAN; }
apply_input_devices_disable(){ _apply_config "$1" -d INPUT_TOUCHSCREEN -d KEYBOARD_ATKBD -d MOUSE_PS2 -d SERIO_I8042; }
apply_mellanox_disable(){ _apply_config "$1" -d MLX4_EN -d MLX5_CORE -d MLXFW -d MLXSW_CORE; }
apply_platform_disable(){ _apply_config "$1" -d CZNIC_PLATFORMS -d MELLANOX_PLATFORM -d SURFACE_PLATFORMS; }
apply_security_disable(){ _apply_config "$1" -d AMD_MEM_ENCRYPT -d X86_SGX; }
apply_hwmon_disable(){ _apply_config "$1" -d IGB_HWMON -d IXGBE_HWMON -d SCSI_UFS_HWMON -d SENSORS_IIO_HWMON -d TIGON3_HWMON; }

# =============================================================================
# SIZE REDUCTION
# =============================================================================
apply_size_reduction(){ _apply_config "$1" -d MEMORY_HOTPLUG --set-val LOG_BUF_SHIFT 16 --set-val RCU_FANOUT 32 --set-val VGA_ARB_MAX_GPUS 4; }

# =============================================================================
# COMBINED PROFILES
# =============================================================================
apply_minimal_profile(){ local kdir="${1:?Kernel dir required}"; apply_new_options "$kdir"; apply_dead_code_elimination "$kdir"; apply_debug_disable "$kdir"; apply_performance_opts "$kdir"; apply_compiler_opts "$kdir"; apply_network_opts "$kdir"; apply_memory_opts "$kdir"; apply_size_reduction "$kdir"; }
apply_trim_profile(){ local kdir="${1:?Kernel dir required}"; apply_minimal_profile "$kdir"; apply_laptop_disable "$kdir"; apply_drm_disable "$kdir"; apply_network_vendors_disable "$kdir"; apply_wireless_vendors_disable "$kdir"; apply_subsystems_disable "$kdir"; apply_input_devices_disable "$kdir"; apply_mellanox_disable "$kdir"; apply_platform_disable "$kdir"; apply_hwmon_disable "$kdir"; apply_security_disable "$kdir"; }
apply_cachy_profile(){ local kdir="${1:?Kernel dir required}"; apply_trim_profile "$kdir"; apply_clear_defaults "$kdir"; apply_preemption_opts "$kdir"; }
apply_full_profile(){ apply_cachy_profile "$1"; }

# =============================================================================
# CLI INTERFACE (only runs when executed directly, not sourced)
# =============================================================================
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m' DEF=$'\e[0m'
  info(){ printf '%b\n' "${GRN}$*${DEF}"; }
  warn(){ printf '%b\n' "${YLW}$*${DEF}"; }
  error(){ printf '%b\n' "${RED}Error: $*${DEF}" >&2; }
  die(){ error "$*"; exit 1; }

  usage(){
    cat <<EOF
${BLU}Unified Kernel Configuration${DEF}
${GRN}Usage:${DEF} $(basename "$0") [OPTIONS] <kernel_src_dir>
${GRN}Options:${DEF}
  --mode=MODE, -m MODE  Configuration mode (default: full)
  --help, -h            Show this help
${GRN}Modes:${DEF}
  minimal   Basic optimizations + debug disabling
  trim      Aggressive driver trimming
  cachy     CachyOS-optimized performance
  full      All optimizations (default)
${GRN}Examples:${DEF}
  $(basename "$0") --mode=minimal /usr/src/linux-6.18
  $(basename "$0") -m cachy /usr/src/linux-6.18
  $(basename "$0") /usr/src/linux-6.18
${GRN}Notes:${DEF}
  - Requires scripts/config in kernel source tree
  - Run 'make scripts' first if needed
  - Can also be sourced as a library in other scripts
EOF
  }

  MODE=full KERNEL_DIR=
  while [[ $# -gt 0 ]]; do
    case $1 in
      --mode=*) MODE=${1#*=}; shift ;;
      -m) MODE=${2:?Mode required}; shift 2 ;;
      --help|-h) usage; exit 0 ;;
      -*) die "Unknown option: $1" ;;
      *) KERNEL_DIR=$1; shift ;;
    esac
  done

  [[ -n $KERNEL_DIR ]] || { error "Kernel source directory required"; echo; usage; exit 1; }
  [[ -d $KERNEL_DIR ]] || die "Directory not found: $KERNEL_DIR"
  [[ -f $KERNEL_DIR/scripts/config ]] || die "Not a kernel source tree: $KERNEL_DIR"
  [[ $MODE =~ ^(minimal|trim|cachy|full)$ ]] || die "Invalid mode: $MODE"

  info "Unified Kernel Configuration"; info "Mode: ${YLW}${MODE}${DEF}"; info "Kernel source: ${YLW}${KERNEL_DIR}${DEF}"; echo
  cd "$KERNEL_DIR" || die "Cannot enter: $KERNEL_DIR"
  [[ -x scripts/config ]] || { info "Building kernel scripts..."; make scripts || die "Failed to build scripts"; }
  [[ -f ${SCRIPT_DIR}/utils/sort-modprobed-dbs ]] && { info "Sorting modprobed databases..."; "${SCRIPT_DIR}/utils/sort-modprobed-dbs" || warn "Failed to sort modprobed databases"; }

  info "Applying ${MODE} configuration..."
  case $MODE in
    minimal) apply_minimal_profile "$KERNEL_DIR" ;;
    trim) apply_trim_profile "$KERNEL_DIR" ;;
    cachy) apply_cachy_profile "$KERNEL_DIR" ;;
    full) apply_full_profile "$KERNEL_DIR" ;;
  esac

  echo; info "Configuration complete!"; info "Next steps:"; echo "  1. make menuconfig"; echo "  2. make -j\$(nproc)"; echo "  3. sudo make modules_install"; echo "  4. sudo make install"
fi
