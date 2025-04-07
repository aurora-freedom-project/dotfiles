# Terminal configuration
{ config, pkgs, ... }:

{
  # Alacritty terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        dynamic_title = true;
      };
      
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 12.0;
      };
      
      colors = {
        primary = {
          background = "#282c34";
          foreground = "#abb2bf";
        };
      };
    };
  };
  
  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      background_opacity = "0.95";
      window_padding_width = 10;
    };
    theme = "One Dark";
  };
  
  # iTerm2 configuration for macOS
  programs.iterm2.enable = pkgs.stdenv.isDarwin;
}
