let
  ipNetwork = "10.10.1";
  ipMachine = "135";

  hostOpts = {
    hasFastConnection = true;
    owners = [ "support@speartail.com" ];
  };

in {
  network = {
    description = "Some Random Customer";
    enableRollBack = true;
  };

  util = { config, pkgs, ... }: {
    imports = [
      ./machines/customer_s-util-1.nix {}
    ];

    deployment = hostOpts // {
      targetHost = "${ipNetwork}.${ipMachine}";
    };
  };
}
