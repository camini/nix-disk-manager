#!/usr/bin/env bash
set -euo pipefail

function e_info() { return; }
function e_warning() { echo -e "WARNING $*";}
function e_success() { echo "success"; }


e_info "Démontage de toutes les partitions secondaires (sauf / et /boot)..."
# On exclut le montage root (sur /) et /boot
for m in $(mount | grep '^/dev/' \
                | grep -v ' on / ' \
                | grep -v ' on /boot ' \
                | awk '{print $3}'); do
umount -R "$m" || e_warning "Impossible de démonter $m"
done
e_info "Toutes les partitions secondaires (hors / et /boot) sont (en principe) démontées."

e_info "Génération d'une configuration NixOS fraîche..."
nixos-generate-config


e_success()