self:
  pkgs:
    let
      srcs = [
      ];
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
        in self:
          super:
            with pkgs.haskell.lib;
            {
              #hbeat = unmarkBroken super.hbeat;
              algebra = bigBreak super.algebra;
              c2hsc = unmarkBroken super.c2hsc;
              Cabal = super.Cabal_2_4_1_0;
              cabal-install = super.callHackage "cabal-install" "2.4.1.0" {};
              cachix = unmarkBroken super.cachix;
              cachix-api = unmarkBroken super.cachix-api;
              co-log = unmarkBroken super.co-log;
              co-log-polysemy = bigBreak super.co-log-polysemy;
              compressed = bigBreak super.compressed;
              #haskell-src-exts-simple = unmarkBroken (super.haskell-src-exts-simple.overrideScope (self: super: { haskell-src-exts = self.haskell-src-exts_1_21_0; }));
              hierarchy = bigBreak super.hierarchy;
              higgledy = doJailbreak (dontCheck (unmarkBroken super.higgledy));
              hpack = dontCheck super.hpack;
              massiv = unmarkBroken super.massiv;
              scheduler = unmarkBroken super.scheduler;
              ormolu = dontCheck (self.callCabal2nix "ormolu" (pkgs.fetchFromGitHub {
               owner = "tweag";
               repo = "ormolu";
               rev = "de1a2789c0bc183e04aa2800db1af9ba881eb2e8";
               sha256 = "19ydr39fwbg89zqrkwhxmnaacpw0ffg81mryk6z9yh956sxgm3l2";
              }) {});
              perhaps = bigBreak super.perhaps;
              pointful = bigBreak super.pointful;
              polysemy = dontCheck (self.callCabal2nix "polysemy" (pkgs.fetchFromGitHub {
               owner = "polysemy-research";
               repo = "polysemy";
               rev = "ac6d7b312114863987f103871df54b2a5d1fe7d8";
               sha256 = "148pbpivpka2dlnym98dws2njli1v4f0zq8bq4rklrfzdraayd9a";
              }) {});
              polysemy-plugin = dontCheck (self.callHackage "polysemy-plugin" "0.2.3.0" {});
              polysemy-zoo = dontCheck (self.callCabal2nix "polysemy-zoo" (pkgs.fetchFromGitHub {
               owner = "polysemy-research";
               repo = "polysemy-zoo";
               rev = "5f7c1a7da2b424356d40fad253bc2551cf30ce7f";
               sha256 = "03dgdhpzypxvygmh5jji973x9kidkh8043l807alra7s5bqqbf1l";
              }) {});
              #polysemy-zoo = dontCheck (self.callCabal2nix "polysemy-zoo" (pkgs.fetchFromGitHub {
              # owner = "polysemy-research";
              # repo = "polysemy-zoo";
              # rev = "5a6d359ee989e9da610578e82505b9fd0fa04175";
              # sha256 = "1aa62s5k5iaji6c2jk3c26nmlbsbhcckmy8xfl1rq8l2zry4p2ps";
              #}) {});
              #th-lift = super.th-lift_0_8_0_1;
              #th-lift-instances = super.th-lift-instances_0_1_13;
              #time-compat = dontCheck super.time-compat_1_9_2_2;
              typerep-map = bigBreak super.typerep-map;
              #type-errors = unmarkBroken super.type-errors;
              #concurrent-output = super.concurrent-output_1_10_10;
              #Agda = dontCheck (self.callCabal2nix "Agda" (pkgs.fetchFromGitHub {
              #  owner = "agda";
              #  repo = "agda";
              #  rev = "6f3046e081ebfa40793c3a064e53bdbd83c82dcf";
              #  sha256 = "1pgffhzs3c23cfc4klllyy5z3yjrahgylagw88b32psci050bn4c";
              #}) {});
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
              filtered (if builtins.pathExists (path + "/default.nix")
                then hpkgs.callPackage path ({
                  pkgs = self;
                  compiler = ghc;
                  returnShellEnv = false;
                } // args)
                else hpkgs.callCabal2nix hpkgs (builtins.baseNameOf path) path args);
      myHaskellPackages = ghc: self: super:
        let fromSrc = arg:
          let
            path = if builtins.isList arg then builtins.elemAt arg 0 else arg;
            args = if builtins.isList arg then builtins.elemAt arg 1 else {};
          in {
            name  = builtins.baseNameOf path;
            value = callPackage self ghc (~/src + "/${path}") args;
          };
        in builtins.listToAttrs (builtins.map fromSrc srcs);

      usingWithHoogle = hpkgs: hpkgs // rec {
        ghc = hpkgs.ghc // { withPackages = hpkgs.ghc.withHoogle; };
        ghcWithPackages = ghc.withPackages;
      };
        overrideHask = ghc: hpkgs: hoverrides: hpkgs.override {
          overrides =
            pkgs.lib.composeExtensions
              hoverrides
              (pkgs.lib.composeExtensions
                 (otherHackagePackages ghc)
                 (pkgs.lib.composeExtensions
                    (myHaskellPackages ghc)
                    (self: super: {
                       ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
                       ghcWithPackages = self.ghc.withPackages;

                       developPackage =
                         { root
                         , name ? builtins.baseNameOf root
                         , source-overrides ? {}
                         , overrides ? self: super: {}
                         , modifier ? drv: drv
                         , returnShellEnv ? pkgs.lib.inNixShell }:
                         let hpkgs =
                           (pkgs.lib.composeExtensions
                               (_: _: self)
                               (pkgs.lib.composeExtensions
                                  (self.packageSourceOverrides source-overrides)
                                  overrides)) {} super;
                             drv = hpkgs.callCabal2nix name root {};
                         in if returnShellEnv
                            then (modifier drv).env
                            else modifier drv;
                     })));
        };
      breakout = super:
        names:
          builtins.listToAttrs (builtins.map (x:
            {
              name = x;
              value = pkgs.haskell.lib.doJailbreak (super.${x});
            }) names);
      filtered = drv:
        drv.overrideAttrs (attrs:
          {
            src = self.haskellFilterSource [] (attrs.src);
          });
    in {
      haskellFilterSource = paths:
        src:
          pkgs.lib.cleanSourceWith {
            inherit src;
            filter = path:
              type:
                let
                  baseName = baseNameOf path;
                in !(type == "directory" && builtins.elem baseName ([
                  ".git"
                  ".cabal-sandbox"
                  "dist"
                ] ++ paths)) && !(type == "unknown" || baseName == "cabal.sandbox.config" || baseName == "result" || pkgs.stdenv.lib.hasSuffix ".hdevtools.sock" path || pkgs.stdenv.lib.hasSuffix ".sock" path || pkgs.stdenv.lib.hasSuffix ".hi" path || pkgs.stdenv.lib.hasSuffix ".hi-boot" path || pkgs.stdenv.lib.hasSuffix ".o" path || pkgs.stdenv.lib.hasSuffix ".dyn_o" path || pkgs.stdenv.lib.hasSuffix ".dyn_p" path || pkgs.stdenv.lib.hasSuffix ".o-boot" path || pkgs.stdenv.lib.hasSuffix ".p_o" path);
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
            ghc865 = "2.4.1.0";
          };
        in compiler.withHoogle (p:
          with p;
          [
            hpack
            criterion
            (self.haskell.lib.doJailbreak (callHackage "cabal-install" (cabal.${ghc}) {}))
          ] ++ packages.haskellBuildInputs);
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc865 = overrideHask "ghc865" pkgs.haskell.packages.ghc865 (self: super: {});
        };
      };
      haskellPackages_8_6 = self.haskell.packages.ghc865;
      ghcDefaultVersion = "ghc865";
      haskellPackages = self.haskell.packages.${self.ghcDefaultVersion};
      haskPkgs = self.haskellPackages;
      ghcSystem = myPkgs: hpkgs: (hpkgs.ghcWithHoogle (pkgs:
        with pkgs;
        myPkgs pkgs ++ [ compact ]));

      ghc86System = with self; myPkgs: (ghcSystem myPkgs haskellPackages_8_6);

      ghcEnv = myPkgs: hpkgs: envName:
        pkgs.myEnvFun {
          name = envName;
          buildInputs = with hpkgs;
          [
            (ghcWithHoogle (pkgs:
              with pkgs;
              myPkgs pkgs ++ [ compact ]))
          ];
        };
      ghc86Env = with self; myPkgs: (ghcEnv myPkgs haskellPackages_8_6 "ghc86");
    }
