#!/bin/bash

MODE_FILE="/etc/cpu-mode"
GOV_SYS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
EPP_SYS="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"
AC_SYS="/sys/class/power_supply/AC0/online"

target_gov=""
target_epp=""

resolve_target() {
  local mode
  mode=$(cat "$MODE_FILE" 2>/dev/null || echo auto)

  case "$mode" in
    performance)
      target_gov="performance"; target_epp="performance" ;;
    powersave)
      target_gov="powersave"; target_epp="power" ;;
    balanced)
      target_gov="powersave"; target_epp="balance_performance" ;;
    auto|*)
      if [[ -f "$AC_SYS" && $(<"$AC_SYS") = "1" ]]; then
        target_gov="powersave"; target_epp="balance_performance"
      else
        target_gov="powersave"; target_epp="power"
      fi ;;
  esac
}

apply() {
  local changed=0
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [[ $(<"$cpu") != "$target_gov" ]] && { echo "$target_gov" > "$cpu" 2>/dev/null; changed=1; }
  done
  if [[ -f "$EPP_SYS" ]]; then
    local cur=$(<"$EPP_SYS")
    [[ "$cur" != "$target_epp" ]] && { echo "$target_epp" > "$EPP_SYS" 2>/dev/null; changed=1; }
  fi
  [[ $changed -eq 1 ]] && logger -t governor-watchdog "Applied: $target_gov / $target_epp"
}

while true; do
  resolve_target
  apply
  sleep 60
done
