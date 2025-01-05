#!/usr/bin/env bash
set -euo pipefail

disk_choice=$1
disk_name=$1

function e_info() { return; }
function e_warning() { echo -e "WARNING $*";}
function e_success() { echo "success"; }

e_info "Partitions détectées sur $disk_choice :"
part_raw=$(lsblk -ln -o NAME,SIZE,FSTYPE "$disk_choice")
mapfile -t partitions < <(echo "$part_raw" | grep -v "^$disk_name ")

for i in "${!partitions[@]}"; do
  echo "${partitions[$i]}"
done

if [[ "${#partitions[@]}" -eq 0 ]]; then
  e_warning "Aucune partition détectée sur ce disque."
  exit 1
fi