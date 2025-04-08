{ config, pkgs, ... }:

{
  # Template for team members to customize
  # Copy this directory to create your own profile
  
  # These will be set dynamically by the setup scripts
  home.username = "{{USERNAME}}";
  home.homeDirectory = "{{HOMEDIR}}";
  
  # Keep this state version
  home.stateVersion = "24.11";
  
  # Add your personal packages here
  home.packages = with pkgs; [
    # Core tools - uncomment or add your own
    # git
    # vim
    # vscode
    
    # Browsers
    # firefox
    # brave
    
    # Communication
    # slack
    # discord
    
    # Development
    # nodejs
    # python3
  ];
  
  # Personal program configurations
  programs = {
    # Configure your git identity
    git = {
      enable = true;
      userName = "{{FULLNAME}}";
      userEmail = "{{EMAIL}}";
    };
    
    # Shell configuration
    zsh = {
      enable = true;
      # Add your custom zsh configuration here
    };
    
    # Other program configurations
    # vscode.enable = true;
  };
}