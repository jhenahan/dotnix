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
            mu4e-conversation = withPatches (super.mu4e-conversation) [ ./emacs/patches/mu4e-conversation.patch ];
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
              version = "20181230";
              src = fetchurl {
                url = "https://orgmode.org/elpa/org-plus-contrib-${version}.tar";
                sha256 = "0gibwcjlardjwq19bh0zzszv0dxxlml0rh5iikkcdynbgndk1aa1";
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
                inherit (super.elpaPackages) hyperbole;
              })));
    in {
      emacs = pkgs.emacs26;
      emacsPackagesNg = self.emacs26PackagesNg;
      emacs26PackagesNg = mkEmacsPackages (self.emacs);
      emacs26System = self.emacs26PackagesNg.emacsWithPackages;
      emacs26Env = myPkgs: pkgs.myEnvFun {
        name = "emacs26";
        buildInputs = [ (self.emacs26PackagesNg.emacsWithPackages myPkgs) ];
      };
    }
