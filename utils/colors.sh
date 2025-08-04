#!/bin/bash

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

# Emojis
CHECK="✅ "
WARN="⚠️ "
INFO="ℹ️ "
ERROR="❌ "

# Status functions
check() { printf "${CHECK}${GREEN}%s${RESET}\n" "$1"; }
warn()  { printf "${WARN} ${YELLOW}%s${RESET}\n" "$1"; }
info()  { printf "${INFO} ${CYAN}%s${RESET}\n" "$1"; }
error() { printf "${ERROR}${RED}%s${RESET}\n" "$1"; }

# Color-only functions
green()  { printf "${GREEN}%s${RESET}\n" "$1"; }
yellow() { printf "${YELLOW}%s${RESET}\n" "$1"; }
red()    { printf "${RED}%s${RESET}\n" "$1"; }
blue()   { printf "${BLUE}%s${RESET}\n" "$1"; }
cyan()   { printf "${CYAN}%s${RESET}\n" "$1"; }
white()  { printf "${WHITE}%s${RESET}\n" "$1"; }

# Help
if [[ $1 == "--help" ]]; then
  white "---------------------------"
  info "Available Functions"
  white "---------------------------"

  check "check \$1"
  warn "warn \$1"
  info "info \$1"
  error "error \$1"
  printf "\n"
  green "green \$1"
  yellow "yellow \$1"
  red "red \$1"
  blue "blue \$1"
  cyan "cyan \$1"
  white "white \$1"
  white "---------------------------"
fi
