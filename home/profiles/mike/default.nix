{ config, pkgs, ... }:

{
  # Cấu hình cá nhân cho mike
  home.username = "mike";
  home.homeDirectory = "/Users/mike";
  
  # Thêm stateVersion để tránh lỗi
  home.stateVersion = "24.11";
  
  # Các gói cá nhân
  home.packages = with pkgs; [
    # Thêm các gói cá nhân ở đây
    git
    vim
    vscode
    firefox
    iterm2
  ];
  
  # Cấu hình cá nhân khác
  programs = {
    # Cấu hình các chương trình ở đây
    zsh.enable = true;
    git = {
      enable = true;
      userName = "Mike";
      userEmail = "mike@example.com";
    };
  };
}
