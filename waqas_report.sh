#!/bin/bash

# System Report
echo "System Report"
echo "-------------"

USERNAME=$(whoami)
DATE_TIME=$(date)

echo "Username: $USERNAME"
echo "Date and Time: $DATE_TIME"

# System Information
echo "System Information"
echo "------------------"

Hostname=$(hostname)
OS=$(source /etc/os-release && echo "$PRETTY_NAME")
Uptime=$(uptime -p)

echo "Hostname: $Hostname"
echo "Operating System: $OS"
echo "Uptime: $Uptime"

# Hardware Information
echo "Hardware Information"
echo "--------------------"

Cpu=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^ //g')
Ram=$(free -h | grep "Mem:" | awk '{print $2}')
Disk=$(lsblk -d -o NAME,MODEL,SIZE | grep -v "NAME")
Video=$(lshw -C display | grep "product" | sed 's/^ *product: //g')

echo "CPU: $Cpu"
echo "RAM: $Ram"
echo "Disks: $Disk"
echo "Video: $Video"

# Network Information
echo "Network Information"
echo "-------------------"

Fqdn=$(hostname -f)
Host_Address=$(ip route get 1 | awk '{print $7}')
Gateway_Ip=$(ip route | grep default | awk '{print $3}')
Dns_Server=$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}')

echo "FQDN: $Fqdn"
echo "Host Address: $Host_Address"
echo "Gateway IP: $Gateway_Ip"
echo "DNS Server: $Dns_Server"

# System Status
echo "System Status"
echo "-------------"

Users_Logged_In=$(who | awk '{print $1}' | sort | uniq | paste -sd "," -)
Disk_Space=$(df -h --output=target,avail | tail -n +2)
Process_Count=$(ps aux | wc -l)
Load_Averages=$(uptime | awk -F'[a-z]:' '{ print $2}')
Listening_Ports=$(ss -tuln | grep LISTEN | awk '{print $5}')
Ufw_Status=$(sudo ufw status | grep Status | awk '{print $2}')

echo "Users Logged In: $Users_Logged_In"
echo "Disk Space: $Disk_Space"
echo "Process Count: $Process_Count"
echo "Load Averages: $Load_Averages"
echo "Listening Ports: $Listening_Ports"
echo "UFW Status: $Ufw_Status"
