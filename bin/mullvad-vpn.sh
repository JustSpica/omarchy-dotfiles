#!/usr/bin/env bash

INTERFACE="mullvad-ca"

is_active() {
  ip -o addr show dev "$INTERFACE" 2>/dev/null | grep -Eq '\binet\b|\binet6\b'
}

get_status() {
  if is_active; then
    echo '{"text":"[  ]","class":"connected","tooltip":"VPN ativa (Mullvad: '"$INTERFACE"')"}'
  else
    echo '{"text":"[  ]","class":"disconnected","tooltip":"VPN desligada (Mullvad: '"$INTERFACE"')"}'
  fi
}

toggle_vpn() {
  if is_active; then
    pkexec wg-quick down "$INTERFACE"
  else
    pkexec wg-quick up "$INTERFACE"
  fi
}

case "${1:-status}" in
  status)
    get_status
    ;;
  toggle)
    toggle_vpn
    sleep 1
    get_status
    ;;
  *)
    echo '{"text":"[ ? ]","class":"unknown","tooltip":"Uso: mullvad-vpn.sh [status|toggle]"}'
    ;;
esac
