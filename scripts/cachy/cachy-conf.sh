#!/usr/bin/env bash
# CachyOS performance configuration for Linux kernel

set -euo pipefail

# Performance and scheduling optimizations (batched)
scripts/config \
  -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE \
  -d HZ_PERIODIC \
  -d NO_HZ_IDLE \
  -d CONTEXT_TRACKING_FORCE \
  -e NO_HZ_FULL_NODEF \
  -e NO_HZ_FULL \
  -e NO_HZ \
  -e NO_HZ_COMMON \
  -e CONTEXT_TRACKING

# Preemption settings (batched)
scripts/config \
  -e PREEMPT_DYNAMIC \
  -d PREEMPT \
  -d PREEMPT_VOLUNTARY \
  -e PREEMPT_LAZY \
  -d PREEMPT_NONE

# Compiler optimization
scripts/config \
  -d CC_OPTIMIZE_FOR_PERFORMANCE \
  -e CC_OPTIMIZE_FOR_PERFORMANCE_O3

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

# Memory optimization
scripts/config \
  -d TRANSPARENT_HUGEPAGE_MADVISE \
  -e TRANSPARENT_HUGEPAGE_ALWAYS
