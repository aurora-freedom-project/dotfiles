{ config, pkgs, lib, ... }:

{
  # Cấu hình chung cho NixOS
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/nvidia.nix
    ../../../modules/nixos/virtualization.nix
    ../common.nix
  ];

  # Cấu hình boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Cấu hình mạng
  networking = {
    hostName = "legion";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Cấu hình người dùng
  users.users.rnd = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = lib.mkForce pkgs.zsh;
  };

  # Cấu hình hệ thống
  system.stateVersion = "24.11";
}
