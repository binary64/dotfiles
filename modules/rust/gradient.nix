{ config, pkgs, lib, ... }:

with lib;

let
  rustPlatform = pkgs.rustPlatform;

  gradient = rustPlatform.buildRustPackage rec {
    pname = "gradient-rs";
    version = "0.3.4"; # Replace with the actual version

    src = pkgs.fetchFromGitHub {
      owner = "mazznoer";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-o8RayTBpJOwxJ9FSvqI+CFPJKI61ARiy/GJ4kkmRLtU="; # Replace with the actual sha256
    };

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    meta = with lib; {
      description = "A command-line tool to generate color gradients";
      homepage = "https://github.com/mazznoer/gradient-rs";
      license = licenses.mit;
      maintainers = with maintainers; [ ]; # Add maintainers here
    };
  };
in
{
  environment.systemPackages = [ gradient ];
}

