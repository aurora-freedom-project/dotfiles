# Shared packages configuration for all platforms
{ config, pkgs, ... }:

{
  # Common packages for all platforms
  home.packages = with pkgs; [
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
    exa
    jq
    
    # Languages and runtimes
    nodejs
    python3
    rustup
  ];
}
