{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = pkgs.rust-bin.stable."1.87.0".minimal;
          rustc = pkgs.rust-bin.stable."1.87.0".minimal;
        };

        lorrySrc = pkgs.fetchFromGitLab {
          group = "CodethinkLabs";
          owner = "lorry";
          repo = "lorry2";
          rev = "v2.6.0";
          sha256 = "sha256-Dofd9NDyo2U8K1HU1QEOvFSILAAF1y/Og14K4lj0hNg=";
        };
      in
      {
        packages = rec {
          default = lorry;
          lorry = rustPlatform.buildRustPackage {
            name = "lorry";
            src = lorrySrc;

            cargoLock = {
              lockFile = "${lorrySrc}/Cargo.lock";
            };

            buildAndTestSubdir = "lorry";

            buildInputs = with pkgs; [
              git
              openssl
            ];

            nativeBuildInputs = with pkgs; [
              git
              openssl
              pkg-config
            ];

            OPENSSL_NO_VENDOR = 1;
            SQLX_OFFLINE = true;

            meta.platforms = pkgs.lib.platforms.linux;
          };
        };
      }
    );
}
