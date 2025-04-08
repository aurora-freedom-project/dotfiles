{ config, pkgs, ... }:

{
  # Template for team members to customize
  # Copy this directory to create your own profile
  
  # Replace with your username
  home.username = "username";
  # Replace with your home directory
  home.homeDirectory = "/Users/username";  # or /home/username for Linux
  
  # Keep this state version
  home.stateVersion = "24.11";
  
  # Add your personal packages here
  home.packages = with pkgs; [
    # Examples (uncomment or add your own)
    # firefox
    # vscode
    # slack
  ];
  
  # Personal program configurations
  programs = {
    # Configure your git identity
    git = {
      enable = true;
      userName = "Your Name";
      userEmail = "your.email@example.com";
    };
    
    # Other program configurations
    # vscode.enable = true;
  };
}