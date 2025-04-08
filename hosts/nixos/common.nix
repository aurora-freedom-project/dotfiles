{ config, pkgs, ... }:

{
  # Cấu hình chung cho NixOS
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Cấu hình thời gian
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Cấu hình ngôn ngữ
  i18n.defaultLocale = "en_US.UTF-8";

  # Cấu hình gói phần mềm cơ bản
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    tmux
    unzip
    ripgrep
    fd
  ];

  # Cấu hình các chương trình
  programs = { 
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
    
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "npm" "python" "sudo" "vscode" ];
        theme = "robbyrussell";
      };
    };
    
    git = {
      enable = true;
    };
  };

  # Cấu hình dịch vụ
  services = {
    openssh.enable = true;
    fstrim.enable = true;
  };

  # Cấu hình bảo mật
  security = {
    sudo.wheelNeedsPassword = true;
    rtkit.enable = true;
  };
}
