{ config, pkgs, ... }:

{
  # Cấu hình chung cho macOS
  imports = [
    ./profiles/${config.home.username}
  ];

  # Cấu hình cơ bản
  home = {
    # Cấu hình ngôn ngữ
    language.base = "en_US.UTF-8";
    
    # Cấu hình các gói phần mềm cơ bản
    packages = with pkgs; [
      # Các công cụ cơ bản
      coreutils
      curl
      wget
      git
      vim
      tmux
      htop
      ripgrep
      fd
      jq
      
      # Các công cụ phát triển
      vscode
      nodejs
      python3
    ];
    
    # Cấu hình các file dotfiles
    file = {
      ".config/nvim" = {
        source = ./config/nvim;
        recursive = true;
      };
    };
  };
  
  # Cấu hình các chương trình
  programs = {
    home-manager.enable = true;
    
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        update = "brew update && brew upgrade";
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
    
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        ms-python.python
      ];
    };
  };
  
  # Cấu hình macOS-specific
  targets.darwin = {
    defaults = {
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
  };
}
