# Shared packages configuration for all platforms
{ config, pkgs, ... }:

{
  # Common packages for all platforms
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    vim
    neovim
    vscode
    
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
    eza  # Changed from exa to eza
    jq
    
    # Languages and runtimes
    nodejs
    python3
    rustup
  ];
}
