self: pkgs:

let myEmacsPackages   = import ./emacs.nix pkgs;
    myHaskellPackages = import ./haskell.nix pkgs;
    myRustConfig = import ./rust.nix;
in
{
  emacs26System   = pkgs.emacs26System myEmacsPackages;
  ghc86System     = pkgs.ghc86System (myHaskellPackages 8.6);
  rustSystem      = (pkgs.rustChannelOf { date = "2019-01-26"; channel = "nightly"; }).rust.override myRustConfig;
}
