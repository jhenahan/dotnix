self: pkgs:

let
  myEmacsPackages = import ./emacs.nix pkgs;
  myHaskellPackages = import ./haskell.nix pkgs;
  myRustConfig = import ./rust.nix;
in
{
  #emacs26System = pkgs.emacs26System myEmacsPackages;
  emacs27System = pkgs.emacs27System myEmacsPackages;
  ghcSystem = pkgs.ghcSystem (myHaskellPackages 8.8);
  rustSystem = pkgs.latest.rustChannels.stable.rust.override myRustConfig;
}
