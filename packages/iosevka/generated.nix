# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  iosevka = {
    pname = "iosevka";
    version = "v1.5.3";
    src = fetchurl {
      url = "https://github.com/viperML/iosevka/releases/download/v1.5.3/iosevka.zip";
      sha256 = "sha256-ZSGdT1mO1LezVkbg8hc1lKLisKtvVftOPtmjQl8qxGE=";
    };
  };
}
