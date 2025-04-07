{ config, pkgs, ... }:

{
  # Module cho các tính năng desktop trên NixOS
  
  # Cấu hình X11 và Wayland
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    
    # Cấu hình bàn phím
    layout = "us";
    xkbVariant = "";
    
    # Cấu hình chuột
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        naturalScrolling = true;
        tapping = true;
      };
    };
  };
  
  # Cấu hình âm thanh
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  
  # Cấu hình font
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "JetBrains Mono" "Fira Code" ];
      };
    };
  };
  
  # Cấu hình các gói phần mềm desktop
  environment.systemPackages = with pkgs; [
    # Các ứng dụng desktop
    firefox
    thunderbird
    libreoffice
    vlc
    gimp
    vscode
    
    # Các công cụ hệ thống
    gnome.gnome-tweaks
    gnome.dconf-editor
    gnome.gnome-terminal
  ];
  
  # Cấu hình dịch vụ
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };
    
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    
    flatpak.enable = true;
  };
}
