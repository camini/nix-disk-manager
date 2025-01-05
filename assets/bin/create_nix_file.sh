#!/usr/bin/env bash
set -euo pipefail

fs_type=$1
mount_point=$2
uuid=$3


function e_info() { return; }
function e_warning() { echo -e "WARNING $*";}
function e_success() { echo "success"; }
function e_error() { echo -e "ERROR $*";}



###############################################################################
# Options de montage
###############################################################################
fs_options='[ "defaults" "nofail" "x-gvfs-show" ]'
if [[ "$fs_type" == "btrfs" ]]; then
  fs_options='[ "defaults" "nofail" "x-gvfs-show" "compress=zstd" ]'
fi

###############################################################################
# Injection dans hardware-configuration.nix
###############################################################################
hardware_file="/etc/nixos/hardware-configuration.nix"

# Sauvegarde de sécurité
cp "$hardware_file" "$hardware_file.bak"
e_warning "Une sauvegarde a été créée : $hardware_file.bak"

sed -i '/^}/i \
  fileSystems."'"$mount_point"'" = {\
    device = "/dev/disk/by-uuid/'"$uuid"'";\
    fsType = "'"$fs_type"'";\
    options = '"$fs_options"';\
  };\
' "$hardware_file"

if grep -q "$mount_point" "$hardware_file"; then
  e_success "Le bloc fileSystems pour $mount_point a été inséré dans $hardware_file."
else
  e_error "L'insertion n'a pas été trouvée dans $hardware_file. Vérifiez manuellement."
  exit 1
fi