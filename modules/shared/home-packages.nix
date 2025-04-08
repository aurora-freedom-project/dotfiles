# Shared home-manager packages for all platforms
{ config, pkgs, ... }:

{
  # Common packages for all users via home-manager
  home.packages = with pkgs; [
    # Development tools
    git
    vim
    vscode
    
    # Terminal utilities
    tmux
    htop
    fzf
    ripgrep
    fd
    
    # System tools
    bat
    eza
    jq
    
    # Languages and runtimes
    nodejs
    python3
  ];
  
  # Common program configurations
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
    
    git = {
      enable = true;
      delta.enable = true;
    };
  };
}