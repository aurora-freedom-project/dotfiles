# Shell configuration
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "npm" "python" "sudo" "vscode" ];
      theme = "robbyrussell";
    };
    
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch";
      hm = "home-manager switch";
      vim = "nvim";
    };
    
    initExtra = ''
      # Custom zsh configuration
      bindkey -e
      
      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
  
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch";
      hm = "home-manager switch";
      vim = "nvim";
    };
  };
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
