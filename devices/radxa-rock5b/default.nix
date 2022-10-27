{ lib, pkgs, ... }:

let
  inherit (lib)
    mkAfter
    mkDefault
  ;
in
{
  config = {
    wip.arm.device = {
      identifier = "radxa-rock5b";
      vendor = "Radxa";
      name = "ROCK 5B";
      system = "aarch64-linux";
    };
    boot.kernelPackages = mkDefault pkgs.linuxPackages_rock5;
    boot.kernelParams = mkAfter [
      "console=ttyFIQ0,115200n8"
      "console=ttyS2,115200n8"
      "earlycon=uart8250,mmio32,0xfeb50000"
      "earlyprintk"
    ];
    nixpkgs.overlays = [
      (final: super: {
        linuxPackages_rock5 = final.linuxPackagesFor final.linux_rock5;
        linux_rock5 = super.callPackage ./kernel {
          kernelPatches = [
            final.kernelPatches.bridge_stp_helper
            final.kernelPatches.request_key_helper
            { patch = ./kernel/0001-BSP-disable-vendor-kludge-around-overlays.patch; }
          ];
        };

      })
    ];
  };
}
