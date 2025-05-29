#!/usr/bin/env bash

set -e

modprobed-db store

make scripts

scripts/config -e CACHY
scripts/config -e SCHED_BORE
scripts/config -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE
scripts/config -d HZ_PERIODIC -d NO_HZ_IDLE -d CONTEXT_TRACKING_FORCE -e NO_HZ_FULL_NODEF -e NO_HZ_FULL -e NO_HZ -e NO_HZ_COMMON -e CONTEXT_TRACKING
scripts/config -e PREEMPT_DYNAMIC -d PREEMPT -d PREEMPT_VOLUNTARY -e PREEMPT_LAZY -d PREEMPT_NONE
scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE -e CC_OPTIMIZE_FOR_PERFORMANCE_O3
scripts/config -d SLUB_DEBUG
scripts/config -d PM_DEBUG
scripts/config -d PM_ADVANCED_DEBUG
scripts/config -d PM_SLEEP_DEBUG
scripts/config -d ACPI_DEBUG
scripts/config -d LATENCYTOP
scripts/config -d SCHED_DEBUG
scripts/config -d DEBUG_PREEMPT
scripts/config -m TCP_CONG_CUBIC \
            -d DEFAULT_CUBIC \
            -e TCP_CONG_BBR \
            -e DEFAULT_BBR \
            --set-str DEFAULT_TCP_CONG bbr \
            -e NET_SCH_FQ_CODEL \
            -e NET_SCH_FQ \
            -e CONFIG_DEFAULT_FQ_CODEL \
            -d CONFIG_DEFAULT_FQ
scripts/config -d TRANSPARENT_HUGEPAGE_MADVISE -e TRANSPARENT_HUGEPAGE_ALWAYS
scripts/config -e USER_NS
# Disable kernel debugging
scripts/config --disable CRASH_DUMP
scripts/config --disable USB_PRINTER

# Disable BPF/Tracers if not needed
scripts/config --disable BPF
scripts/config --disable FTRACE
scripts/config --disable FUNCTION_TRACER

yes "" | make LSMOD="${HOME}"/.config/modprobed.db localmodconfig
make prepare
make -j"$(nproc)" xconfig
