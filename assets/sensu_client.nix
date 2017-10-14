{ pkgs, lib }:

let
  stdenv = pkgs.stdenv;

  checkPingDupsPackage = let
    name = "check_ping_dups";
  in stdenv.mkDerivation {
    inherit name;
    src = ../../assets/check_ping_dups.sh;
    phases = [ "installPhase" "fixupPhase" ];
    installPhase = ''
      script=$out/bin/${name}

      mkdir -p $out/bin

      substitute $src $script \
        --subst-var-by ping /run/wrappers/bin/ping \
        --subst-var-by grep ${stdenv.lib.getBin pkgs.gnugrep}/bin/grep

      chmod 755 $script
    '';
  };

  makeKeyPackage = type: stdenv.mkDerivation {
    name = "rabbitmq-${type}-keys";
    src = ../.././secrets/certs;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp $src/ca/cacert.pem          $out/ca.pem
      cp $src/${type}/{cert,key}.pem $out/

      if [ "type" == "server" ]; then
        cat $src/ca/cacert.pem $src/client/cert.pem > $out/chain.pem
      else
        cat $src/ca/cacert.pem $src/server/cert.pem > $out/chain.pem
      fi
    '';
  };

in rec {
  password = "fjkleahjk_343f_hfjahhlkh-hkla24rtrHJKLKh";

  queueHost = monitorHost;
  monitorHost = "monitor.speartail.net";

  sensuClient = { name, customer, region ? "", open_ports ? true, subs ? [], vars ? {}, config }: {
    networking.firewall.allowedTCPPorts = [ config.services.sensu.client.socket.port ];
    services.sensu = {
      enable = true;
      role = lib.mkDefault "client";
      openDefaultPorts = lib.mkDefault open_ports;
      defaultSubscriptions.enable = true;
      logLevel = lib.mkDefault "warn";
      transport.name = "rabbitmq";

      client = {
        inherit name vars;
        socket.bind = "0.0.0.0";
        subscriptions = [ (if (region != "") then region else customer) ] ++ subs;
      };

      dependencies = [ checkPingDupsPackage ];

      programs = {
        common  = true;
        esx     = true;
        http    = true;
        ipmi    = true;
        network = true;
        openvpn = true;
        snmp    = true;
        ups     = true;
      };

      rabbitmq = [{
        host = monitorHost;
        user = "sensu";
        inherit password;
        port = 5671;
        ssl = {
          cert_chain_file  = "${clientKeys}/chain.pem";
          private_key_file = "${clientKeys}/key.pem";
        };
      }];
    };
  };

  clientKeys = makeKeyPackage "client";
  serverKeys = makeKeyPackage "server";
}
