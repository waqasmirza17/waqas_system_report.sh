#!/bin/bash

echo "Starting the assignment2.sh script"

echo "Setting up network configuration for 192.168.16.21"
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

if ! grep -q "192.168.16.21" $NETPLAN_FILE; then
    cp $NETPLAN_FILE "${NETPLAN_FILE}.bak"
   
    sed -i 's/address: .*/address: 192.168.16.21\/24/' $NETPLAN_FILE
    echo "Network configuration updated to 192.168.16.21"

    
    netplan apply || handle_error "Failed to apply netplan configuration"
else
    echo "Network configuration already set to 192.168.16.21"
fi

echo "Updating /etc/hosts file"
if ! grep -q "192.168.16.21" /etc/hosts; then
    sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
    echo "/etc/hosts file updated"
else
    echo "/etc/hosts already contains the correct entry"
fi

echo "Checking and installing the required software"


if ! dpkg -l | grep -q apache2; then
    apt-get update && apt-get install -y apache2 || handle_error "Failed to install apache2"
    echo "apache2 installed"
else
    echo "apache2 is already installed"
fi

if ! dpkg -l | grep -q squid; then
    apt-get install -y squid || handle_error "Failed to install squid"
    echo "squid installed"
else
    echo "squid is already installed"
fi

echo "Creating users and configuring SSH keys"
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"


for USER in "${USERS[@]}"; do
    if id "$USER" &>/dev/null; then
        echo "$USER already exists"
    else
        echo "Creating user $USER"
        useradd -m -s /bin/bash $USER || handle_error "Failed to create user $USER"
        
        
        mkdir -p /home/$USER/.ssh
        echo "$PUBLIC_KEY" >> /home/$USER/.ssh/authorized_keys
        chown -R $USER:$USER /home/$USER/.ssh
        echo "User $USER created and SSH key added"
    fi
done

usermod -aG sudo dennis || handle_error "Failed to add dennis to sudo group"
echo "User dennis added to sudo group"

echo "All user accounts and SSH keys configured"

echo "assignment2.sh script completed"

