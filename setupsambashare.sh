#!/bin/bash

source ./utils/colors.sh

white "Samba Network Share Setup Wizard"

# 1. Update & install samba (less verbose)
info "Updating system and installing samba..."
sudo apt update -qq &>/dev/null
sudo apt install -y samba &>/dev/null

# 2. Ask for username
echo -ne "${BLUE} Enter a username for Samba (no spaces): ${RESET}"
read -r SMB_USER

# 3. Create Linux user (no login, no home)
info "Creating Linux user '$SMB_USER' (no login, no home)..."
sudo adduser --no-create-home --disabled-login --shell /usr/sbin/nologin "$SMB_USER" &>/dev/null

# 4. Set samba password
info "Set a password for the Samba user '$SMB_USER':"
sudo smbpasswd -a "$SMB_USER"

# 5. Ask for share name and path
echo -ne "${BLUE} Enter a name for the Samba share: ${RESET}"
read -r SHARE_NAME
echo -ne "${BLUE} Enter the full path to the directory to share (will be created if missing): ${RESET}"
read -r SHARE_PATH

# 6. Create directory if missing
if [ ! -d "$SHARE_PATH" ]; then
    info "Creating directory $SHARE_PATH..."
    sudo mkdir -p "$SHARE_PATH"
fi

# 7. Backup smb.conf
info "Backing up /etc/samba/smb.conf to /etc/samba/smb.bk ..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.bk

# 8. Add share config to smb.conf
info "Adding share configuration to smb.conf..."
sudo bash -c "cat >> /etc/samba/smb.conf" <<EOF

[$SHARE_NAME]
  path = $SHARE_PATH
  valid users = $SMB_USER
  read only = no
  writable = yes
  browsable = yes
  create mask = 0660
  directory mask = 0770
EOF

# 9. Set permissions
info "Setting permissions for $SHARE_PATH..."
sudo chmod -R 777 "$SHARE_PATH"
sudo chown -R "$SMB_USER":"$SMB_USER" "$SHARE_PATH"

# 10. Restart samba and test config
info "Restarting Samba service..."
sudo systemctl restart smbd.service

info "Testing Samba configuration..."
if testparm -s &>/dev/null; then
    check "Samba configuration is valid!"
else
    error "Samba configuration has errors. Please check /etc/samba/smb.conf."
    exit 1
fi

# 11. Show connection info
IP=$(hostname -I | awk '{print $1}')
check "Samba share '$SHARE_NAME' is ready!"
info "To connect from Windows: \\\\$IP\\$SHARE_NAME"
info "To connect from Linux: see 'Mount Samba Drive