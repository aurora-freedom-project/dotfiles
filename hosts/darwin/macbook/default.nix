{ config, pkgs, lib, ... }:

{
  # Import các module chung
  imports = [
    ../common.nix
  ];
  
  # Cấu hình người dùng - only keep what's unique to this file
  users.users.mike = {
    name = "mike";
    home = "/Users/mike";
    shell = lib.mkForce pkgs.zsh;  # Using lib.mkForce to resolve the conflict
  };
  
  # Add any macbook-specific configurations here
  
  # Cấu hình hệ thống
  system.stateVersion = 4;
}
