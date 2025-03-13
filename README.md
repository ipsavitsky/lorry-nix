# A nix flake that builds and deploys lorry

## Todo
- [x] Build lorry
- [ ] Define a `nixosModule` to deploy lorry

## Usage

Example usage of a `nixosSystem` with lorry installed

``` nix
{
  inputs={
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    lorry.url = "github:ipsavitsy/lorry-nix";
  };
  
  outputs = let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      exampleSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        environment.systemPackages = [
          lorry.packages.${system}.default;
        ];
      };
    };
  };
}
```
