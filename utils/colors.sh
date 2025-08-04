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


# Color-only functions with optional newline
green()  { local nl="${2:-\n}"; printf "${GREEN}%s${RESET}${nl}" "$1"; }
yellow() { local nl="${2:-\n}"; printf "${YELLOW}%s${RESET}${nl}" "$1"; }
red()    { local nl="${2:-\n}"; printf "${RED}%s${RESET}${nl}" "$1"; }
blue()   { local nl="${2:-\n}"; printf "${BLUE}%s${RESET}${nl}" "$1"; }
cyan()   { local nl="${2:-\n}"; printf "${CYAN}%s${RESET}${nl}" "$1"; }
white()  { local nl="${2:-\n}"; printf "${WHITE}%s${RESET}${nl}" "$1"; }

# Usage:
# green "Hello"         # prints with newline (default)
# green "Hello" ""      # prints without newline (for spinner)
# green "Hello" "\r"    # prints with carriage return (for spinner)
# ...existing code...


help=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      help=true
      shift
      ;;
    *)
      echo "Unknown option: -h --help"
      exit 1
      ;;
  esac
done


# Help
if [ "$help" = true ]; then
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
