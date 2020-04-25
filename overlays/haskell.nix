self:
pkgs:
let
  srcs = [];
  sources = import ../nix/sources.nix;
  otherHackagePackages = ghc:
    let
      pkg = p:
        self.packageDrv ghc p {};
      seriously = p:
        with pkgs.haskell.lib;
        dontCheck (doJailbreak p);
      seriouslyWith = p: ps:
        with pkgs.haskell.lib;
        seriously (addSetupDepends p ps);
      bigBreak = p:
        with pkgs.haskell.lib;
        doJailbreak (unmarkBroken p);
    in
      self:
      super:
        with pkgs.haskell.lib;
        {
          Agda-dev = self.callCabal2nix "Agda" (
            pkgs.fetchFromGitHub {
              owner = "agda";
              repo = "agda";
              rev = "cfba5317228f50d2d248b622b162bc8bd2932bc7";
              sha256 = "1c42xpnsml5rsqmspxb8y6lk36abzaxgnmdnz3iqjvdvr34vwny2";
            }
          ) {};
          Agda = dontCheck (
            self.Agda-dev.overrideScope (
              self: super: {
                regex-compat = self.regex-compat_0_95_2_0;
                regex-pcre-builtin = self.regex-pcre-builtin_0_95_1_1_8_43;
                regex-posix = self.regex-posix_0_96_0_0;
                regex-base = self.regex-base_0_94_0_0;
                regex-tdfa = self.regex-tdfa_1_3_1_0;
              }
            )
          );
          #base-compat-batteries = doJailbreak (overrideCabal (super.base-compat-batteries) (attrs:
          #  {
          #    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
          #      self.contravariant
          #    ];
          #  }));
          #ghc-heap-view = overrideCabal (super.ghc-heap-view) (attrs:
          #  {
          #    enableLibraryProfiling = false;
          #    enableExecutableProfiling = false;
          #  });
        };
  callPackage = hpkgs:
  ghc:
  path:
  args:
    filtered (
      if builtins.pathExists (path + "/default.nix")
      then hpkgs.callPackage path (
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
                          drv = hpkgs.callCabal2nix name root {};
                        in
                          if returnShellEnv
                          then (modifier drv).env
                          else modifier drv;
                  }
                )
            )
        );
  };
  breakout = super:
  names:
    builtins.listToAttrs (
      builtins.map (
        x:
          {
            name = x;
            value = pkgs.haskell.lib.doJailbreak (super.${x});
          }
      ) names
    );
  filtered = drv:
    drv.overrideAttrs (
      attrs:
        {
          src = self.haskellFilterSource [] (attrs.src);
        }
    );
in
{
  haskellFilterSource = paths:
  src:
    pkgs.lib.cleanSourceWith {
      inherit src;
      filter = path:
      type:
        let
          baseName = baseNameOf path;
        in
          !(
            type == "directory" && builtins.elem baseName (
              [
                ".git"
                ".cabal-sandbox"
                "dist"
              ] ++ paths
            )
          ) && !(type == "unknown" || baseName == "cabal.sandbox.config" || baseName == "result" || pkgs.stdenv.lib.hasSuffix ".hdevtools.sock" path || pkgs.stdenv.lib.hasSuffix ".sock" path || pkgs.stdenv.lib.hasSuffix ".hi" path || pkgs.stdenv.lib.hasSuffix ".hi-boot" path || pkgs.stdenv.lib.hasSuffix ".o" path || pkgs.stdenv.lib.hasSuffix ".dyn_o" path || pkgs.stdenv.lib.hasSuffix ".dyn_p" path || pkgs.stdenv.lib.hasSuffix ".o-boot" path || pkgs.stdenv.lib.hasSuffix ".p_o" path);
    };
  packageDrv = ghc:
    callPackage (usingWithHoogle (self.haskell.packages.${ghc})) ghc;
  packageDeps = path:
    let
      ghc = self.ghcDefaultVersion;
      package = self.packageDrv ghc path {};
      compiler = package.compiler;
      packages = self.haskell.lib.getHaskellBuildInputs package;
      cabal = {
        ghc865 = "3.0.0.0";
      };
    in
      compiler.withHoogle (
        p:
          with p;
          [
            hpack
            criterion
            (self.haskell.lib.doJailbreak (callHackage "cabal-install" (cabal.${ghc}) {}))
          ] ++ packages.haskellBuildInputs
      );
  haskell = pkgs.haskell // {
    packages = pkgs.haskell.packages // {
      ghc865 = overrideHask "ghc865" pkgs.haskell.packages.ghc865 (self: super: {});
    };
  };
  haskellPackages_8_6 = self.haskell.packages.ghc865;
  ghcDefaultVersion = "ghc865";
  haskellPackages = self.haskell.packages.${self.ghcDefaultVersion};
  haskPkgs = self.haskellPackages;
  ghcSystem = myPkgs: hpkgs: (
    hpkgs.ghcWithHoogle (
      pkgs:
        with pkgs;
        myPkgs pkgs ++ [ compact ]
    )
  );

  ghc86System = with self; myPkgs: (ghcSystem myPkgs haskellPackages_8_6);

  ghcEnv = myPkgs: hpkgs: envName:
    pkgs.myEnvFun {
      name = envName;
      buildInputs = with hpkgs;
        [
          (
            ghcWithHoogle (
              pkgs:
                with pkgs;
                myPkgs pkgs ++ [ compact ]
            )
          )
        ];
    };
  ghc86Env = with self; myPkgs: (ghcEnv myPkgs haskellPackages_8_6 "ghc86");
}
