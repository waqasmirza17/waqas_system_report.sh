#!/usr/bin/env bash

trap '' TERM HUP INT

VERBOSE=false
NEW_HOSTNAME=""
NEW_IP=""
HOSTENTRY_NAME=""
HOSTENTRY_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -verbose)
      VERBOSE=true
      shift
      ;;
    -name)
      NEW_HOSTNAME="$2"
      shift 2
      ;;
    -ip)
      NEW_IP="$2"
      shift 2
      ;;
    -hostentry)
      HOSTENTRY_NAME="$2"
      HOSTENTRY_IP="$3"
      shift 3
      ;;
    *)
      if $VERBOSE; then
        echo "Warning: Unrecognized option $1"
      fi
      shift
      ;;
  esac
done

logv() {
  if $VERBOSE; then
    echo "$@"
  fi
}

log_change() {
  logger "[configure-host.sh] $1"
  logv "$1"
}

if [[ -n "$NEW_HOSTNAME" ]]; then
  CURRENT_HOSTNAME="$(hostname)"
  if [[ "$CURRENT_HOSTNAME" != "$NEW_HOSTNAME" ]]; then
    # Update the hostname
    echo "$NEW_HOSTNAME" > /etc/hostname
    
    
    hostnamectl set-hostname "$NEW_HOSTNAME"
    
    log_change "Hostname changed from '$CURRENT_HOSTNAME' to '$NEW_HOSTNAME'"
  else
    logv "Hostname is already '$NEW_HOSTNAME'; no change needed."
  fi
  
  # New Hostname
  if ! grep -q "127.0.1.1\s\+$NEW_HOSTNAME" /etc/hosts; then
    sed -i "/127.0.1.1\s\+$CURRENT_HOSTNAME/d" /etc/hosts
    sed -i "/127.0.1.1\s\+$NEW_HOSTNAME/d" /etc/hosts
    echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
    log_change "Updated /etc/hosts for hostname $NEW_HOSTNAME with 127.0.1.1"
  else
    logv "/etc/hosts already has 127.0.1.1 $NEW_HOSTNAME"
  fi
fi

if [[ -n "$NEW_IP" ]]; then
  LAN_IFACE=$(ip route show default | awk '/default via/ {print $5}')
  [[ -z "$LAN_IFACE" ]] && LAN_IFACE="eth0"
  
  NETPLAN_FILE=$(ls /etc/netplan/*.yaml | head -n 1)
  
  CURRENT_IP=$(ip addr show "$LAN_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
  
  if [[ "$CURRENT_IP" != "$NEW_IP" ]]; then
    sed -i "s/${CURRENT_IP}/${NEW_IP}/g" "$NETPLAN_FILE"
    netplan apply
    log_change "IP changed from '$CURRENT_IP' to '$NEW_IP' on interface '$LAN_IFACE'"
  else
    logv "IP is already '$NEW_IP'; no change needed."
  fi
  
  LOCAL_HOSTNAME="$(hostname)"
  if ! grep -qE "^[^#]*\s+$NEW_IP\s+$LOCAL_HOSTNAME" /etc/hosts; then
    sed -i "/$NEW_IP\s\+$LOCAL_HOSTNAME/d" /etc/hosts
    echo "$NEW_IP $LOCAL_HOSTNAME" >> /etc/hosts
    log_change "Updated /etc/hosts for local IP $NEW_IP and hostname $LOCAL_HOSTNAME"
  else
    logv "/etc/hosts already has $NEW_IP $LOCAL_HOSTNAME"
  fi
fi

if [[ -n "$HOSTENTRY_NAME" && -n "$HOSTENTRY_IP" ]]; then
  if grep -qE "^[^#]*\s+$HOSTENTRY_IP\s+$HOSTENTRY_NAME" /etc/hosts; then
    logv "Hostentry $HOSTENTRY_NAME ($HOSTENTRY_IP) already in /etc/hosts"
  else
    sed -i "/$HOSTENTRY_IP\s\+$HOSTENTRY_NAME/d" /etc/hosts
    echo "$HOSTENTRY_IP $HOSTENTRY_NAME" >> /etc/hosts
    log_change "Added/updated /etc/hosts with $HOSTENTRY_NAME $HOSTENTRY_IP"
  fi
fi

exit 0
