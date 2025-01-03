{ inputs, ganix, ... }@flakeContext:
{ config, lib, pkgs, ... }: {
  imports = [
    inputs.self.nixosModules.services
    inputs.self.nixosModules.user-root
  ];
  config = {
    system = {
      stateVersion = "23.05";
    };

    boot = {
      kernelParams = ["cma=256M"];

      # Use the hardened kernel for security while retaining RPi compatibility
      kernelPackages = pkgs.linuxPackages_hardened;

      # Cleanup tmp on startup
      cleanTmpDir = true;

      loader = {
        systemd-boot.enable = true;
        raspberryPi.version = ganix.raspberry_model;
      };

      extraModprobeConfig = ''
        options hid_apple fnmode=0
      '';

      supportedFilesystems = [ "ntfs" "vfat" ];
    };

    time.timeZone = ganix.timezone;

    documentation.enable = false;

    systemd.services.kismet = {
      description = "Kismet Wireless Network Sniffer (Headless)";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "/usr/bin/kismet_server";
      serviceConfig.Restart = "always";
      serviceConfig.User = "root";
      environment.TMPDIR = "/var/tmp";
    };

    environment.systemPackages = with pkgs; [
      libraspberrypi
      vim
      git
      wget
      gpsd
      btop
      neofetch
      pkgs.linuxKernel.packages.linux_hardened.rtl8812au
      kismet
      jq
      docker-compose
      bat
      xh
    ];

    hardware = {
      enableRedistributableFirmware = true;
      firmware = [
        pkgs.firmwareLinuxNonfree
        pkgs.wireless-regdb
      ];

      bluetooth = {
        enable = false;
        powerOnBoot = false;
      };
    };

    networking = {
      hostName = ganix.hostname;
      firewall.enable = false;
      interfaces.wlan0.useDHCP = true;

      wireless = {
        enable = ganix.wifi_enabled;
        interfaces = [ "wlan0" ];
        networks = {
          "${ganix.wifi_network_name}" = {
            pskRaw = "${ganix.wifi_network_psk}";
          };
        };
      };
    };

    sdImage = {
      compressImage = false;
      imageName = "${config.sdImage.imageBaseName}-${ganix.hostname}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
    };

    i18n.defaultLocale = "en_US.UTF-8";

    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };

    nixpkgs.config.allowUnfree = true;

    # Add Docker service
    virtualisation.docker.enable = true;

   fileSystems = {
  "/" = lib.mkForce {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };
  "/boot" = {
    device = "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
  };
};

    swapDevices = [{ device = "/swapfile"; size = 1024; }];

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
