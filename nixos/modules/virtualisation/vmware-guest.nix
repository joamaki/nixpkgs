{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vmwareGuest;
  open_vm_tools = pkgs.open_vm_tools;
in
{
  options = {
    services.vmwareGuest = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the VMWare guest service.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [ {
      assertion = pkgs.stdenv.isi686 || pkgs.stdenv.isx86_64;
      message = "VMWare guest is not currently supported on ${pkgs.stdenv.system}";
    } ];

    environment.systemPackages = [ open_vm_tools ];

    systemd.services.vmware =
      { description = "VMWare Guest Service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${open_vm_tools}/bin/vmtoolsd";
      };

    services.xserver = {
      videoDrivers = mkOverride 50 [ "vmware" ];

      config = ''
          Section "InputDevice"
            Identifier "VMMouse"
            Driver "vmmouse"
          EndSection
        '';

      serverLayoutSection = ''
          InputDevice "VMMouse"
        '';

      displayManager.sessionCommands = ''
          ${open_vm_tools}/bin/vmware-user-suid-wrapper
        '';
    };
  };
}
