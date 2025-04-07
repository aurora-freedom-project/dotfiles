# NixOS specific packages
{ config, pkgs, ... }:

{
  # Packages specific to NixOS
  environment.systemPackages = with pkgs; [
    # Desktop environment
    gnome.gnome-tweaks
    gnome-extensions-cli
    
    # System tools
    gparted
    ntfs3g
    
    # Hardware support
    pciutils
    usbutils
    
    # Virtualization
    virt-manager
    qemu
    
    # Networking
    networkmanager
    networkmanagerapplet
  ];
}
