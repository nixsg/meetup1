{ invoicer ? { outPath = ./.; name = "invoicer"; }
, pkgs ? import <nixpkgs> {} }:

let
  ruby = pkgs.ruby_2_4;
  bundler = pkgs.bundler.override { inherit ruby; };
  stdenv = pkgs.stdenv;
  _name = "invoicer";

  env = pkgs.bundlerEnv {
    name = "${_name}-env";
    inherit bundler ruby;
    gemdir = ./config;
  };

  run = let
    b = "${env.bundler}/bin/bundle";
  in ''
    #!${stdenv.shell} -eu
    export BUNDLE_BIN=${b}
    export RUBY_VERSION=${env.ruby.version}
    cd $out
    ${b} exec rake -T
  '';

in stdenv.mkDerivation rec {
  version = "0.0.1";
  name = "${_name}-${version}";

  # phases = [ "installPhase" ];

  buildInputs = with pkgs; [
  ];

  propagatedBuildInputs = [
    ruby bundler
  ] ++ (with pkgs; [
    freetds
    libxml2
    unixODBC
  ]);

  src = [
    "config"
    "lib"
  ];

  meta = with pkgs.lib; {
    description = "CEC Invoicer";
    homepage    = https://speartail.com/;
    # license     = with licenses; unfree;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.unix;
  };
}
