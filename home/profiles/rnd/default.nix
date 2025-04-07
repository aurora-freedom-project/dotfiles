{ config, pkgs, ... }:

{
  # Cấu hình cá nhân cho rnd
  home.username = "rnd";
  home.homeDirectory = "/home/rnd";
  
  # Thêm stateVersion để tránh lỗi
  home.stateVersion = "23.11";
  
  # Các gói cá nhân
  home.packages = with pkgs; [
    # Thêm các gói cá nhân ở đây
    git
    vim
    vscode
    firefox
    tmux
  ];
  
  # Cấu hình cá nhân khác
  programs = {
    # Cấu hình các chương trình ở đây
    zsh.enable = true;
    git = {
      enable = true;
      userName = "RnD";
      userEmail = "rnd@example.com";
    };
  };
}
