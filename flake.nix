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

        rustBin = pkgs.rust-bin.stable."1.88.0".minimal;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustBin;
          rustc = rustBin;
        };

        lorrySrc = pkgs.fetchFromGitLab {
          group = "CodethinkLabs";
          owner = "lorry";
          repo = "lorry2";
          rev = "v2.7.0";
          sha256 = "sha256-zVSZt266VZQH3XncspUc783ShMRz/T/uTnH11Qvm8v0=";
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
