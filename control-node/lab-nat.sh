#!/usr/bin/env bash
# /root/lab-nat.sh on|off|status — run INSIDE CT 205.
# Temporary internet egress for GOAD VLAN 66 during provisioning/activation.
# Runtime-only: container restart = off.
set -euo pipefail
LAB_NET=172.16.66.0/24; LAB_IF=eth1; WAN_IF=eth0; HOME_NET=192.168.100.0/24

add_rule() { local t=$1 c=$2; shift 2; iptables -t "$t" -C "$c" "$@" 2>/dev/null || iptables -t "$t" -I "$c" "$@"; }
del_rule() { local t=$1 c=$2; shift 2; while iptables -t "$t" -C "$c" "$@" 2>/dev/null; do iptables -t "$t" -D "$c" "$@"; done; }

case "${1:-status}" in
  on)
    add_rule filter FORWARD -i "$LAB_IF" -d "$HOME_NET" -j DROP          # lab -> home LAN: blocked
    add_rule nat POSTROUTING -s "$LAB_NET" -o "$WAN_IF" -j MASQUERADE
    sysctl -qw net.ipv4.ip_forward=1
    echo "NAT ON" ;;
  off)
    sysctl -qw net.ipv4.ip_forward=0
    del_rule nat POSTROUTING -s "$LAB_NET" -o "$WAN_IF" -j MASQUERADE
    del_rule filter FORWARD -i "$LAB_IF" -d "$HOME_NET" -j DROP
    echo "NAT OFF" ;;
  status)
    echo "ip_forward=$(sysctl -n net.ipv4.ip_forward)"
    iptables -t nat -S POSTROUTING | grep -F "$LAB_NET" || echo "no MASQUERADE rule"
    iptables -S FORWARD | grep -F "$HOME_NET" || echo "no home-LAN block" ;;
esac
