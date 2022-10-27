{ pkgs ? import ./nixpkgs.nix {} }:

let
  nixpkgsPath = pkgs.path;
  fromPkgs = path: nixpkgsPath + "/${path}";
  evalConfig = import (fromPkgs "nixos/lib/eval-config.nix");
  buildConfig = { configuration ? {} }:
    evalConfig {
      specialArgs = {
        inherit nixpkgsPath;
      };
      modules= [
          ./modules
          configuration
      ];
    }
  ;
  devices =
    builtins.filter
    (d: builtins.pathExists (./. + "/devices/${d}/default.nix"))
    (builtins.attrNames (builtins.readDir ./devices))
  ;

  evalDevice =
    name: 
    let
      evalWith = additionalConfig: buildConfig {
        configuration =
          {
            imports = [
              additionalConfig
              (./devices + "/${name}")
            ];
          }
        ;
      };
    in
    rec {
      isoMinimal = (
        evalWith (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
      ).config.system.build.isoImage;

      rootfs = (
        evalWith ./modules/rootfs.nix
      ).config.system.build.rootfsImage;

      isoUEFI = (
        evalWith ./modules/isoUEFI.nix
      ).config.system.build.isoImage;

      eval = evalWith { };

      inherit (eval) pkgs;

      inherit (eval.config.boot.kernelPackages) kernel;
    }
  ;
in
  builtins.listToAttrs
  (map (name: { inherit name; value = evalDevice name; }) devices)
