# ________       __.__        
# \______ \     |__|__| ____  
#  |    |  \    |  |  |/    \ 
#  |    `   \   |  |  |   |  \
# /_______  /\__|  |__|___|  /
#         \/\______|       \/
#     Lightning in a bottle

{ config, lib, pkgs, ... }:

{


  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/plasma-workspace.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
    allowInsecurePredicate = pkg: (pkg.pname) == "broadcom-sta";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.initrd.luks.devices = {
    luksroot = {
      name = "root";
      device = "/dev/disk/by-uuid/5c353b9b-5fe2-41c8-9347-a97eda0d2961";
      preLVM = true;
      allowDiscards = true;
    };
  };

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

  # Nouveau leaves this Kepler GPU below its lowest advertised performance
  # state.  The moderate 0a state keeps the 2880x1800 desktop responsive
  # without forcing the GPU's maximum memory clock.
  systemd.services.nouveau-performance-state = {
    description = "Set Nouveau GPU performance state to 0a";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    after = [ "sys-kernel-debug.mount" "systemd-modules-load.service" ];
    requires = [ "sys-kernel-debug.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for attempt in {1..50}; do
        test -e /sys/kernel/debug/dri/0/pstate && break
        sleep 0.1
      done
      echo 0a > /sys/kernel/debug/dri/0/pstate
    '';
  };

  # Reapply hardware performance settings after a suspend cycle.
  powerManagement.resumeCommands = ''
    ${pkgs.hdparm}/bin/hdparm -W0 /dev/sda
    echo 0a > /sys/kernel/debug/dri/0/pstate
  '';

  # TODO: Not working?
  # nixpkgs.config.allowUnfree = true;

  # environment.etc."nixos" = {
  #   source = "/home/carter/.config/nixos/";
  #   mode = "symlink";
  # };

  networking.hostName = "nosferatu"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Guatemala";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.plasma-login-manager.enable = true;
  };

  programs.azrah.enable = true;

  hardware.bluetooth.enable = true;

  users.users.carter = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      tmux
    ];
  };

  sops.defaultSopsFile = secrets/secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.example_key = {};

  environment.variables = {
    EDITOR = "nvim";
  };

  programs.firefox.enable = true;

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.email = "carterinmotion@gmail.com";
      user.name = "Carter Andrew";
    };
  };

  services.tailscale = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

