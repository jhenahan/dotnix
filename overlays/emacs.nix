self:
  pkgs:
    let
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
            lsp-mode = super.lsp-mode.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "emacs-lsp";
                repo  = "lsp-mode";
                rev = "b8dd0caccc21568a086a2b450e393ffd75e836b7";
                sha256 = "1fx71c7ypdsi578a3gcg5wykhvsm43m3zs9mfpr8ldsikxws5chc";
              };
            });
            lsp-ui = super.lsp-ui.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "emacs-lsp";
                repo  = "lsp-ui";
                rev = "3ccc3e3386732c3ee22c151e6b5215a0e4c99173";
                sha256 = "1k51lwrd3qy1d0afszg1i041cm8a3pz4qqdj7561sncy8m0szrwk";
              };
            });
            blackout = compileEmacsFiles {
              name = "blackout";
              src = fetchFromGitHub {
                owner = "raxod502";
                repo = "blackout";
                rev = "87822abd1ed46411368ef91752a7f51c0ef2aee0";
                sha256 = "0n0889vsm3lzswkcdgdykgv3vz4pb9s88wwkinc5bn70vc187byp";
                # date = 2018-12-14T19:32:49-08:00;
              };
            };
            frog-jump-buffer = compileEmacsFiles {
              name = "frog-jump-buffer";
              src = fetchFromGitHub {
                owner = "waymondo";
                repo = "frog-jump-buffer";
                rev = "20e7393f07dfe2f4671c93912c8b3374b9bea678";
                sha256 = "0qzxl8wzbg83ysdhig3a2srip2a528gwhsp077xrdqwf3c7s2s7a";
              };
              buildInputs = [ super.avy super.dash super.projectile super.frog-menu super.posframe ];
            };
            #mu4e-conversation = withPatches (super.mu4e-conversation) [ ./emacs/patches/mu4e-conversation.patch ];
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
            objed = super.objed.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "clemera";
                repo = "objed";
                rev = "50769c9b42e03174ca0aa632bd778047b2197d14";
                sha256 = "0db7is3zfr33zi5a1z4zf0h3nqbfybgvp1dkkb01zrh6gi4rf9if";
              };
            });
            lua-mode = super.lua-mode.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "immerrr";
                repo = "lua-mode";
                rev = "95c64bb5634035630e8c59d10d4a1d1003265743";
                sha256 = "0cawb544qylifkvqads307n0nfqg7lvyphqbpbzr2xvr5iyi4901";
              };
            });
            magithub = addBuildInputs (super.magithub) [
              (pkgs.git)
            ];
            magit-filenotify = addBuildInputs (super.magit-filenotify) [
              (pkgs.git)
            ];
            magit-gh-pulls = addBuildInputs (super.magit-gh-pulls) [
              (pkgs.git)
            ];
            magit-lfs = addBuildInputs (super.magit-lfs) [
              (pkgs.git)
            ];
            magit-tbdiff = addBuildInputs (super.magit-tbdiff) [
              (pkgs.git)
            ];
            magit-imerge = addBuildInputs (super.magit-imerge) [
              (pkgs.git)
            ];
            github-pullrequest = addBuildInputs (super.github-pullrequest) [
              (pkgs.git)
            ];
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
              version = "20190520";
              src = fetchurl {
                url = "https://orgmode.org/elpa/org-plus-contrib-${version}.tar";
                sha256 = "0kmq5a4xx0hszbi3cc84q1mkv7qgkl9sgyzhchg4iv0vyzp6prqz";
              };
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
      emacs = pkgs.emacsMacport;
      emacsPackagesNg = self.emacs26PackagesNg;
      emacs26PackagesNg = mkEmacsPackages (self.emacs);
      emacs26System = self.emacs26PackagesNg.emacsWithPackages;
      emacs26Env = myPkgs: pkgs.myEnvFun {
        name = "emacs26";
        buildInputs = [ (self.emacs26PackagesNg.emacsWithPackages myPkgs) ];
      };
    }
