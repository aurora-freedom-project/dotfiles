{ config, pkgs, ... }:

{
  # Cấu hình cho Ubuntu
  # File này được sử dụng bởi home-manager trên Ubuntu

  # Cấu hình cơ bản
  home.packages = with pkgs; [
    # Các gói phần mềm cơ bản cho Ubuntu
    git
    vim
    curl
    wget
    htop
    tmux
    ripgrep
    fd
    jq
  ];

  # Cấu hình các chương trình
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "sudo apt update && sudo apt upgrade -y";
      };
    };
    
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

  # Cấu hình các file dotfiles
  home.file = {
    ".config/nvim" = {
      source = ./config/nvim;
      recursive = true;
    };
  };
}
