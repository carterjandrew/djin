#   _______                  _____                    __         
#   \      \   ____  _______/ ____\________________ _/  |_ __ __ 
#   /   |   \ /  _ \/  ___/\   __\/ __ \_  __ \__  \\   __\  |  \
#  /    |    (  <_> )___ \  |  | \  ___/|  | \// __ \|  | |  |  /
#  \____|__  /\____/____  > |__|  \___  >__|  (____  /__| |____/ 
#          \/           \/            \/           \/
#												   The undead boyar

{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config = {
    allowInsecurePredicate = pkg: (pkg.pname) == "broadcom-sta";
  };

  boot.initrd.luks.devices = {
    luksroot = {
      name = "root";
      device = "/dev/disk/by-uuid/5c353b9b-5fe2-41c8-9347-a97eda0d2961";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # The MacBookPro11,3 firmware normally hides the Intel GPU from non-macOS
  # boot loaders.  Run this small EFI shim before displaying the NixOS menu so
  # i915 can see the integrated GPU.  Keep the file pinned for reproducibility.
  boot.loader.grub.extraFiles."EFI/custom/apple_set_os.efi" = pkgs.fetchurl {
    url = "https://github.com/0xbb/apple_set_os.efi/releases/download/v1/apple_set_os.efi";
    hash = "sha256-PuHraE6f1ZAdretfaTs3RgSw7AvOYEfusJU9rm1/1dY=";
  };
  boot.loader.grub.extraConfig = ''
    search --no-floppy --set=apple_efi --file /EFI/custom/apple_set_os.efi
    chainloader ($apple_efi)/EFI/custom/apple_set_os.efi
    boot
  '';

  # Load Intel graphics early so it owns the internal panel before userspace
  # starts.  The discrete GPU driver is left to normal PCI auto-detection.
  boot.initrd.kernelModules = [ "i915" ];

  boot.extraModulePackages = [
    config.boot.kernelPackages.broadcom_sta
  ];
  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [
    "b43"
    "b43legacy"
    "ssb"
    "bcma"
    "brcmsmac"
  ];

  # Avoid latency spikes from issuing synchronous TRIM commands during normal
  # filesystem activity.  The periodic fstrim service below batches them
  # instead; LUKS discard pass-through remains enabled above.
  fileSystems."/".options = [ "noatime" ];
  services.fstrim.enable = true;

  # This Apple/Samsung SSD can spend over a second flushing its volatile
  # write cache, stalling all I/O and making cold application starts take
  # minutes.  Disabling the drive cache avoids those firmware stalls while
  # retaining filesystem write-ordering guarantees.
  systemd.services.disable-apple-ssd-write-cache = {
    description = "Disable the Apple SSD volatile write cache";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    after = [ "dev-sda.device" ];
    requires = [ "dev-sda.device" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.hdparm}/bin/hdparm -W0 /dev/sda";
      RemainAfterExit = true;
    };
  };

  # Apple GMUX can physically cut power to the unused discrete GPU once both
  # graphics clients have registered with vga_switcheroo.  Refuse to do this
  # unless Intel is the boot GPU, so an NVRAM reset cannot cause a black screen.
  systemd.services.power-off-nvidia-gpu = {
    description = "Power off the unused NVIDIA GPU";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    after = [ "sys-kernel-debug.mount" "systemd-modules-load.service" ];
    requires = [ "sys-kernel-debug.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ "$(cat /sys/bus/pci/devices/0000:00:02.0/boot_vga)" != 1 ]; then
        echo "Refusing to power off NVIDIA: Intel is not the boot GPU" >&2
        exit 1
      fi

      switch=/sys/kernel/debug/vgaswitcheroo/switch
      for attempt in {1..50}; do
        [ -e "$switch" ] && break
        sleep 0.1
      done
      [ -e "$switch" ] || {
        echo "vga_switcheroo did not become available" >&2
        exit 1
      }
      echo OFF > "$switch"
    '';
  };

  # Reapply hardware power settings after a suspend cycle.
  powerManagement.resumeCommands = ''
    ${pkgs.hdparm}/bin/hdparm -W0 /dev/sda
    if [ "$(cat /sys/bus/pci/devices/0000:00:02.0/boot_vga)" = 1 ] \
      && [ -e /sys/kernel/debug/vgaswitcheroo/switch ]; then
      echo OFF > /sys/kernel/debug/vgaswitcheroo/switch
    fi
  '';

}
