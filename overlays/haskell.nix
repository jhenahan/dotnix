self:
  pkgs:
    let
      srcs = [
        "hasktags"
        "pipes-async"
        "rebase"
        "rerebase"
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
        in self:
          super:
            with pkgs.haskell.lib;
            {
              #base-compat-batteries = dontCheck (doJailbreak (addSetupDepends super.base-compat-batteries [ super.contravariant ]));
              async-pool = doJailbreak (unbreak super.async-pool);
              bytestring-show = doJailbreak (unbreak super.bytestring-show);
              c2hsc = unbreak super.c2hsc;
              kdt = unbreak super.kdt;
              compressed = doJailbreak (unbreak super.compressed);
              Agda = dontCheck (self.callCabal2nix "Agda" (pkgs.fetchFromGitHub {
                owner = "agda";
                repo = "agda";
                rev = "6f3046e081ebfa40793c3a064e53bdbd83c82dcf";
                sha256 = "1pgffhzs3c23cfc4klllyy5z3yjrahgylagw88b32psci050bn4c";
              }) {});
              equivalence = dontCheck super.equivalence;
              Chart = doJailbreak (self.callCabal2nixWithOptions "Chart" (pkgs.fetchFromGitHub {
                owner = "timbod7";
                repo = "haskell-chart";
                rev = "23e9739b80ecbb6fe70c4a7989714414f9f915c7";
                sha256 = "14irxdaa9vykf958izfsjdc2mdzm5fjrwbw7c53nfjm0vfg2qr46";
              }) ''--subpath chart'' {});
              Chart-diagrams = doJailbreak (self.callCabal2nixWithOptions "Chart-diagrams" (pkgs.fetchFromGitHub {
                owner = "timbod7";
                repo = "haskell-chart";
                rev = "23e9739b80ecbb6fe70c4a7989714414f9f915c7";
                sha256 = "14irxdaa9vykf958izfsjdc2mdzm5fjrwbw7c53nfjm0vfg2qr46";
              }) ''--subpath chart-diagrams'' {});
              SVGFonts-git = doJailbreak (self.callCabal2nix "SVGFonts" (pkgs.fetchFromGitHub {
                owner = "diagrams";
                repo = "SVGFonts";
                rev = "f1e163e90c57ccce700b1775dad10c982cf3a587";
                sha256 = "0d0b2djsim4h7r2b58q1rrls1wwvikbmk9b0iqpn3d6plai92mq7";
              }) {});
              SVGFonts = overrideCabal self.SVGFonts-git (attrs:
              {
                libraryHaskellDepends = attrs.libraryHaskellDepends ++ [ super.tuple ];
              });
              hfsevents = overrideCabal super.hfsevents (attrs:
              {
                platforms = pkgs.stdenv.lib.platforms.darwin;
              });
              diagrams-postscript = doJailbreak super.diagrams-postscript;
              hierarchy = doJailbreak (unbreak super.hierarchy);
              heap = dontCheck (unbreak super.heap);
              html-entities = addSetupDepends super.html-entities [ super.cabal-doctest ];
              lattices = dontCheck (unbreak super.lattices);
              machinecell = doJailbreak (unbreak super.machinecell);
              pipes-safe = doJailbreak super.pipes-safe;
              recursors = seriouslyWith (unbreak super.recursors) [ super.template-haskell ];
              pipes-zlib = dontCheck super.pipes-zlib;
              pipes-text = doJailbreak (unbreak super.pipes-text);
              speculation = doJailbreak (unbreak super.speculation);
              time-recurrence = doJailbreak (unbreak super.time-recurrence);
              pointful = doJailbreak (unbreak super.pointful);
              servant-streaming-server = doJailbreak super.servant-streaming-server;
              #base-compat-batteries = doJailbreak (overrideCabal (super.base-compat-batteries) (attrs:
              #  {
              #    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
              #      self.contravariant
              #    ];
              #  }));
              #Diff = dontCheck (doJailbreak super.Diff);
              #cereal = dontCheck (doJailbreak super.cereal);
              #these = dontCheck (doJailbreak super.these);
              #pandoc = dontCheck (doJailbreak super.pandoc);
              #aeson = doJailbreak (overrideCabal (super.aeson) (attrs:
              #  {
              #    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
              #      self.contravariant
              #    ];
              #  }));
              #heap = dontCheck (doJailbreak super.heap);
              #hakyll = doJailbreak (overrideCabal (super.hakyll) (attrs:
              #  {
              #    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
              #      self.pandoc
              #      self.pandoc-citeproc
              #    ];
              #  }));
              #servant-docs = dontCheck (doJailbreak super.servant-docs);
              #insert-ordered-containers = dontCheck (doJailbreak super.insert-ordered-containers);
              #stylish-haskell = dontCheck (doJailbreak super.stylish-haskell);
              #binary-orphans = dontCheck (doJailbreak super.binary-orphans);
              #machinecell = dontCheck (doJailbreak super.machinecell);
              #tdigest = dontCheck (doJailbreak super.tdigest);
              #diagrams-contrib = doJailbreak super.diagrams-contrib;
              #doctest-prop = dontCheck (doJailbreak super.doctest-prop);
              #diagrams-graphviz = doJailbreak super.diagrams-graphviz;
              #diagrams-svg = doJailbreak super.diagrams-svg;
              #generic-lens = overrideCabal (dontCheck (doJailbreak super.generic-lens)) (drv: { patches = []; });
              #haddock-library = dontHaddock super.haddock-library;
              #language-ecmascript = doJailbreak super.language-ecmascript;
              #liquidhaskell = doJailbreak super.liquidhaskell;
              #pipes-async = doJailbreak super.pipes-async;
              #pipes-binary = doJailbreak super.pipes-binary;
              #pipes-text = doJailbreak super.pipes-text;
              #pipes-zlib = dontCheck (doJailbreak super.pipes-zlib);
              #psqueues = dontCheck (doJailbreak super.psqueues);
              #text-show = dontCheck (doJailbreak super.text-show);
              #text-show = dontCheck (doJailbreak super.text-show);
              #html-entities = doJailbreak (addSetupDepends super.html-entities [ super.cabal-doctest ]);
              #rerebase = doJailbreak (addSetupDepends super.rerebase [ super.rebase ]);
              #recursors = doJailbreak (addSetupDepends super.recursors [ super.QuickCheck super.hspec super.template-haskell ]);
              #ListLike = overrideCabal (super.ListLike) (attrs:
              #  {
              #    libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
              #      (self.semigroups)
              #    ];
              #  });
              ##cabal2nix = dontCheck (super.cabal2nix);
              #darcs = doJailbreak super.darcs;
              #graphviz = doJailbreak (dontCheck super.graphviz);
              ##megaparsec = super.megaparsec_7_0_4;
              ##hspec-megaparsec = super.hspec-megaparsec_2_0_0;
              ##modern-uri = super.modern-uri_0_3_0_1;
              ##versions = super.versions_3_5_0;
              ##repline = super.repline_0_2_0_0;
              ##dhall = super.dhall_1_19_1;
              #ghc-exactprint = self.callCabal2nix "ghc-exactprint" (pkgs.fetchFromGitHub {
              #  owner = "alanz";
              #  repo = "ghc-exactprint";
              #  rev = "8df39b87ebaeb4248a945e54ae1f0f02c25dd14d";
              #  sha256 = "10pzn71nnfrmyywqv50vfak7xgf19c9aqy3i8k92lns5x9ycfqdv";
              #}) {};
              #Agda = dontCheck (doJailbreak super.Agda);
              #brittany = self.callCabal2nix "brittany" (pkgs.fetchFromGitHub {
              #  owner = "lspitzner";
              #  repo = "brittany";
              #  rev = "621e00bf3f24896d603978c3d4e5fd61dac3841a";
              #  sha256 = "1shd30mfncqzdrcnmm5pfvgsivv030s7y9isn3753dclj5jag5aa";
              #}) {};
              #ghc-datasize = overrideCabal (super.ghc-datasize) (attrs:
              #  {
              #    enableLibraryProfiling = false;
              #    enableExecutableProfiling = false;
              #  });
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
            ghc864 = "2.4.1.0";
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
          ghc864 = overrideHask "ghc864" pkgs.haskell.packages.ghc864 (self: super: {});
        };
      };
      haskellPackages_8_6 = self.haskell.packages.ghc864;
      ghcDefaultVersion = "ghc864";
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
