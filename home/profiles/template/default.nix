{ config, pkgs, ... }:

{
  # Cấu hình cá nhân
  home.username = "{{USERNAME}}";
  home.homeDirectory = "{{HOMEDIR}}";
  
  # Thêm stateVersion để tránh lỗi
  home.stateVersion = "24.11";
  
  # Các gói cá nhân
  home.packages = with pkgs; [
    # Thêm các gói cá nhân ở đây
    git
    vim
    vscode
  ];
  
  # Cấu hình cá nhân khác
  programs = {
    git = {
      enable = true;
      userName = "{{FULLNAME}}";
      userEmail = "{{EMAIL}}";
    };
    
    # Cấu hình các chương trình ở đây
    zsh.enable = true;
  };
}