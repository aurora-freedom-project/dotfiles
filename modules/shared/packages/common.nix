# Shared packages configuration for all platforms
{ config, pkgs, ... }:

{
  # Common packages for all platforms - system level
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    vim
    neovim
    
    # Terminal utilities
    tmux
    htop
    fzf
    ripgrep
    fd
    
    # Shell
    zsh
    starship
    
    # Network tools
    curl
    wget
    
    # System tools
    bat
    eza  # Modern replacement for exa
    jq
  ];
}
