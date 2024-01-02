{pkgs, ...}: {
  home.packages = with pkgs; [
    tickrs
  ];

  xdg.configFile."tickrs/config.yml".text = ''
    symbols:
      - BTC-GBP
      - TSLA
  '';
}
