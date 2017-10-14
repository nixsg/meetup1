{ config, lib, pkgs, ... }:

let
  containerOpts = import ../containers/common_container.nix;
  inherit (import ../apps/sensu_client.nix { inherit pkgs lib; }) sensuClient;

in lib.recursiveUpdate (sensuClient {
  name = "Customer";
  customer = "short_form";
  inherit config;
  }) {

  imports = [
    ./hardware/boot_uefi.nix
    ./profiles/appliance.nix
    ./profiles/singapore.nix
    ./profiles/vm_hyperv.nix
  ];

  networking.hostName = "s-util-1";

  services = {
    resolved.domains = [ "internal.external.com" ];
  };
}
