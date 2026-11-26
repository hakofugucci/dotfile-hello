{ pkgs, ... }:
{
  home.username = "admin";
  home.homeDirectory = "/Users/admin";
  home.stateVersion = "25.05";

  home.packages = [ pkgs.jdk21_headless ];

  programs.zsh = {
    enable = true;
    shellAliases.nullpo = "cat ${./nullpo.aa}";
  };
}
