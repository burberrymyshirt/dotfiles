#!/bin/sh

set -eu

GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

AUR_MANAGER="paru"

log_info() {
    printf "%s[INFO]%s %s\n" "$GREEN" "$RESET" "$1"
}

log_error() {
    printf "%s[ERROR]%s %s\n" "$RED" "$RESET" "$1" >&2
    exit 1
}

if [ "$(id -u)" -eq 0 ]; then
    log_error "run as a normal user with sudo"
    exit 1
fi

install_deps() {
    # sudo pacman -Syyu
    sudo pacman -Sy --needed base-devel stow curl wget

    if ! command -v "$AUR_MANAGER" 1>/dev/null 2>&1 ; then
        log_info "$AUR_MANAGER doesn't exist"
    fi
    log_info "paru now exists"
}

install_deps
