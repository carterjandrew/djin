{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.initrd.luks.devices = {
    luksroot = {
      name = "root";
      device = "/dev/disk/by-uuid/643a8658-29d0-469c-a798-4f966be0a3f9";
      preLVM = true;
      allowDiscards = true;
    };
  };
}
