# macOS specific packages
{ config, pkgs, ... }:

{
  # Packages specific to macOS via nix-darwin
  environment.systemPackages = with pkgs; [
    # macOS utilities
    m-cli
    mas
    
    # System tools
    coreutils
    findutils
    gnu-sed
    gawk
    
    # Development tools
    cocoapods
    xcodes
  ];
  
  # Homebrew configuration for macOS-only applications
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    
    # GUI applications that are not available or work better via Homebrew
    casks = [
      "alfred"
      "iterm2"
      "rectangle"
      "karabiner-elements"
      "1password"
      "docker"
      "visual-studio-code"
    ];
    
    # CLI tools that work better via Homebrew
    brews = [
      "mas"
      "swift-format"
    ];
  };
}
