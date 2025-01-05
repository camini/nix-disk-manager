#!/usr/bin/env bash
set -euo pipefail

partition_choice=$1

function e_info() { return; }
function e_warning() { echo -e "WARNING $*";}
function e_success() { echo "success"; }
function e_error() { echo -e "ERROR $*";}

###############################################################################
# Récupération du type de FS + UUID
###############################################################################
fs_type=$(lsblk -no FSTYPE "$partition_choice")
if [[ -z "$fs_type" ]]; then
  e_error "Impossible de déterminer le type de système de fichiers pour $partition_choice."
  exit 1
fi
e_info "Type de FS détecté : $fs_type"

uuid=$(blkid "$partition_choice" -s UUID -o value || true)
if [[ -z "$uuid" ]]; then
  e_error "Impossible de récupérer l'UUID de $partition_choice."
  exit 1
fi

echo "success|$fs_type|$uuid"

e_info "UUID récupéré : $uuid"