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
                rev = "1800dac68f2a142ba551aa61037a0e35a85686db";
                sha256 = "0xzq05wjsqm5zp3b0wy6c3cp7482c41wssqq0vp4mxlhmm5nd8as";
              };
            });
            lsp-ui = super.lsp-ui.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "emacs-lsp";
                repo  = "lsp-ui";
                rev = "f2e2f742d0d2cd45def3e28197c84e0e85581e94";
                sha256 = "0qvqgkh1iakxddy5kpnv9aii75g38wy3nnqhmfa0hcwvncfbimx3";
              };
            });
            ox-reveal = super.ox-reveal.overrideAttrs (attrs: {
              src = fetchFromGitHub {
                owner = "yjwen";
                repo = "org-reveal";
                rev = "1cdd088ec5fab631c564dca7f9f74fd3e9b7d4d4";
                sha256 = "1vjxjadq2i74p96y9jxnqj1yb86fsgxzmn7bjgnb88ay6nvc1l72";
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
                rev = "e995fccac1ea34da34477bdcede6f1bfc0ff96f8";
                sha256 = "1b51ghpfzka905h8ii4sm7h85ncbfblrwir3rbljqpn1827xn4yx";
              };
              buildInputs = [ super.avy super.dash super.projectile super.frog-menu super.posframe ];
            };
            mu4e-conversation = withPatches (super.mu4e-conversation) [ ./emacs/patches/mu4e-conversation.patch ];
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
                rev = "8aa7aecf19090692d910036f256f67c1b8968a75";
                sha256 = "0mhby1sjnw0vvwl1yjfqmhwk9nxv1chl3qxrvkd7n51d03bfrr3j";
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
      emacs = pkgs.emacs26;
      #emacs = pkgs.emacsMacport;
      emacsPackagesNg = self.emacs26PackagesNg;
      emacs26PackagesNg = mkEmacsPackages (self.emacs);
      emacs26System = self.emacs26PackagesNg.emacsWithPackages;
      emacs26Env = myPkgs: pkgs.myEnvFun {
        name = "emacs26";
        buildInputs = [ (self.emacs26PackagesNg.emacsWithPackages myPkgs) ];
      };
    }
