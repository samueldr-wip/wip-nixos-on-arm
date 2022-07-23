{ config, lib, ... }:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
  ;

  inherit (config.wip.arm) device;
  inherit (config.nixpkgs) localSystem;
  selectedPlatform = lib.systems.elaborate device.system;
  isCross = selectedPlatform.system != localSystem.system;
in
{
  options = {
    wip.arm = {
      device = {
        identifier = mkOption {
          type = types.str;
          description = ''
            Identifier used for the board, generally downcased `vendor-name`.
          '';
        };
        vendor = mkOption {
          type = types.str;
          description = ''
            Vendor name for the board.
          '';
        };
        name = mkOption {
          type = types.str;
          description = ''
            Advertised name for the board.
          '';
        };
        system = mkOption {
          type = types.str;
          description = ''
            System for the board.
          '';
        };
        fullName = mkOption {
          type = types.str;
          default = "${config.vendor} ${config.name}";
          description = ''
            Automatically generated, full name.
          '';
        };
      };
      workarounds = {
        ignoreMissingKernelModules = mkOption {
          type = types.bool;
          default = true;
          internal = true;
        };
      };
    };
  };
  config = mkMerge [
    {
      nixpkgs.overlays = lib.mkIf (config.wip.arm.workarounds.ignoreMissingKernelModules) [
        (final: super: {
          # Workaround for modules expected by NixOS not being built more often than not.
          makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    }
    (mkIf isCross {
      # Some filesystems (e.g. zfs) have some trouble with cross (or with BSP kernels?) here.
      boot.supportedFilesystems = lib.mkForce [ "vfat" ];

      nixpkgs.crossSystem =
        builtins.trace ''
          Building with crossSystem?: ${selectedPlatform.system} != ${localSystem.system} → ${if isCross then "we are" else "we're not"}.
                 crossSystem: config: ${selectedPlatform.config}''
        selectedPlatform
      ;
    })
  ];
}
