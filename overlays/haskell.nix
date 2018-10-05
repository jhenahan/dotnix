self:
  pkgs:
    let
      srcs = [ "hasktags" ];
      otherHackagePackages = ghc:
        let
          pkg = p:
            self.packageDrv ghc p {};
        in self:
          super:
            with pkgs.haskell.lib;
            {
              base-compat-batteries = doJailbreak (super.base-compat-batteries);
              diagrams-contrib = doJailbreak (super.diagrams-contrib);
              diagrams-graphviz = doJailbreak (super.diagrams-graphviz);
              diagrams-svg = doJailbreak (super.diagrams-svg);
              generic-lens = dontCheck (super.generic-lens);
              haddock-library = dontHaddock (super.haddock-library);
              language-ecmascript = doJailbreak (super.language-ecmascript);
              liquidhaskell = doJailbreak (super.liquidhaskell);
              pipes-binary = doJailbreak (super.pipes-binary);
              pipes-text = doJailbreak (super.pipes-text);
              pipes-zlib = dontCheck (doJailbreak (super.pipes-zlib));
              text-show = dontCheck (doJailbreak (super.text-show));
              time-recurrence = doJailbreak (super.time-recurrence);
              html-entities = doJailbreak (addSetupDepends super.html-entities [ super.cabal-doctest ]);
              recursors = doJailbreak (addSetupDepends super.recursors [ super.QuickCheck super.hspec super.template-haskell ]);
              ListLike = overrideCabal (super.ListLike) (attrs:
                {
                  libraryHaskellDepends = attrs.libraryHaskellDepends ++ [
                    (self.semigroups)
                  ];
                });
              cabal2nix = dontCheck (super.cabal2nix);
              dhall = dontCheck (super.dhall_1_17_0.overrideAttrs (attrs:
                {
                  strictDeps = true;
                  nativeBuildInputs = [
                    (pkgs.cacert)
                  ] ++ attrs.nativeBuildInputs;
                }));
              ghc-exactprint = self.callCabal2nix "ghc-exactprint" (pkgs.fetchFromGitHub {
                owner = "alanz";
                repo = "ghc-exactprint";
                rev = "8df39b87ebaeb4248a945e54ae1f0f02c25dd14d";
                sha256 = "10pzn71nnfrmyywqv50vfak7xgf19c9aqy3i8k92lns5x9ycfqdv";
              }) {};
              Agda-git = self.callCabal2nix "Agda" (pkgs.fetchFromGitHub {
                owner = "agda";
                repo = "agda";
                rev = "3afae4659ea166933af672af8359bdd4d4349d1f";
                sha256 = "12q467vfnxk0dxpc8bkk31w84kq0alhpczz4ajd2arhrgdv3v1g5";
              }) {};
              Agda = dontCheck (doJailbreak (addSetupDepends self.Agda-git [ super.attoparsec super.containers super.convertible super.mtl super.time ]));
              brittany = self.callCabal2nix "brittany" (pkgs.fetchFromGitHub {
                owner = "lspitzner";
                repo = "brittany";
                rev = "460bd4dd2b14c11b171de99e61e3d778bb523604";
                sha256 = "1df1bxbc5gzlb7ifamdng95nrgsz8qlkwswvybcir35mj7cplblw";
              }) {};
              ghc-datasize = overrideCabal (super.ghc-datasize) (attrs:
                {
                  enableLibraryProfiling = false;
                  enableExecutableProfiling = false;
                });
              ghc-heap-view = overrideCabal (super.ghc-heap-view) (attrs:
                {
                  enableLibraryProfiling = false;
                  enableExecutableProfiling = false;
                });
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
      myHaskellPackages = ghc:
        self:
          super:
            let
              fromSrc = arg:
                let
                  path = if builtins.isList arg
                    then builtins.elemAt arg 0
                    else arg;
                  args = if builtins.isList arg
                    then builtins.elemAt arg 1
                    else {};
                in {
                  name = builtins.baseNameOf path;
                  value = callPackage self ghc (~/src + "/${path}") args;
                };
            in builtins.listToAttrs (builtins.map fromSrc srcs);
      usingWithHoogle = hpkgs:
        hpkgs // rec {
          ghc = hpkgs.ghc // {
            withPackages = hpkgs.ghc.withHoogle;
          };
          ghcWithPackages = ghc.withPackages;
        };
      overrideHask = ghc:
        hpkgs:
          hoverrides:
            hpkgs.override {
              overrides = pkgs.lib.composeExtensions hoverrides (pkgs.lib.composeExtensions (otherHackagePackages ghc) (pkgs.lib.composeExtensions (myHaskellPackages ghc) (self:
                super:
                  {
                    ghc = super.ghc // {
                      withPackages = super.ghc.withHoogle;
                    };
                    ghcWithPackages = self.ghc.withPackages;
                    
                    developPackage = { root
                                     , source-overrides ? {}
                                     , overrides ? self:
                                       super:
                                         {}
                                     , modifier ? drv:
                                       drv
                                     , returnShellEnv ? pkgs.lib.inNixShell }:
                      let
                        drv = ((pkgs.lib.composeExtensions (_:
                          _:
                            self) (pkgs.lib.composeExtensions (self.packageSourceOverrides source-overrides) overrides)) {} super).callCabal2nix (builtins.baseNameOf root) root {};
                      in if returnShellEnv
                        then modifier drv.env
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
            ghc843 = "2.4.0.0";
          };
          hie-nix = import (pkgs.fetchFromGitHub {
            owner = "domenkozar";
            repo = "hie-nix";
            rev = "96af698f0cfefdb4c3375fc199374856b88978dc";
            sha256 = "1bcw59zwf788wg686p3qmcq03fr7bvgbcaa83vq8gvg231bgid4m";
          }) {};
          hie = {
            ghc843 = hie-nix.hie84;
          };
        in compiler.withHoogle (p:
          with p;
          [
            hpack
            criterion
            hdevtools
            (self.haskell.lib.doJailbreak (callHackage "cabal-install" (cabal.${ghc}) {}))
            hie.${ghc}
          ] ++ packages.haskellBuildInputs);
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          ghc843 = overrideHask "ghc843" (pkgs.haskell.packages.ghc843) (self:
            super:
              breakout super [
                "compact"
                "criterion"
                "text-format"
              ] // (with pkgs.haskell.lib;
              {
                text-format = doJailbreak (overrideCabal (super.text-format) (drv:
                  {
                    src = pkgs.fetchFromGitHub {
                      owner = "deepfire";
                      repo = "text-format";
                      rev = "a1cda87c222d422816f956c7272e752ea12dbe19";
                      sha256 = "0lyrx4l57v15rvazrmw0nfka9iyxs4wyaasjj9y1525va9s1z4fr";
                    };
                  }));
              }));
        };
      };
      haskellPackages_8_4 = self.haskell.packages.ghc843;
      ghcDefaultVersion = "ghc843";
      haskellPackages = self.haskellPackages_8_4;
      haskPkgs = self.haskellPackages;
      ghc84System = myPkgs: (self.haskellPackages_8_4.ghcWithHoogle (pkgs:
        with pkgs;
        myPkgs pkgs ++ [ compact ]));
      ghc84Env = myPkgs:
        pkgs.myEnvFun {
          name = "ghc84";
          buildInputs = with self.haskellPackages_8_4;
          [
            (ghcWithHoogle (pkgs:
              with pkgs;
              myPkgs pkgs ++ [ compact ]))
          ];
        };
    }
