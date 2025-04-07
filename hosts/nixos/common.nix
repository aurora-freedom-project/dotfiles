{ config, pkgs, ... }:

{
  # Cấu hình chung cho NixOS
  nix = {
    package = pkgs.nixFlakes;
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
