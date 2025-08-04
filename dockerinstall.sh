#!/bin/bash

source ./utils/colors.sh

white "Docker & Portainer Installer"

# Update & Upgrade (less verbose)
info "Updating system packages..."
sudo apt update -qq &>/dev/null
sudo apt upgrade -y &>/dev/null

# Install dependencies (less verbose)
info "Installing dependencies..."
sudo apt install -y ca-certificates curl gnupg lsb-release &>/dev/null

# Add Docker GPG key (less verbose)
info "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings &>/dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &>/dev/null

# Add Docker repository (less verbose)
info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker & Compose plugin (less verbose)
info "Installing Docker Engine and Compose plugin..."
sudo apt update -qq &>/dev/null
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>/dev/null

# Verify Docker install
if docker --version &>/dev/null && docker compose version &>/dev/null; then
    check "Docker and Docker Compose installed successfully!"
else
    error "Docker installation failed!"
    exit 1
fi

# Ask user if they want to install Portainer
read -rp "$(echo -e ${BLUE} Do you want to install Portainer? [y/N]: ${RESET})" INSTALL_PORTAINER
INSTALL_PORTAINER=${INSTALL_PORTAINER,,} # to lowercase

if [[ "$INSTALL_PORTAINER" == "y" || "$INSTALL_PORTAINER" == "yes" ]]; then
    info "Creating Portainer volume..."
    docker volume create portainer_data &>/dev/null

    info "Running Portainer container..."
    docker run -d \
      -p 8000:8000 -p 9443:9443 \
      --name portainer \
      --restart=always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest &>/dev/null

    # Wait a few seconds for container to start
    sleep 5

    # Verify Portainer is running
    if docker ps --format '{{.Names}}' | grep -q '^portainer$'; then
        check "Portainer is running! Access at https://<your-server-ip>:9443"
    else
        error "Portainer failed to start."
    fi
else
    warn "Portainer installation skipped."
fi

check "Docker installation complete!"