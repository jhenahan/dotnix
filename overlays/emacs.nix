self:
  pkgs:
    let
      sources = import ../nix/sources.nix;
      myEmacsPackageOverrides = self:
        super:
          let
            inherit (pkgs) fetchurl
                           fetchgit fetchFromGitHub stdenv;
            inherit (stdenv) lib
                             mkDerivation;
            withPatches = pkg:
              patches:
                lib.overrideDerivation pkg (attrs:
                  { inherit patches; });
            compileEmacsFiles = pkgs.callPackage ./emacs/builder.nix;
            addBuildInputs = pkg:
              inputs:
                pkg.overrideAttrs (attrs:
                  {
                    buildInputs = attrs.buildInputs ++ inputs;
                  });
            addPropagatedBuildInputs = pkg:
              inputs:
                pkg.overrideAttrs (attrs:
                  {
                    propagatedBuildInputs = attrs.propagatedBuildInputs ++ inputs;
                  });
            notBroken = pkg:
              pkg.overrideAttrs (attrs:
                rec { meta.broken = false; });
            compileLocalFile = name:
              compileEmacsFiles {
                inherit name;
                src = ./emacs + ("/" + name);
              };
            fetchFromEmacsWiki = pkgs.callPackage ({ fetchurl
                                                   , name
                                                   , sha256 }:
              fetchurl {
                inherit sha256;
                url = "https://www.emacswiki.org/emacs/download/" + name;
              });
            compileNivFile = { name
                             , buildInputs ? []
                             , propagatedBuildInputs ? []
                             , patches ? [] }:
              compileEmacsFiles {
                inherit name buildInputs
                        propagatedBuildInputs patches;
                src = sources.${name};
              };
            compileEmacsWikiFile = { name
                                   , sha256
                                   , buildInputs ? []
                                   , patches ? [] }:
              compileEmacsFiles {
                inherit name buildInputs
                        patches;
                src = fetchFromEmacsWiki {
                  inherit name sha256;
                };
              };
          in {
            apropos-plus = compileNivFile { name = "apropos+"; };
            thingatpt-plus = compileNivFile { name = "thingatpt+"; };
            pp-plus = compileNivFile { name = "pp+"; };
            mbdepth-plus = compileNivFile { name = "mbdepth+"; };
            lacarte = compileNivFile { name = "lacarte"; };
            icomplete-plus = compileNivFile { name = "icomplete+"; };
            hexrgb = compileNivFile { name = "hexrgb"; };
            fuzzy-match = compileNivFile { name = "fuzzy-match"; };
            frame-fns = compileNivFile { name = "frame-fns"; };
            misc-fns = compileNivFile { name = "misc-fns"; };
            synonyms = compileNivFile { name = "synonyms";
                                        buildInputs = [ self.thingatpt-plus ];
                                      };

            hl-line-plus = compileNivFile { name = "hl-line+"; };
            vline = compileNivFile { name = "vline"; };
            col-highlight = compileNivFile { name = "col-highlight";
                                             buildInputs = [ self.vline ];
                                           };
            crosshairs = compileNivFile { name = "crosshairs";
                                          buildInputs = [ self.col-highlight self.hl-line-plus ];
                                        };

            naked = compileNivFile { name = "naked"; };
            apropos-fn-var = compileNivFile { name = "apropos-fn+var"; 
                                              buildInputs = [ self.naked ];
                                            };
            frame-cmds = compileNivFile { name = "frame-cmds";
                                          buildInputs = [
                                                          self.frame-fns
                                                          self.misc-fns
                                                          self.thingatpt-plus
                                                        ];
                                        };
            faces-plus = compileNivFile { name = "faces+";
                                          buildInputs = [ self.thingatpt-plus ];
                                        };
            doremi = compileNivFile { name = "doremi"; };
            doremi-frm = compileNivFile { name = "doremi-frm";
                                          buildInputs = [
                                                          self.doremi
                                                          self.hexrgb
                                                          self.frame-cmds
                                                          self.frame-fns
                                                          self.misc-fns
                                                          self.thingatpt-plus
                                                          self.faces-plus
                                                        ];
                                        };
            bookmark-plus = compileNivFile { name = "bookmark+";
                                             buildInputs = [
                                                             self.apropos-plus
                                                             self.thingatpt-plus
                                                             self.col-highlight
                                                             self.crosshairs
                                                             self.font-lock-plus
                                                             self.frame-fns
                                                           ];
                                           };
            icicles = compileNivFile { name = "icicles";
                                       buildInputs = [ 
                                                       self.apropos-fn-var 
                                                       self.bookmark-plus
                                                       self.crosshairs
                                                       self.doremi
                                                     ];
                                     };
            doom-modeline = super.doom-modeline.overrideAttrs (attrs: {
              src = sources.doom-modeline;
            });
            dash = super.dash.overrideAttrs (attrs: {
              src = sources.dash;
            });
            doom-themes = super.doom-themes.overrideAttrs (attrs: {
              src = sources.emacs-doom-themes;
            });
            lsp-haskell = super.lsp-haskell.overrideAttrs (attrs: {
              src = sources.lsp-haskell;
            });
            lsp-mode = super.lsp-mode.overrideAttrs (attrs: {
              src = sources.lsp-mode;
            });
            lsp-ui = super.lsp-ui.overrideAttrs (attrs: {
              src = sources.lsp-ui;
            });
            blackout = compileEmacsFiles {
              name = "blackout";
              src = sources.blackout;
            };
            frog-jump-buffer = compileEmacsFiles {
              name = "frog-jump-buffer";
              src = sources.frog-jump-buffer;
              buildInputs = [ super.avy self.dash super.projectile super.frog-menu super.posframe ];
            };
            ivy-explorer = super.ivy-explorer.overrideAttrs (attrs: {
	      src = fetchFromGitHub {
	        owner = "clemera";
	        repo  = "ivy-explorer";
	        rev = "a413966cfbcecacc082d99297fa1abde0c10d3f3";
	        sha256 = "1720g8i6jq56myv8m9pnr0ab7wagsflm0jgkg7cl3av7zc90zq8r";
	      };
	    }); 
            org-trello = super.org-trello.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "org-trello";
                repo = "org-trello";
                rev = "f02e92f5d7be03289f774875fc4e6877fe7b1aaa";
                sha256 = "0c0f6wf7d86nq3kwvjr429ddxz3q3aylm2apahw19hxx212vipb3";
              };
            });
            auth-source-pass = super.auth-source-pass.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "DamienCassou";
                repo = "auth-password-store";
                rev = "8b0c7f0b12f73da9ad002569bac700ebd58e90c2";
                sha256 = "0pf8rzlj960qx5l3dmm5qws51mkiqz18a5ay7s03f8bvfrx69qjs";
              };
            });
            magit = addPropagatedBuildInputs (super.magit) [ pkgs.git ];
            powershell = notBroken (super.powershell);
            pdf-tools = lib.overrideDerivation super.pdf-tools (attrs: {
              src = fetchFromGitHub {
                owner = "politza";
                repo = "pdf-tools";
                rev = "db7de3901ae0e55f6ab8cf9baec257f706c3d16e";
                sha256 = "1vvhgxxg5lpmh0kqjgy8x1scdaah3wb76h2zj7x99ayym2bxyigv";
              };
            });
            org-plus-contrib = self.elpaBuild rec {
              pname = "org-plus-contrib";
              version = "master";
              src = sources.org-mode;
              meta = {
                homepage = "https://elpa.gnu.org/packages/org.html";
                license = lib.licenses.free;
              };
            };
          };
      mkEmacsPackages = emacs:
        (self.emacsPackagesNgGen emacs).overrideScope' (self:
          super:
            pkgs.lib.fix (pkgs.lib.extends myEmacsPackageOverrides (_:
              super.melpaPackages // {
                inherit emacs;
                inherit (super) melpaBuild
                                elpaBuild;
                inherit (super.elpaPackages) hyperbole frog-menu;
              })));
    in {
      #emacs = pkgs.emacs26;
      emacsHEAD = with pkgs; stdenv.lib.overrideDerivation (self.emacs26.override { srcRepo = true; }) (attrs: rec {
        name = "emacs-${version}${versionModifier}";
        version = "27.0";
        versionModifier = ".50";

        doCheck = false;
        buildInputs = attrs.buildInputs ++ [ harfbuzz.dev jansson freetype ];

        patches = lib.optionals stdenv.isDarwin
          [ ./emacs/patches/tramp-detect-wrapped-gvfsd.patch
            ./emacs/patches/at-fdcwd.patch
          ];

          src = ~/src/emacs;
      });

      emacsHEADPackagesNg = mkEmacsPackages self.emacsHEAD;

      emacs = pkgs.emacsMacport;
      emacsPackagesNg = self.emacs26PackagesNg;
      emacs26PackagesNg = mkEmacsPackages (self.emacs);
      emacs26System = self.emacs26PackagesNg.emacsWithPackages;
      emacs27System = self.emacsHEADPackagesNg.emacsWithPackages;
      emacs26Env = myPkgs: pkgs.myEnvFun {
        name = "emacs26";
        buildInputs = [ (self.emacs26PackagesNg.emacsWithPackages myPkgs) ];
      };
    }
