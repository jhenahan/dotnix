self:
super:
let
  sources = import ../nix/sources.nix;
  unstable = import (sources.nixos-unstable) {};
in
{
  dhall-terraform =
    with unstable;
    lowPrio (
      haskell.lib.doJailbreak
        (
          haskellPackages.callPackage sources.dhall-terraform {
            dhall = haskellPackages.dhall_1_29_0;
          }
        )
    );
  easy-dhall =
    let
      pkgs = super;
    in
      import (sources.easy-dhall-nix) {};
}
