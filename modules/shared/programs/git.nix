# Git configuration
{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Aurora Freedom Project";
    userEmail = "aurora@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      ci = "commit";
      br = "branch";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
  };
}
