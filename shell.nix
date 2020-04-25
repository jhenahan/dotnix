{ sources ? import ./nix/sources.nix }:

let
  pkgs = import (sources.nixpkgs) {};
  hm = import (sources.home-manager) {};

  niv = pkgs.symlinkJoin {
    name = "niv";
    paths = [ sources.niv ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/niv \
        --add-flags "--sources-file ${toString ./nix/sources.json}"
    '';
  };

  build-nix-path-env-var = path:
    builtins.concatStringsSep ":" (
      pkgs.lib.mapAttrsToList (k: v: "${k}=${v}") path
    );

  nix-path = build-nix-path-env-var {
    nixpkgs = sources.nixpkgs;
    nixpkgs-overlays = "$dotfiles/overlays";
    darwin-config = "$dotfiles/config/darwin.nix";
    darwin = sources.darwin;
    home-manager = sources.home-manager;
  };

  files = "$(find . -name '*.nix')";

  format = pkgs.writeShellScriptBin "format" "nixpkgs-fmt ${files}";

  set-nix-path = ''
    export dotfiles="$(nix-build --no-out-link)"
    export NIX_PATH="${nix-path}"
  '';

  deploy-root-cmd = pkgs.writeShellScript "deploy-root-cmd" ''
    ${set-nix-path}
    darwin-rebuild ''${1-switch} --show-trace
    home-manager ''${1-switch}
  '';


  mk-json-string = data: "{" + (builtins.concatStringsSep "," data) + "}";

  deploy = pkgs.writeShellScriptBin "deploy" ''
    set -e
    ${format}/bin/format
    ${deploy-root-cmd} $1
  '';

  collect-garbage =
    pkgs.writeShellScriptBin "collect-garbage" "sudo nix-collect-garbage -d";
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.nixpkgs-fmt
    hm.home-manager
    niv
    format
    deploy
    collect-garbage
  ];
}
