{ config, lib, pkgs, ... }:

{
  services.xserver = {
    enable = true;

    displayManager.sddm = {
      enable = true;
      theme = lib.mkForce "nixos";
      autoLogin = {
        enable = true;
        user = "peter";
      };
    #   themes = with pkgs; [
    #     kde5.ecm # for the setup-hook
    #     kde5.plasma-workspace
    #     nixos-artwork
    #   ];
    };
  };
}
