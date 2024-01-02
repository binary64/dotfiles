{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  #imports = [ ./tmux.nix ];

  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console.keyMap = "uk";
  hardware.opengl.enable = true;
  environment.shells = with pkgs; [bashInteractive fish];
  environment.systemPackages = with pkgs; [
    cachix
  ];
  programs = {
    #   neovim = {
    #     enable = true;
    #   };
    #   hyprland = {
    #     enable = true;
    #   };
  };
  #environment.systemPackages = with pkgs; [
  #  nodePackages.pnpm
  #];

  #programs.steam.enable = true;

  # better for steam proton games
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
}
