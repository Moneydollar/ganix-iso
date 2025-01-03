/** Include services and programs configuration */
{ inputs, ... }@flakeContext:
{ config, lib, pkgs, ... }: {
  config = {
    services = {
      ntp.enable = true;

      openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "yes";
          PasswordAuthentication = true;
        };
      };

      avahi = {
        enable = true;
        nssmdns = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };

      gpsd.enable = true;

      
    };
  };
}
