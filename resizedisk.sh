#!/bin/bash

source ./utils/colors.sh

white "Proxmox VM Disk Resize Helper"

# Check for required tools
blue "Checking for required tools..."

sudo apt update -qq
sudo apt install -y cloud-guest-utils lvm2 &>/dev/null

# Show current disk layout
check "Current Disk Layout:"
lsblk
df -h

# List available disks
info "Available Disks:"
DISKS=($(lsblk -d -n -o NAME | grep -v "^sr"))
for i in "${!DISKS[@]}"; do
    SIZE=$(lsblk -d -n -o SIZE "/dev/${DISKS[$i]}")
    echo -e "  [$i] /dev/${DISKS[$i]} (${SIZE})"
done

read -rp "$(echo -e ${BLUE} Select disk number to resize: ${RESET})" DISK_INDEX
DISK="/dev/${DISKS[$DISK_INDEX]}"

# List partitions on selected disk (clean names)
info "Partitions on $DISK:"
PARTS=($(lsblk -ln -o NAME "$DISK" | grep -v "^${DISKS[$DISK_INDEX]}$"))
for i in "${!PARTS[@]}"; do
    SIZE=$(lsblk -n -o SIZE "/dev/${PARTS[$i]}")
    echo -e "  [$i] /dev/${PARTS[$i]} (${SIZE})"
done

read -rp "$(echo -e ${BLUE} Select partition number to grow: ${RESET})" PART_INDEX
PART="/dev/${PARTS[$PART_INDEX]}"

# Grow the partition
info "Growing partition $PART..."
sudo growpart "$DISK" "${PART: -1}" || echo -e "${ERROR} ${RED} growpart failed. Partition may already be full.${RESET}"

# Try resizing PV (if LVM)
info "Trying to resize Physical Volume (if applicable).."
sudo pvresize "$PART" 2>/dev/null

# Detect LV
LV_PATH=$(sudo lvdisplay 2>/dev/null | grep "LV Path" | awk '{print $3}')
if [[ -n "$LV_PATH" ]]; then
    echo -e "${CHECK} ${GREEN} Found Logical Volume: $LV_PATH${RESET}"
    echo -e "${INFO} ${GREEN} Extending Logical Volume...${RESET}"
    sudo lvextend -l +100%FREE "$LV_PATH"
    echo -e "${INFO} ${GREEN} Resizing filesystem on $LV_PATH...${RESET}"
    sudo resize2fs "$LV_PATH"
else
    echo -e "${WARN} ${YELLOW} No LVM detected. Trying to resize filesystem directly on $PART...${RESET}"
    sudo resize2fs "$PART"
fi
# Final check
check "Updated Disk Usage"
df -h
lsblk

check "Done! Your filesystem should now use full disk!"
