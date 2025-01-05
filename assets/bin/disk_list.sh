#!/usr/bin/env bash
set -euo pipefail

function e_info()    { return; }


# Détection des disques
e_info "Détection des disques disponibles..."
#lsblk -d -n -o NAME,SIZE,TYPE | grep disk || e_warning "Aucun disque détecté."
#e_info "Disques détectés :"

mapfile -t disks < <(lsblk -d -n -o NAME,SIZE,TYPE | grep disk)

for i in "${!disks[@]}"; do
  echo "/dev/${disks[$i]}"
done