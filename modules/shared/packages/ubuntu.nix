# Ubuntu specific packages
{ config, pkgs, ... }:

{
  # Packages specific to Ubuntu via home-manager
  home.packages = with pkgs; [
    # Ubuntu utilities
    gnome-shell-extensions
    
    # System tools
    apt-transport-https
    gnupg
    
    # Development tools
    gcc
    make
    cmake
    
    # Additional utilities
    ubuntu-drivers-common
    software-properties-common
  ];
}
