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
            magithub = addBuildInputs (super.magithub) [
              (pkgs.git)
            ];
            magit-filenotify = addBuildInputs (super.magit-filenotify) [
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
              version = "20180924";
              src = fetchurl {
                url = "https://orgmode.org/elpa/org-plus-contrib-${version}.tar";
                sha256 = "1n76ymkkbrzdl5zc8g7zjc2vqw1640v2608is56pxqsbs4wcb5dh";
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
