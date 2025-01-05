#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
  echo "ERREUR: Ce script doit être exécuté avec les droits root (sudo)."
  exit 1
fi

echo "success"