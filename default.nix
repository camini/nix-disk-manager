# default.nix

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
# Export nix_disk_manager as an attribute at the top level
{
  nix_disk_manager = pkgs.callPackage ./nix_disk_manager.nix { };
}
