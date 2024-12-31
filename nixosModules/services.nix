/** Include services and programs configuration */
{ inputs, ... }@flakeContext:
{ config, lib, pkgs, ... }: {
  config = {
    services = {
      ntp.enable = true;

      openssh = {
        enable = true;
        openFirewall = true;
        settings.PermitRootLogin = "yes";
        settings.PasswordAuthentication = false;
      };

      avahi = {
        enable = true;
        nssmdns = true;
        publish.enable = true;
        publish.addresses = true;
        publish.workstation = true;
      };
      gpsd = {
        enable = true;
      }
      

    # add docker
    virtualisation.docker.enable = true;
  };
}
