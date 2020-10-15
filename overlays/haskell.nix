self:
pkgs:
let
  srcs = [];
  sources = import ../nix/sources.nix;

  packageDrv = ghc:
    callPackage (usingWithHoogle self.haskell.packages.${ghc}) ghc;

  otherHackagePackages = ghc:
    let
      pkg = p: self.packageDrv ghc p {};
    in
      self: super:
        with pkgs.haskell.lib; {
          Agda = doJailbreak (dontHaddock super.Agda);
          Diff = dontCheck super.Diff;
          aeson = overrideCabal super.aeson (
            attrs: {
              libraryHaskellDepends =
                attrs.libraryHaskellDepends ++ [ self.contravariant ];
            }
          );
          base-compat-batteries = doJailbreak super.base-compat-batteries;
          diagrams-contrib = doJailbreak super.diagrams-contrib;
          diagrams-graphviz = doJailbreak super.diagrams-graphviz;
          diagrams-svg = doJailbreak super.diagrams-svg;
          generic-lens = dontCheck super.generic-lens;
          haddock-library = dontHaddock super.haddock-library;
          hasktags = dontCheck super.hasktags;
          language-ecmascript = doJailbreak super.language-ecmascript;
          liquidhaskell = doJailbreak super.liquidhaskell;
          pipes-binary = doJailbreak super.pipes-binary;
          pipes-text = unmarkBroken (doJailbreak super.pipes-text);
          EdisonAPI = unmarkBroken super.EdisonAPI;
          EdisonCore = unmarkBroken super.EdisonCore;
          pipes-zlib = dontCheck (doJailbreak super.pipes-zlib);
          text-show = dontCheck (doJailbreak super.text-show);
          time-compat = doJailbreak super.time-compat;
          time-recurrence = unmarkBroken (doJailbreak super.time-recurrence);
          tls = dontCheck super.tls;
          rebase = doJailbreak super.rebase;

          ListLike = overrideCabal super.ListLike (
            attrs: {
              libraryHaskellDepends =
                attrs.libraryHaskellDepends ++ [ self.semigroups ];
            }
          );

          cabal2nix = dontCheck super.cabal2nix;
        };

  callPackage = hpkgs: ghc: path: args:
    filtered (
      if builtins.pathExists (path + "/default.nix")
      then hpkgs.callPackage path
        (
          {
            pkgs = self;
            compiler = ghc;
            returnShellEnv = false;
          } // args
        )
      else hpkgs.callCabal2nix hpkgs (builtins.baseNameOf path) path args
    );

  myHaskellPackages = ghc: self: super:
    let
      fromSrc = arg:
        let
          path = if builtins.isList arg then builtins.elemAt arg 0 else arg;
          args = if builtins.isList arg then builtins.elemAt arg 1 else {};
        in
          {
            name = builtins.baseNameOf path;
            value = callPackage self ghc (~/src + "/${path}") args;
          };
    in
      builtins.listToAttrs (builtins.map fromSrc srcs);

  usingWithHoogle = hpkgs: hpkgs // rec {
    ghc = hpkgs.ghc // { withPackages = hpkgs.ghc.withHoogle; };
    ghcWithPackages = ghc.withPackages;
  };

  overrideHask = ghc: hpkgs: hoverrides: hpkgs.override {
    overrides =
      pkgs.lib.composeExtensions
        hoverrides
        (
          pkgs.lib.composeExtensions
            (otherHackagePackages ghc)
            (
              pkgs.lib.composeExtensions
                (myHaskellPackages ghc)
                (
                  self: super: {
                    ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
                    ghcWithPackages = self.ghc.withPackages;

                    developPackage =
                      { root
                      , name ? builtins.baseNameOf root
                      , source-overrides ? {}
                      , overrides ? self: super: {}
                      , modifier ? drv: drv
                      , returnShellEnv ? pkgs.lib.inNixShell
                      }:
                        let
                          hpkgs =
                            (
                              pkgs.lib.composeExtensions
                                (_: _: self)
                                (
                                  pkgs.lib.composeExtensions
                                    (self.packageSourceOverrides source-overrides)
                                    overrides
                                )
                            ) {} super;
                          drv =
                            hpkgs.callCabal2nix name root {};
                        in
                          if returnShellEnv
                          then (modifier drv).env
                          else modifier drv;
                  }
                )
            )
        );
  };

  breakout = super: names:
    builtins.listToAttrs
      (
        builtins.map
          (
            x: {
              name = x;
              value = pkgs.haskell.lib.doJailbreak super.${x};
            }
          )
          names
      );

  filtered = drv:
    drv.overrideAttrs
      (attrs: { src = self.haskellFilterSource [] attrs.src; });

in
{

  haskellFilterSource = paths: src: pkgs.lib.cleanSourceWith {
    inherit src;
    filter = path: type:
      let
        baseName = baseNameOf path;
      in
        !(
          type == "directory"
          && builtins.elem baseName ([ ".git" ".cabal-sandbox" "dist" ] ++ paths)
        )
        && !(
          type == "unknown"
          || baseName == "cabal.sandbox.config"
          || baseName == "result"
          || pkgs.stdenv.lib.hasSuffix ".hdevtools.sock" path
          || pkgs.stdenv.lib.hasSuffix ".sock" path
          || pkgs.stdenv.lib.hasSuffix ".hi" path
          || pkgs.stdenv.lib.hasSuffix ".hi-boot" path
          || pkgs.stdenv.lib.hasSuffix ".o" path
          || pkgs.stdenv.lib.hasSuffix ".dyn_o" path
          || pkgs.stdenv.lib.hasSuffix ".dyn_p" path
          || pkgs.stdenv.lib.hasSuffix ".o-boot" path
          || pkgs.stdenv.lib.hasSuffix ".p_o" path
        );
  };

  haskell = pkgs.haskell // {
    packages = pkgs.haskell.packages // {
      ghc865 = overrideHask "ghc865" pkgs.haskell.packages.ghc865 (
        self: super:
          (
            breakout super [
              "hakyll"
              "pandoc"
            ]
          )
          // (
            with pkgs.haskell.lib; {
              inherit (pkgs.haskell.packages.ghc884) hpack;
            }
          )
      );

      ghc884 = overrideHask "ghc884" pkgs.haskell.packages.ghc884 (
        self: super:
          (
            breakout super [
              "hakyll"
              "pandoc"
            ]
          )
      );
    };
  };

  haskellPackages_8_6 = self.haskell.packages.ghc865;
  haskellPackages_8_8 = self.haskell.packages.ghc884;
  haskellPackages_8_10 = self.haskell.packages.ghc8101;

  haskellPackages = self.haskell.packages.${self.ghcDefaultVersion};
  haskPkgs = self.haskellPackages;

  ghcDefaultVersion = "ghc884";


  ghcVersionInstance = myPkgs: hpkgs: (
    hpkgs.ghcWithHoogle (
      pkgs:
        with pkgs;
        myPkgs pkgs
    )
  );

  ghcSystem = with self; myPkgs: (ghcVersionInstance myPkgs haskPkgs);

}
