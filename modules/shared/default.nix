{ config, pkgs, ... }:

{
  # Import all shared modules
  imports = [
    ./packages/common.nix
    # Add other shared modules as needed
  ];
}