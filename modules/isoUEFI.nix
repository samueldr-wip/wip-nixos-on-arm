{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (specialArgs) nixpkgsPath;
  fromPkgs = path: nixpkgsPath + "/${path}";
in
{
  imports = [
    (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  config = {
    # TODO: output /dtbs into root of ESP
  };
}
