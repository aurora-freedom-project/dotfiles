{ config, pkgs, lib, ... }:

{
  # Cấu hình chung cho NixOS
  imports = [
    ../common.nix
  ];

  # Cấu hình WSL
  wsl = {
    enable = true;
    defaultUser = "rnd";
    startMenuLaunchers = true;
    
    # Cấu hình tích hợp với Windows
    interop = {
      enable = true;
      register = true;
    };
    
    # Cấu hình tự động mount
    automountPath = "/mnt";
    automountOptions = "metadata,umask=22,fmask=11";
  };

  # Cấu hình người dùng
  users.users.rnd = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = lib.mkForce pkgs.zsh;
  };

  # Cấu hình hệ thống
  system.stateVersion = "24.11";
}
