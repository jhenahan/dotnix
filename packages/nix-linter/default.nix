{ callPackage }:

let
  sources = import ../nix/sources.nix;
in

(callPackage sources.nix-linter {}).nix-linter
