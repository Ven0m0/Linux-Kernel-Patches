#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'

# =============================================================================
# Unified AutoFDO-Optimized Kernel Build Script
# Builds kernel with Profile-Guided Optimization using AutoFDO
# =============================================================================

# Color codes
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
readonly BLU=$'\e[34m' CYN=$'\e[36m' BLD=$'\e[1m'

# Helper functions
has() { command -v -- "$1" &>/dev/null; }
die() { printf '%b\n' "${RED}Error:${DEF} $*" >&2; exit 1; }
info() { printf '%b\n' "${GRN}$*${DEF}"; }
warn() { printf '%b\n' "${YLW}$*${DEF}"; }
msg() { printf '%b\n' "${CYN}$*${DEF}"; }

# Configuration
readonly WORKDIR="${AUTOFDO_WORKDIR:-${HOME}/profiling}"
readonly DIR="${HOME}/projects/kernel"
readonly KERNELDIR="${DIR}/linux/linux-cachyos/linux-cachyos"
readonly NPROC=$(nproc)

# Mode selection
MODE="${1:-full}"

# Export LLVM flags
export LLVM=1 LLVM_IAS=1

# =============================================================================
# Functions
# =============================================================================

setup_profiling() {
    info "Setting up profiling permissions..."
    sudo sh -c "echo 0 > /proc/sys/kernel/kptr_restrict"
    sudo sh -c "echo 0 > /proc/sys/kernel/perf_event_paranoid"
}

install_dependencies() {
    info "Installing dependencies..."
    sudo pacman -S --needed --noconfirm perf cachyos-benchmarker llvm clang sysbench
}

run_benchmarks() {
    local workdir="${1:-$WORKDIR}"

    info "Creating working directory: ${workdir}"
    mkdir -p "${workdir}"
    cd "${workdir}"

    info "Running CachyOS benchmarker..."
    cachyos-benchmarker "${workdir}"

    info "Running Sysbench tests..."

    # CPU and memory benchmarks in parallel (independent workloads)
    msg "Running CPU and memory benchmarks (parallelized)..."
    sysbench cpu --time=30 --cpu-max-prime=50000 --threads="${NPROC}" run &
    local pid_cpu=$!
    sysbench memory --memory-block-size=1M --memory-total-size=16G run &
    local pid_mem1=$!
    sysbench memory --memory-block-size=1M --memory-total-size=16G --memory-oper=read --num-threads=16 run &
    local pid_mem2=$!

    # Wait for parallel benchmarks to complete
    wait $pid_cpu $pid_mem1 $pid_mem2
    info "CPU and memory benchmarks completed."

    # I/O benchmarks must run sequentially (prepare → test → cleanup)
    msg "Running I/O benchmarks (sequential)..."
    sysbench fileio --file-total-size=5G --file-num=5 prepare
    sysbench fileio --file-total-size=5G --file-num=5 --file-fsync-freq=0 --file-test-mode=rndrd --file-block-size=4K run
    sysbench fileio --file-total-size=5G --file-num=5 --file-fsync-freq=0 --file-test-mode=seqwr --file-block-size=1M run
    sysbench fileio --file-total-size=5G --file-num=5 cleanup
    info "I/O benchmarks completed."

    # Additional miscellaneous tests
    msg "Running miscellaneous tests..."

    # Find conf files (silenced output)
    find / -type f -name "*.conf" > /dev/null 2>&1 || true

    # Search patterns with ripgrep if available
    if has rg; then
        rg test || true
        rg KERNEL || true
        rg sched || true
        rg fair || true
    fi

    info "All benchmarks completed."
}

build_baseline_kernel() {
    info "Building baseline kernel for profiling..."

    sudo -v
    mkdir -p "$KERNELDIR" && cd "$KERNELDIR" || die "Failed to create kernel directory"

    # Clone kernel source
    if [[ ! -d linux ]]; then
        git clone --depth=1 --single-branch -b 6.17/cachy https://github.com/CachyOS/linux.git
    fi

    cd linux || die "Failed to enter linux directory"

    # Configure kernel
    zcat /proc/config.gz > .config
    make LLVM=1 LLVM_IAS=1 prepare

    # Enable AutoFDO and LTO
    scripts/config -e CONFIG_AUTOFDO_CLANG -e CONFIG_LTO_CLANG_THIN

    # Build kernel
    info "Building baseline kernel (this will take a while)..."
    make LLVM=1 LLVM_IAS=1 pacman-pkg -j"${NPROC}"

    # Install baseline kernel
    local pkgver="${pkgver:-unknown}"
    [[ $pkgver != unknown ]] && rm -f linux-upstream-api-headers-"${pkgver}"*.tar.zst

    if compgen -G "linux-upstream-*.tar.zst" > /dev/null; then
        sudo pacman -U --noconfirm linux-upstream{,-headers,-debug}-*.tar.zst
    else
        warn "No baseline kernel packages found to install"
    fi
}

generate_autofdo_profile() {
    info "Generating AutoFDO profile..."

    cd "$KERNELDIR" || die "Failed to enter kernel directory"

    # Clone linux-cachyos for profiling if not exists
    if [[ ! -d linux-cachyos/linux-cachyos ]]; then
        git clone --depth=1 --single-branch https://github.com/cachyos/linux-cachyos
    fi

    cd linux-cachyos/linux-cachyos || die "Failed to enter linux-cachyos directory"

    # Setup profiling
    setup_profiling

    # Run benchmarks for profiling
    run_benchmarks "$KERNELDIR"

    # Record perf data during kernel build
    local VM_PATH="/usr/lib/modules/$(uname -r)/build/vmlinux"
    local AUTOPROF="${KERNELDIR}/kernel-compilation.afdo"

    if [[ ! -f "$VM_PATH" ]]; then
        warn "vmlinux not found at ${VM_PATH}, using alternative path"
        VM_PATH="/usr/lib/modules/$(uname -r)/vmlinux"
    fi

    info "Recording performance data..."
    perf record --pfm-events BR_INST_RETIRED.NEAR_TAKEN:k -a -N -b -c 500009 -o kernel.data -- time makepkg -sfci --skipinteg

    info "Creating LLVM AutoFDO profile..."
    ./create_llvm_prof --binary="$VM_PATH" --profile="${KERNELDIR}/kernel.data" --format=extbinary --out="$AUTOPROF"

    info "AutoFDO profile generated: ${AUTOPROF}"
}

build_optimized_kernel() {
    info "Building optimized kernel with AutoFDO profile..."

    local AUTOPROF="${KERNELDIR}/kernel-compilation.afdo"

    [[ ! -f "$AUTOPROF" ]] && die "AutoFDO profile not found: ${AUTOPROF}"

    cd "${DIR}/linux" || {
        mkdir -p "${DIR}/linux"
        cd "${DIR}/linux"
        git clone --depth=1 -b 6.12/base git@github.com:CachyOS/linux.git .
    }

    make clean
    info "Building with AutoFDO profile (this will take a while)..."
    make LLVM=1 LLVM_IAS=1 CLANG_AUTOFDO_PROFILE="$AUTOPROF" pacman-pkg -j"${NPROC}"

    info "Optimized kernel build complete!"
}

show_usage() {
    cat <<EOF
${BLD}Unified AutoFDO Kernel Build Script${DEF}

${BLD}USAGE:${DEF}
    $0 [MODE]

${BLD}MODES:${DEF}
    ${GRN}full${DEF}        - Complete AutoFDO workflow (default)
                  1. Install dependencies
                  2. Build baseline kernel
                  3. Generate AutoFDO profile
                  4. Build optimized kernel

    ${GRN}benchmark${DEF}   - Run benchmarks only (for profiling)

    ${GRN}profile${DEF}     - Generate AutoFDO profile only
                  (assumes baseline kernel is installed)

    ${GRN}build${DEF}       - Build optimized kernel with existing profile
                  (assumes AutoFDO profile exists)

    ${GRN}help${DEF}        - Show this help message

${BLD}ENVIRONMENT VARIABLES:${DEF}
    ${CYN}AUTOFDO_WORKDIR${DEF}  - Working directory for profiling (default: ~/profiling)

${BLD}EXAMPLES:${DEF}
    # Full AutoFDO build workflow
    $0 full

    # Run benchmarks only
    $0 benchmark

    # Generate profile with custom workdir
    AUTOFDO_WORKDIR=/tmp/profiling $0 profile

    # Build optimized kernel
    $0 build

EOF
}

# =============================================================================
# Main
# =============================================================================

main() {
    case "$MODE" in
        full)
            info "Starting full AutoFDO workflow..."
            install_dependencies
            build_baseline_kernel
            generate_autofdo_profile
            build_optimized_kernel
            info "Full AutoFDO workflow completed successfully!"
            ;;
        benchmark)
            info "Running benchmarks only..."
            install_dependencies
            run_benchmarks "$WORKDIR"
            ;;
        profile)
            info "Generating AutoFDO profile..."
            install_dependencies
            generate_autofdo_profile
            ;;
        build)
            info "Building optimized kernel..."
            build_optimized_kernel
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            die "Unknown mode: ${MODE}\nRun '$0 help' for usage information."
            ;;
    esac
}

main "$@"
