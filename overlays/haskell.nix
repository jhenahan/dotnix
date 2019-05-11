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
          unbreak = p:
            with pkgs.haskell.lib;
            overrideCabal p (attrs:
            {
              broken = false;
            });
          bigBreak = p:
            with pkgs.haskell.lib;
            doJailbreak (unbreak p);
        in self:
          super:
            with pkgs.haskell.lib;
            {
              Chart = unbreak super.Chart;
              Chart-diagrams = unbreak super.Chart-diagrams;
              algebra = bigBreak super.algebra;
              ansi-terminal = super.ansi-terminal_0_9;
              bytestring-show = bigBreak super.bytestring-show;
              c2hsc = unbreak super.c2hsc;
              co-log = super.co-log_0_3_0_0;
              co-log-core = super.co-log-core_0_2_0_0;
              co-log-polysemy = unbreak super.co-log-polysemy;
              compressed = bigBreak super.compressed;
              dhall = dontCheck super.dhall_1_22_0;
              haskell-src-exts-simple = unbreak (super.haskell-src-exts-simple.overrideScope (self: super: { haskell-src-exts = self.haskell-src-exts_1_21_0; }));
              hierarchy = bigBreak super.hierarchy;
              lattices = unbreak super.lattices;
              perhaps = bigBreak super.perhaps;
              pointful = bigBreak super.pointful;
              servant-auth-server = dontCheck super.servant-auth-server;
              tls = dontCheck super.tls;
              typerep-map = super.typerep-map_0_3_2;
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
