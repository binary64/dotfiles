{pkgs, ...}: {
  imports = [./lf ./tickrs.nix];
  home.packages = with pkgs; [file];
}
