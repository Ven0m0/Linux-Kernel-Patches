#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
IFS=$'\n\t'

# =============================================================================
# Unified Docker-based Kernel Build Script
# Builds kernels for different architectures using Docker
# =============================================================================

# Color codes
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
readonly BLU=$'\e[34m' CYN=$'\e[36m' BLD=$'\e[1m'

# Helper functions
die() { printf '%b\n' "${RED}Error:${DEF} $*" >&2; exit 1; }
info() { printf '%b\n' "${GRN}$*${DEF}"; }
warn() { printf '%b\n' "${YLW}$*${DEF}"; }
msg() { printf '%b\n' "${CYN}$*${DEF}"; }

# Configuration
readonly REPO_BASE="${REPO_BASE:-/home/ptr1337/.docker/build/nginx/www/repo}"
readonly DOCKER_IMAGE_BASE="${DOCKER_IMAGE_BASE:-pttrr/docker-makepkg}"

# Architecture targets
readonly ARCH_GENERIC="x86_64"
readonly ARCH_V3="x86_64_v3"
readonly ARCH_V4="x86_64_v4"

# =============================================================================
# Functions
# =============================================================================

configure_pkgbuild() {
    local processor_opt="$1"
    local use_auto_opt="$2"
    local build_zfs="$3"
    local build_nvidia_open="$4"
    local use_llvm_lto="$5"

    info "Configuring PKGBUILD: processor=${processor_opt}, auto_opt=${use_auto_opt}, zfs=${build_zfs}, nvidia=${build_nvidia_open}, lto=${use_llvm_lto}"

    find . -name "PKGBUILD" -exec sed -i \
        -e "s/_processor_opt:=.*/_processor_opt:=${processor_opt}/" \
        -e "s/_use_auto_optimization:=.*/_use_auto_optimization:=${use_auto_opt}/" \
        -e "s/_build_zfs:=.*/_build_zfs:=${build_zfs}/" \
        -e "s/_build_nvidia_open:=.*/_build_nvidia_open:=${build_nvidia_open}/" \
        -e "s/_use_llvm_lto:=.*/_use_llvm_lto:=${use_llvm_lto}/" \
        {} +
}

build_with_docker() {
    local docker_image="$1"
    local arch_suffix="$2"

    info "Building kernels with ${docker_image}..."

    local files
    files=$(find . -name "PKGBUILD")

    if [[ -z "$files" ]]; then
        warn "No PKGBUILD files found in current directory"
        return 1
    fi

    for f in $files; do
        local dir
        dir=$(dirname "$f")
        msg "Building in: ${dir}"

        cd "$dir" || continue

        if ! time docker run --name kernelbuild \
            -e EXPORT_PKG=1 \
            -e SYNC_DATABASE=1 \
            -e CHECKSUMS=1 \
            -v "$PWD:/pkg" \
            "$docker_image"; then
            warn "Build failed in ${dir}"
        fi

        docker rm kernelbuild 2>/dev/null || true
        cd - > /dev/null || exit
    done
}

move_packages() {
    local arch="$1"
    local repo_name="$2"
    local pattern="$3"

    local repo_path="${REPO_BASE}/${arch}/${repo_name}/"

    info "Moving packages to ${repo_path}..."

    if [[ ! -d "$repo_path" ]]; then
        warn "Repository path does not exist: ${repo_path}"
        return 1
    fi

    if compgen -G "*/${pattern}" > /dev/null; then
        mv */"${pattern}" "$repo_path"
    else
        warn "No packages found matching pattern: ${pattern}"
    fi
}

update_repo() {
    local repo_name="$1"

    info "Updating repository: ${repo_name}..."
    RUST_LOG=trace repo-manage-util -p "${repo_name}" update || warn "Repository update failed for ${repo_name}"

    # Run twice to ensure all packages are caught
    msg "Running secondary repository update..."
    RUST_LOG=trace repo-manage-util -p "${repo_name}" update || warn "Secondary repository update failed for ${repo_name}"
}

build_generic() {
    msg "${BLD}Building Generic x86_64 Kernel${DEF}"

    configure_pkgbuild "GENERIC" "no" "yes" "yes" "thin"
    build_with_docker "${DOCKER_IMAGE_BASE}" "${ARCH_GENERIC}"
    move_packages "${ARCH_GENERIC}" "cachyos" "*-x86_64.pkg.tar.zst*"
    update_repo "cachyos"
}

build_v3() {
    msg "${BLD}Building x86_64_v3 Kernels${DEF}"

    # GCC v3 Kernel
    info "Building GCC variant for v3..."
    configure_pkgbuild "GENERIC_V3" "no" "yes" "yes" "none"
    build_with_docker "${DOCKER_IMAGE_BASE}-v3" "${ARCH_V3}"

    # LLVM ThinLTO v3 Kernel
    info "Building LLVM ThinLTO variant for v3..."
    configure_pkgbuild "GENERIC_V3" "no" "yes" "yes" "thin"
    build_with_docker "${DOCKER_IMAGE_BASE}-v3" "${ARCH_V3}"

    move_packages "${ARCH_V3}" "cachyos-v3" "*-x86_64_v3.pkg.tar.zst*"
    update_repo "cachyos-v3"
}

build_v4() {
    msg "${BLD}Building x86_64_v4 Kernels${DEF}"

    # GCC v4 Kernel
    info "Building GCC variant for v4..."
    configure_pkgbuild "GENERIC_V4" "no" "yes" "yes" "none"
    build_with_docker "${DOCKER_IMAGE_BASE}-v4" "${ARCH_V4}"

    # LLVM ThinLTO v4 Kernel
    info "Building LLVM ThinLTO variant for v4..."
    configure_pkgbuild "GENERIC_V4" "no" "yes" "yes" "thin"
    build_with_docker "${DOCKER_IMAGE_BASE}-v4" "${ARCH_V4}"

    move_packages "${ARCH_V4}" "cachyos-v4" "*-x86_64_v4.pkg.tar.zst*"
    update_repo "cachyos-v4"
}

build_all() {
    info "${BLD}Building all kernel variants${DEF}"
    build_generic
    build_v3
    build_v4
    info "All kernel builds completed!"
}

show_usage() {
    cat <<EOF
${BLD}Unified Docker-based Kernel Build Script${DEF}

${BLD}USAGE:${DEF}
    $0 [TARGET]

${BLD}TARGETS:${DEF}
    ${GRN}generic${DEF}  - Build generic x86_64 kernel
    ${GRN}v3${DEF}       - Build x86_64_v3 kernels (GCC + LLVM variants)
    ${GRN}v4${DEF}       - Build x86_64_v4 kernels (GCC + LLVM variants)
    ${GRN}all${DEF}      - Build all kernel variants (default)
    ${GRN}help${DEF}     - Show this help message

${BLD}ENVIRONMENT VARIABLES:${DEF}
    ${CYN}REPO_BASE${DEF}           - Base repository path
                        (default: /home/ptr1337/.docker/build/nginx/www/repo)
    ${CYN}DOCKER_IMAGE_BASE${DEF}  - Base Docker image name
                        (default: pttrr/docker-makepkg)

${BLD}EXAMPLES:${DEF}
    # Build all kernels
    $0 all

    # Build only generic kernel
    $0 generic

    # Build only v3 variants
    $0 v3

    # Build with custom repo path
    REPO_BASE=/custom/path $0 generic

${BLD}NOTES:${DEF}
    - Builds are performed in Docker containers
    - Each architecture variant builds both GCC and LLVM versions
    - Packages are automatically moved to the repository
    - Repository database is updated after builds

EOF
}

# =============================================================================
# Main
# =============================================================================

main() {
    local target="${1:-all}"

    case "$target" in
        generic)
            build_generic
            ;;
        v3)
            build_v3
            ;;
        v4)
            build_v4
            ;;
        all)
            build_all
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            die "Unknown target: ${target}\nRun '$0 help' for usage information."
            ;;
    esac

    info "Build process completed successfully!"
}

main "$@"
