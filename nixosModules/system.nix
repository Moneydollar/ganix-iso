{ inputs, ganix, ... }@flakeContext:
{
  imports = [
    inputs.self.nixosModules.services
    inputs.self.nixosModules.user-root
  ];
  config = {
    system.stateVersion = "23.05";

    boot = {
      loader = {
        systemd-boot.enable = true;  # Use systemd-boot
        generic-extlinux-compatible.enable = false; # Ensure extlinux is disabled
        raspberryPi.version = ganix.raspberry_model; # Keep if relevant to Pi
      };

      kernelPackages = pkgs.linuxPackages_hardened;
      kernelParams = ["cma=256M"];
      cleanTmpDir = true;

      extraModprobeConfig = ''
        options hid_apple fnmode=0
      '';
    };

    # Remaining configurations
    time.timeZone = ganix.timezone;

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

    # Example filesystem configuration
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };

    swapDevices = [{ device = "/swapfile"; size = 1024; }];
    virtualisation.docker.enable = true;

    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };

    nixpkgs.config.allowUnfree = true;
  };
}
c