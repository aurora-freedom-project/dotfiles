{ config, pkgs, ... }:

{
  # Cấu hình chung cho macOS
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
      show-recents = false;
    };
    
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };
  };
  
  # Cấu hình homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    
    taps = [
      "homebrew/cask-fonts"
      "homebrew/services"
    ];
  };
  
  # Cấu hình người dùng
  users.users.mike = {
    name = "mike";
    home = "/Users/mike";
    shell = pkgs.zsh;
  };
  
  # Cấu hình hệ thống
  system.stateVersion = 4;
  
  # Import các module chung
  imports = [
    ../common.nix
  ];
}
