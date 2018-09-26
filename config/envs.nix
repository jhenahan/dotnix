self: pkgs:

let myEmacsPackages   = import ./emacs.nix pkgs;
    myHaskellPackages = import ./haskell.nix pkgs;
in
{
  emacs26Env      = pkgs.emacs26Env myEmacsPackages;
  emacs26System   = pkgs.emacs26System myEmacsPackages;

  ghc84Env        = pkgs.ghc84Env (myHaskellPackages 8.4);
  ghc84System     = pkgs.ghc84System (myHaskellPackages 8.4);

  allEnvs = with self; [
    emacs26Env
    ghc84Env
  ];
}
