{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (specialArgs) nixpkgsPath;
  fromPkgs = path: nixpkgsPath + "/${path}";

  inherit (lib)
    mkForce
    mkIf
    mkOption
    types
  ;
  # FIXME: infinite recursion (obviously)
  #  -> import at eval call site in default.nix?
  #shortSystem = {
  #  "aarch64-linux" = "aarch64";
  #}."${config.wip.arm.device.system}";
  shortSystem = "aarch64";
in
{
  imports = [
    (fromPkgs "nixos/modules/installer/sd-card/sd-image-${shortSystem}-installer.nix")
  ];

  config = {
    fileSystems = mkForce {
      "/" = { label = "NIXOS_ROOTFS"; };
    };
    # Builds an (opinionated) rootfs image.
    # NOTE: *only* the rootfs.
    #       it is expected the end-user will assemble the image as they need.
    system.build.rootfsImage = pkgs.callPackage (
      { callPackage
      , lib
      , populateCommands
      }:

      let
        inherit (lib)
          optionalAttrs
        ;
      in
      callPackage (fromPkgs "nixos/lib/make-ext4-fs.nix") ({
        inherit (config.sdImage) storePaths;
        compressImage = config.sdImage.compressImage;
        populateImageCommands = populateCommands;
        volumeLabel = config.fileSystems."/".label;
      } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
        uuid = config.sdImage.rootPartitionUUID;
      })

    ) {
      populateCommands = ''
        mkdir -p ./files/boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
      '';
    };
  };
}
