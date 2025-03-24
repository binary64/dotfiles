{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  imports = [  ];

  time.timeZone = mkDefault "Europe/London";
  i18n.defaultLocale = mkDefault "en_GB.UTF-8";
  console.keyMap = "uk";
  hardware.opengl.enable = true;
  environment.shells = with pkgs; [bashInteractive fish];
  environment.systemPackages = with pkgs; [
    cachix
  ];

  programs = {
  };

  # set a super secure initial root password
  users.users.root.initialHashedPassword = "$6$nAffBk9Fxs.0J13A$S4e5cCSd.ITeYAZydUnfwo6eHXiYJuzbp3RPKHf8xtnP25V1Zk0eypKFeg0LXDTnJsfRv5O21TKMavcb3c9qE1";

  # kernel tweaks
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

}
