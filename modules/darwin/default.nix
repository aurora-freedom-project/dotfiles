{ config, pkgs, ... }:

{
  # Module cho cấu hình Darwin (macOS)
  
  # Cấu hình cơ bản
  environment.systemPackages = with pkgs; [
    # Các gói phần mềm cơ bản cho macOS
    coreutils
    findutils
    gnugrep
    gnused
    gnutar
    gawk
    gnupg
    curl
    wget
    git
    vim
    tmux
    htop
    ripgrep
    fd
    jq
  ];
  
  # Cấu hình dịch vụ
  services = {
    nix-daemon.enable = true;
  };
  
  # Cấu hình Nix
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      build-users-group = nixbld
    '';
  };
  
  # Cấu hình homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    
    brews = [
      "mas"
    ];
    
    casks = [
      "ghostty"
      "visual-studio-code"
      "rectangle"
      "alfred"
    ];
  };
}
