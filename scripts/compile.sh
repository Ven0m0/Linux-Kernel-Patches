#!/usr/bin/env bash
set -euo pipefail

# Store module database
if command -v modprobed-db &>/dev/null; then
  modprobed-db store
else
  echo "Warning: modprobed-db not found, skipping module tracking" >&2
fi

# Build kernel scripts
make scripts

# Performance and scheduling optimizations (batched)
scripts/config \
  -e CACHY \
  -e SCHED_BORE \
  -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE \
  -d HZ_PERIODIC \
  -d NO_HZ_IDLE \
  -d CONTEXT_TRACKING_FORCE \
  -e NO_HZ_FULL_NODEF \
  -e NO_HZ_FULL \
  -e NO_HZ \
  -e NO_HZ_COMMON \
  -e CONTEXT_TRACKING

# Preemption settings
scripts/config \
  -e PREEMPT_DYNAMIC \
  -d PREEMPT \
  -d PREEMPT_VOLUNTARY \
  -e PREEMPT_LAZY \
  -d PREEMPT_NONE

# Compiler optimizations
scripts/config \
  -d CC_OPTIMIZE_FOR_PERFORMANCE \
  -e CC_OPTIMIZE_FOR_PERFORMANCE_O3

# Disable debug features (batched)
scripts/config \
  -d SLUB_DEBUG \
  -d PM_DEBUG \
  -d PM_ADVANCED_DEBUG \
  -d PM_SLEEP_DEBUG \
  -d ACPI_DEBUG \
  -d LATENCYTOP \
  -d SCHED_DEBUG \
  -d DEBUG_PREEMPT \
  -d CRASH_DUMP \
  -d USB_PRINTER \
  -d BPF \
  -d FTRACE \
  -d FUNCTION_TRACER

# Network optimizations (BBR congestion control)
scripts/config \
  -m TCP_CONG_CUBIC \
  -d DEFAULT_CUBIC \
  -e TCP_CONG_BBR \
  -e DEFAULT_BBR \
  --set-str DEFAULT_TCP_CONG bbr \
  -e NET_SCH_FQ_CODEL \
  -e NET_SCH_FQ \
  -e CONFIG_DEFAULT_FQ_CODEL \
  -d CONFIG_DEFAULT_FQ

# Memory optimizations
scripts/config \
  -d TRANSPARENT_HUGEPAGE_MADVISE \
  -e TRANSPARENT_HUGEPAGE_ALWAYS \
  -e USER_NS

# Build configuration
readonly MODPROBED_DB="${HOME}/.config/modprobed.db"
if [[ -f $MODPROBED_DB ]]; then
  yes "" | make LSMOD="$MODPROBED_DB" localmodconfig
else
  echo "Warning: modprobed.db not found at $MODPROBED_DB" >&2
  yes "" | make localmodconfig
fi

make prepare
make -j"$(nproc)" xconfig
